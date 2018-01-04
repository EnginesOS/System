def write_persistent_files
   unless @blueprint_reader.persistent_files.nil?
     write_comment('#Persistant Files')
     log_build_output('set setup_env')
     paths = ''
     src_paths = @blueprint_reader.persistent_files
     unless src_paths.nil?
       src_paths.each do |p_file|
         p_file[:volume_name] = templater.process_templated_string(p_file[:volume_name])         
         path = p_file[:path]
         dir = File.dirname(path)
         file = File.basename(path)
         SystemDebug.debug(SystemDebug.builder, :dir, dir)
         if dir.is_a?(String) == false || dir.length == 0 || dir == '.' || dir == '..'
           path = 'app/' + file
         end
         paths +=  p_file[:volume_name].to_s + ':' + path + ' '
       end
       write_build_script('persistent_files.sh   ' + paths)
     end
   end
 end
 
def write_persistent_dirs
  unless @blueprint_reader.persistent_dirs.nil?
    log_build_output('setup persistent Dirs')
    paths = ''
    write_comment('#Persistant Dirs')
    @blueprint_reader.persistent_dirs.each do |p_dir|
      p_dir[:volume_name] = templater.process_templated_string(p_dir[:volume_name])      
      path = p_dir[:path]
      path.chomp!('/')
      paths += p_dir[:volume_name].to_s + ':' + path + ' ' unless path.nil?
    end
    write_build_script('persistent_dirs.sh  ' + paths)
  end
end