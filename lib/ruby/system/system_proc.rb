def resolve_pid_to_container_id(pid)
  s = get_pid_status
  unless s.is_a?(FalseClass)
    s[/NSpid:.*\n/]
  end
end

def get_pid_status(pid)
  if File.exists?("/host/sys/#{pid}/status")
    begin
    f = File.open("/host/sys/#{pid}/status")
      f.read
    ensure
      f.close
    end
  else
    false
  end
end