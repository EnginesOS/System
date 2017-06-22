def write_comment(cmt)
  unless @in_run == true
    @docker_file.puts(cmt)
  else
    write_run_line("echo \"" + cmt + "\"")
  end
end

def write_run_line(cmd)
  write_run_start unless @in_run == true
  if @first_line == true
    @docker_file.write("\\\n     " + cmd)
  else
    @docker_file.write("&& \\\n     " + cmd)
  end
  @first_line = false
end

def write_run_start(comment = '')
  unless @in_run == true
    @in_run = true
    @first_line = true
    write_line("\n#Start of Run:" + comment.to_s)
    @docker_file.write('RUN ')
    count_layer
  end
end

def write_run_end
  write_line("\n#End of Run:\n\n")
  @in_run = false
end

def write_build_script(cmd)
  write_run_line('/build_scripts/' + cmd)
end

def write_line(line)
  @docker_file.puts(line)
end

def insert_framework_frag_in_dockerfile(frag_name)
  log_build_output(frag_name)
  write_run_end if @in_run == true
  write_comment('#Framework Frag')
  frame_build_docker_frag = File.open(build_dir + '/Dockerfile.' + frag_name)
  builder_frag = frame_build_docker_frag.read
  @docker_file.write("\n")
  write_comment('#Docker Fragment ' + frag_name.to_s)
  @docker_file.write(builder_frag)
  @docker_file.write("\n")
  frame_build_docker_frag.close
end

