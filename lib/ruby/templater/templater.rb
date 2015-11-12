class Templater
  require_relative '../system/system_access.rb'
  # @sections = ["Blueprint","System","Builder","Engines","Engine"]
  #
  def initialize(system_access, builder_public)
    @system_access = system_access
    @builder_public = builder_public
  end

  def resolve_system_variable(match)
 
    name = match.sub!(/_Engines_System\(/, '')
    name.sub!(/[\)]/, '')
    var_method = @system_access.method(name.to_sym)
    val = var_method.call
    return val
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return ''
  end

  def apply_blueprint_variables(template)
    return nil if template.nil?
    template.gsub!(/_Engines_Blueprint\([a-z,].*\)/) { |match|
      resolve_blueprint_variable(match)
    }
    return template
  end

  def resolve_blueprint_variable(match)
    name = match.sub!(/_Engines_Blueprint\(/, '')
    name.sub!(/[\)]/, '')
    #    p :getting_blueprint_value_for
    #    p name
    val = ''
    keys = name.split(',')
    hash = @builder_public.blueprint
    keys.each do |key|
      break if key.nil? == true || key.length < 1
      val = hash[key.to_sym]
      hash = val if val.nil? == false
    end
    #    p :got_val
    #    p val
    return val
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return ''
  end

  def resolve_system_function(match)
    name = match.sub!(/_Engines_System\(/, '')
    cmd = name.split('(')
    name = cmd[0]
    if cmd.count > 1
      args = cmd[1]
      args.sub!(/\)/, '')
    end
    var_method = @system_access.method(name.to_sym)
    var_method.call(args)
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return ''
  end

  def resolve_build_variable(match)
    name = match.sub!(/_Engines_Builder\(/, '')
    name.sub!(/[\)]/, '')
    var_method = @builder_public.method(name.to_sym)
    var_method.call
  rescue StandardError
    return 'no match for ' + name.to_s
  end

  def resolve_engines_variable(match)
    name = match.sub!(/_Engines_Environment\(/, '')
    name.sub!(/[\)]/, '')
    @builder_public.engine_environment.each do |environment|
      if environment.name == name
        return environment.value
      end
    end
    return ''
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return ''
  end

  def set_system_access(system)
    @system_access = system
  end

  def process_templated_string(template)
    if @system_access.nil? == false
      template = apply_system_variables(template)
    else
      SystemUtils.log_error_mesg('nil system access', template)
    end
    unless @builder_public.nil?
      template = apply_build_variables(template)
      if @builder_public.respond_to?('blueprint')\
      && @builder_public.blueprint.nil? == false
        template = apply_blueprint_variables(template)
      end
      if @builder_public.engine_environment.nil? == false && @builder_public.engine_environment.count > 0
        template = apply_engines_variables(template)
#      else
#        SystemUtils.log_error_mesg('nil or empty engines variables ' + template.to_s, @builder_public.engine_environment.to_s)
      end
    end
    return template
  rescue StandardError => e
    p template
    SystemUtils.log_exception(e)
    return template
  end

  def apply_engines_variables(template)
    return template if template.is_a?(String) == false
    template.gsub!(/_Engines_Environment\([(0-9a-z_A-Z]*\)/) { |match|
      resolve_engines_variable(match)
    }
    return template
  end

  def apply_system_variables(template)
    return template if template.is_a?(String) == false
    template.gsub!(/_Engines_System\([(0-9a-z_A-Z]*\)\)/) { |match|
      #     p :build_function_match
      #     p match
      resolve_system_function(match)
    }
    template.gsub!(/_Engines_System\([(0-9a-z_A-Z]*\)/) { |match|
      resolve_system_variable(match)
    }
    return template
  rescue StandardError => e
    p 'problem with ' + template.to_s
    SystemUtils.log_exception(e)
  end

  def apply_build_variables(template)
    return template if template.is_a?(String) == false     
    template.gsub!(/_Engines_Builder\([(0-9a-z_A-Z]*\)/) { |match|
      resolve_build_variable(match)
    }
    return template
  end

  def fill_in_dynamic_vars(service_hash)
    p 'FILLING_+@+#+@+@+@+@+@+'
    return false if service_hash.key?(:variables) == false || service_hash[:variables].nil? == true
    service_hash[:variables].each do |variable|
      p variable
      if variable[1].nil? == false && variable[1].is_a?(String) && variable[1].include?('_Engines')
        p :processing
        p variable[1]
        result = process_templated_string(variable[1])
        service_hash[:variables][variable[0]] = result
      end
    end
    return true
  end

  def fill_in_service_def_values(service_def)
    #  p :fill_in_service_def_values
    if service_def.key?(:consumer_params) && service_def[:consumer_params].is_a?(Hash)
      #    p service_def[:consumer_params]
      #      p service_def[:consumer_params].values
      service_def[:consumer_params].values.each do |field|
        #      p :value
        #      p field
        if field.key?(:value)
          value = process_templated_string(field[:value])
          field[:value] = value
        end
      end
    end
    return service_def
  end

  def proccess_templated_service_hash(service_hash)
    fill_in_dynamic_vars(service_hash)
  end
end
