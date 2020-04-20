require 'yajl'
require 'net_x/http_unix'
require 'socket'
require_relative 'event_listener'
require_relative 'event_mask'

class DockerEventWatcher < ErrorsApi
  attr_accessor :event_listeners

  def initialize(event_listeners = {} )
    self.event_listeners = event_listeners
  end

  def restart
    finish
    start
  end

  def finish
    client.finish if client.started?
    @client = nil
  end

  def start
    client.request(Net::HTTP::Get.new('/events')) do |r|
      r.read_body do |chunk|
        begin
          parser << chunk
        rescue Yajl::ParseError => e
          STDERR.puts("EXCEPTION Chunk error on docker Event Stream _#{chunk}_")
          log_error_mesg("EXCEPTION Chunk error on docker Event Stream _#{chunk}_")
          log_exception(e, chunk)
          next
        end
      end
      STDERR.puts('END OF read_body')
    end
    log_error_mesg('Restarting docker Event Stream ')
    STDERR.puts('CLOSED docker Event Stream as close')
    STDERR.puts('client closes')
  rescue Net::ReadTimeout
    log_error_mesg('Restarting docker Event Stream Read Timeout as timeout')
    STDERR.puts("#{Time.now} :TIMEOUT docker Event Stream as close")
  rescue StandardError => e
    STDERR.puts("EXCEPTION docker Event Stream post exception due to #{e} #{e.class.name}")
    log_exception(e)
    log_error_mesg('Restarting docker Event Stream post exception ')
  ensure
    finish
  end

  def add_event_listener(object, method, event_mask = nil, container_name = nil, priority = 200)
    STDERR.puts('DEW ADD EVENT LISTENER')
    l = EventListener.new(object, method, event_mask, container_name, priority)
    mutex.synchronize do
      event_listeners[l.hash_name] = { listener: l , priority: l.priority }
    end
  end

  def rm_event_listener(listener)
    #   SystemDebug.debug(SystemDebug.container_events, 'REMOVED listenter ' + listener.class.name + ':' + listener.object_id.to_s)
    mutex.synchronize do
      event_listeners.delete(listener.object_id.to_s) if @event_listeners.key?(listener.object_id.to_s)
    end
  end

  def fill_in_event_system_values(event_hash)
    if event_hash.key?(:Actor) && event_hash[:Actor][:Attributes].is_a?(Hash)
      event_hash[:container_name] = event_hash[:Actor][:Attributes][:container_name]
      event_hash[:container_type] = event_hash[:Actor][:Attributes][:container_type]
    end
    event_hash
  end

  def match_container(hash, container_name)
    r = false
    if hash.key?(:Actor)
      if hash[:Actor].key?(:Attributes)
        if hash[:Actor][:Attributes].key?(:container_name)
          r = true if hash[:Actor][:Attributes][:container_name] == container_name
        end
      end
    end
    r
  end

  protected

  def is_valid_docker_event?(hash)
    r = false
  #  STDERR.puts("DOCKER SENT ARRAY #{hash}") if hash.is_a?(Array) && ! hash.is_a?(Hash)
  #  STDERR.puts("DOCKER SENT UNKNOWN #{hash}") unless hash.is_a?(Hash)
    r = true if hash.is_a?(Hash)
    r = false if hash.key?(:from) && hash[:from].length >= 64
    r
  end

  def trigger(hash)
    fill_in_event_system_values(hash)
    l = event_listeners.sort_by { |k, v| v[:priority] }
    l.each do |m|
      listener = m[1][:listener]
      unless listener.container_name.nil?
        next unless match_container(hash, listener.container_name)
      end
      begin
        listener.trigger(hash)
      rescue StandardError => e
        SystemDebug.debug(SystemDebug.container_events, hash.to_s + ':' + e.to_s + ':' + e.backtrace.to_s)
        STDERR.puts(hash.to_s + ':' + e.to_s + ':' + e.backtrace.to_s)
      end
    end
  rescue StandardError => e
    SystemDebug.debug(SystemDebug.container_events, hash.to_s + ':' + e.to_s + ':' + e.backtrace.to_s)
    log_exception(e)
  end

  def handle_event(event_hash)
    # SystemDebug.debug(SystemDebug.container_events, 'got ' + event_hash.to_s)
    mutex.synchronize { trigger(event_hash) } if is_valid_docker_event?(event_hash)
  end

  private

  def client
    @client ||= NetX::HTTPUnix.new('unix:///var/run/docker.sock').tap do |c|
      c.continue_timeout = 3600
      c.read_timeout = 3600
    end
  end

  def parser
    @parser ||= Yajl::Parser.new({:symbolize_keys => true}).tap do |p|
      p.on_parse_complete = method(:handle_event)
    end
  end

  def mutex
    @mutex ||= Mutex.new
  end
end
