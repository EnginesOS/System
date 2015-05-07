# @builder_public
# @system_access
# @builder_public.blueprint
# @engine_public
# def engine_environment
# end
module Templating
  
  
@sections = ["Blueprint","System","Builder","Engines","Engine"]
  
  
  def resolve_system_variable(match)
    #$config['db_dsnw'] = 'mysql://_Engines(dbuser):_Engines(dbpasswd)@_System(mysql_host)'/_Engines(dbname)';
      name = match.sub!(/_Engines_System\(/,"")
      p :matching 
      #"mysql_host)'/_Engines(dbname)"
      p match
       name.sub!(/[\)]/,"")      
      p :getting_system_value_for
      p name
      # mysql_host'/_Engines(dbname)
      
      
      var_method = @system_access.method(name.to_sym)
      val = var_method.call
      
      p :got_val
      p val
      
      return val
      
    rescue Exception=>e
      SystemUtils.log_exception(e) 
      
      return ""
    end
  #_Blueprint(software,license_name)
  #_Blueprint(software,rake_tasks,name)
  
  def apply_blueprint_variables(template)
    template.gsub!(/_Engines_Blueprint\([a-z,].*\)/) { | match |
      resolve_blueprint_variable(match)
        } 
        return template
  end
  
  
  def resolve_blueprint_variable(match)
    name = match.sub!(/_Engines_Blueprint\(/,"")
    name.sub!(/[\)]/,"")
    p :getting_blueprint_value_for
    p name
    val =""
    
     keys = name.split(',')
     hash = @builder_public.blueprint
     keys.each do |key|
       if key == nil || key.length < 1
         break
       end
       p :key
       p key
       val = hash[key.to_sym]
       p :val
       p val     
       if val != nil
         hash=val
       end
     end     
    
    p :got_val
    p val
    
    return val
    
  rescue Exception=>e
      SystemUtils.log_exception(e) 
    return ""
  end
  
def resolve_system_function(match)
  name = match.sub!(/_Engines_System\(/,"")
 
    cmd = name.split('(')
    name = cmd[0]
    if cmd.count >1
      args = cmd[1]     
      args.sub!(/\)/,"")      
    end
p :getting_system_function_for
     p name.to_sym
     p :with_args
     p args
    
  var_method = @system_access.method(name.to_sym)
      
  val = var_method.call args
  
  p :got_val
  p val
  return val
  rescue Exception=>e
      SystemUtils.log_exception(e) 
     return ""
end
    def resolve_build_variable(match)
      name = match.sub!(/_Engines_Builder\(/,"")
      name.sub!(/[\)]/,"")
      p :getting_builder_value_for
      p name.to_sym
        
      var_method = @builder_public.method(name.to_sym)
      
      val = var_method.call 
      
      p :got_val
      p val
      return val
      rescue Exception=>e
          SystemUtils.log_exception(e) 
         return ""
    end
    
    def resolve_engines_variable(match)
      name = match.sub!(/_Engines_Environment\(/,"")
      name.sub!(/[\)]/,"")
      p :getting_engines_value_for
      p name.to_sym
      engine_environment.each do |environment|
        p :checking_env
        p :looking_at
        p environment.name
          p :to_match
          p name
        if environment.name == name
          return environment.value
        end
      end
      return ""
      
      rescue Exception=>e
        p engine_environment
           SystemUtils.log_exception(e) 
          return ""
    end
    

  
def process_templated_string(template)
    if  @system_access != nil
      template = apply_system_variables(template)
    end
    if @builder_public != nil
      template = apply_build_variables(template)
    end
    if @builder_public != nil && @builder_public.blueprint != nil
      template = apply_blueprint_variables(template)
    end
    if engine_environment != nil
      template = apply_engines_variables(template)
    end
   
   
   return template
   
 rescue Eception=>e
   SystemUtils.log_exception(e)
   return template
 end
 

def apply_engines_variables(template)

  template.gsub!(/_Engines_Environment\([(0-9a-z_A-Z]*\)/) { | match |
        resolve_engines_variable(match)
      } 
      return template
end

 
 def apply_system_variables(template)
   template.gsub!(/_Engines_System\([(0-9a-z_A-Z]*\)\)/) { | match |
     p :build_function_match
     p match
           resolve_system_function(match)
         } 
   template.gsub!(/_Engines_System\([(0-9a-z_A-Z]*\)/) { | match |
     resolve_system_variable(match)
   } 
   return template
 end
 
 def apply_build_variables(template)
   

   template.gsub!(/_Engines_Builder\([(0-9a-z_A-Z]*\)/) { | match |
     resolve_build_variable(match)
       } 
       return template
 end
 

def fill_in_dynamic_vars(service_hash)
  p "FILLING_+@+#+@+@+@+@+@+"
  if service_hash.has_key?(:variables) == false || service_hash[:variables] == nil
    return
  end
  service_hash[:variables].each do |variable|
    p variable
    if variable[1] != nil && variable[1].is_a?(String) && variable[1].include?("_Engines")
      #variable[1].sub!(/\$/,"")
    #  result = evaluate_function(variable[1])
      result = process_templated_string(variable[1])
      service_hash[:variables][variable[0]] = result
    end
  end
end


  
end