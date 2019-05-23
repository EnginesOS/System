def deal_with_json(r)
  unless r.nil?
    r = parse_as_json(r) unless r.is_a?(Hash)
    symbolise_json(r)
  end
rescue StandardError => e
  #log_error_mesg(' parse problem with ' + r.to_s)
  STDERR.puts('Exception: '+ e.to_s + "\n" + e.backtrace.to_s )
  r
end

def parse_as_json(r)
  JSON.parse(r, create_additions: true)
end

def symbolise_json(r)
  # STDERR.puts("Symbolising " + hash.class.name)
  # STDERR.puts('Debug:' + caller[1].to_s + ':'+ caller[2].to_s )
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

def symbolize_keys_array_members(ar)
  unless ar.count == 0
    if ar[0].is_a?(Hash)
      rv = []
      i = 0
      ar.each do |h|
        rv[i] = ar[i]
        next if h.nil?
        next unless hash.is_a?(Hash)
        rv[i] = symbolize_keys(h)
        i += 1
      end
      rv
    else
      ar
    end
  else
    ar
  end
end

def symbolize_keys(h)
  return h unless h.is_a?(Hash)
  h.inject({}){|r, (k, v)|
    nk = case k
    when String then k.to_sym
    else k
    end
    #    STDERR.puts('k ' + nk.to_s + ':' +nk.class.name)
    new_value = case v
    when Hash then symbolize_keys(v)
    when Array   then
      nv = []
      v.each do |av|
        if av.is_a?(Hash)
          av = symbolize_keys(av)
        end
        nv.push(av)
      end
      nv
    else v
    end
    r[nk] = nv
    r
  }
end

def boolean_if_true_false_str(r)
  if r == 'true'
    true
  elsif r == 'false'
    false
  else
    r
  end
end

def symbolize_tree(tr)
  #  STDERR.puts("Symbolising " + tree.class.name)
  ns = tr.children
  ns.each do |n|
    n.content = symbolize_keys(n.content) if n.content.is_a?(Hash)
    symbolize_tree(n)
  end
  tr
end