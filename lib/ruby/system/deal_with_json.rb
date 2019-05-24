def deal_with_json(r)
  unless r.nil?
    r = parse_as_json(r) unless r.is_a?(Hash)
    symbolise_json(r)
  end
rcue StandardError => e
  #log_error_mesg(' parse problem with ' + r.to_s)
  STDERR.puts('Exception: '+ e.to_s + "\n" + e.backtrace.to_s )
  r
end

def parse_as_json(r)
  STDERR.puts("PARSE_AS_JSPN " + r.class.name)
  STDERR.puts('Debug:' + caller[1].to_s + ':'+ caller[2].to_s )
  JSON.parse(r, create_additions: true)
end

def symbolise_json(r)
  STDERR.puts("Symbolising " + r.class.name)
  STDERR.puts('Debug:' + caller[1].to_s + ':'+ caller[2].to_s )
  if r.is_a?(Hash)
    symbolize_keys(r)
  elsif r.is_a?(Array)
    symbolize_keys_array_members(r)
  elsif r.is_a?(Tree::TreeNode)
    symbolize_tree(r)
  elsif r.is_a?(String)
    boolean_if_true_false_str(r)
  else
    r
  end
end

def symbolize_keys_array_members(a)
  unless a.count == 0
    if a[0].is_a?(Hash)
      r = []
      i = 0
      a.each do |h|
        r[i] = a[i]
        next if h.nil?
        next unless h.is_a?(Hash)
        r[i] = symbolize_keys(h)
        i += 1
      end
      r
    else
      a
    end
  else
    a
  end
end

def symbolize_keys(h)
   return h unless h.is_a?(Hash)
  h.inject({}){|r, (key, v)|
    nk = case key
    when String then key.to_sym
    else key
    end
#    STDERR.puts('key ' + nk.to_s + ':' +nk.class.name)
    nv = case v
    when Hash then symbolize_keys(v)
    when Array   then
      newval = []
      v.each do |av|
        if av.is_a?(Hash)
          av = symbolize_keys(av)
        end
        newval.push(av)
      end
      newval
    else v
    end
    r[nk] = nv
    r
  }
end

def boolean_if_true_false_str(r)
  if  r == 'true'
    true
  elsif r == 'false'
    false
  else
    r
  end
end

def symbolize_tree(t)
  STDERR.puts("Symbolising " + t.class.name)
  ns = t.children
  ns.each do |n|
    n.content = symbolize_keys(n.content) if n.content.is_a?(Hash)
    symbolize_tree(n)
  end
  t
end