def write_volume(vol)
  write_run_end if @in_run == true
  write_line('VOLUME ' + vol.to_s)
  count_layer
end

def write_expose(port)
  write_run_end if @in_run == true
  write_line('EXPOSE ' + port)
  count_layer
end

def write_env(name, value, build_only = false)
  write_run_end if @in_run == true
  write_line('ENV ' + name.to_s  + " \'" + value.to_s + "\'")
  @env_file.puts(name.to_s  + '=' + "\'" + value.to_s  + "\'")
  count_layer
end

def set_user(user)
  write_run_end if @in_run == true
  write_line('USER ' + user)
  count_layer
end

def write_work_dir(wdir)
  write_run_end if @in_run == true
  write_line('WORKDIR ' + wdir)
  count_layer
end