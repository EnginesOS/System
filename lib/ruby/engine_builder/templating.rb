module Templating
  
@sections = ["Blueprint","System","Builder","Engines"]
  
  
  def resolve_system_variable(match)
      name = match.sub!(/_System\(/,"")
      p :matching
      p match
      name.sub!(/[\)]/,"")      
      p :getting_system_value_for
      p name
      
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
    template.gsub!(/_Blueprint\([a-z,].*\)/) { | match |
      resolve_blueprint_variable(match)
        } 
        return template
  end
  
  
  def resolve_blueprint_variable(match)
    name = match.sub!(/_Blueprint\(/,"")
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
  
    def resolve_build_variable(match)
      name = match.sub!(/_Builder\(/,"")
      name.sub!(/[\)]/,"")
      p :getting_builder_value_for
      p name.to_sym
      if name.include?('(')  == true
        cmd = name.split('(')
        name = cmd[0]
        if cmd.count >1
          args = cmd[1]     
          args.sub!(/\)/,"")
          args_array = args.split
        end
      end
        
      var_method = @builder_public.method(name.to_sym)
      if args
        p :got_args
        val = var_method.call args
      else
        val = var_method.call 
      end
      p :got_val
      p val
      return val
      rescue Exception=>e
          SystemUtils.log_exception(e) 
         return ""
    end
    
    def resolve_engines_variable(match)
      name = match.sub!(/_Engines\(/,"")
      name.sub!(/[\)]/,"")
      p :getting_engines_value_for
      p name.to_sym
      @blueprint_reader.environments.each do |env_hash|
        if env_hash[:name] == name
          return env_hash[:value]
        end
      end
      return ""
      
      rescue Exception=>e
        p @blueprint_reader.environments
           SystemUtils.log_exception(e) 
          return ""
    end
    
    def apply_engines_variables(template)
  
      template.gsub!(/_Engines\([a-z].*\)/) { | match |
            resolve_engines_variable(match)
          } 
          return template
    end
  
def process_templated_string(template)
      template = apply_system_variables(template)
      template = apply_build_variables(template)
      template = apply_blueprint_variables(template)
      template = apply_engines_variables(template)
   return template
 rescue Eception=>e
   SystemUtils.log_exception(e)
   return template
 end
 

 
 def apply_system_variables(template)
   template.gsub!(/_System\([a-z].*\)/) { | match |
     resolve_system_variable(match)
   } 
   return template
 end
 
 def apply_build_variables(template)
   template.gsub!(/_Builder\([a-z].*\)/) { | match |
         resolve_build_variable(match)
       } 
       return template
 end
 
 
  
  
end