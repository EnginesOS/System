class Registry

  # @return [Array] of all service_hash(s) below this branch
     def get_all_leafs_service_hashes(branch)
       ret_val = Array.new
       SystemUtils.debug_output("top node",branch.name)
       branch.children.each do |sub_branch|
         SystemUtils.debug_output("on node",sub_branch.name)
         if sub_branch.children.count == 0
           if sub_branch.content.is_a?(Hash)
            
             SystemUtils.debug_output("pushed_content", sub_branch.content)
             ret_val.push(sub_branch.content)
           else
             SystemUtils.debug_output("skipping content ", sub_branch.content)
           end
         else
           ret_val.concat(get_all_leafs_service_hashes(sub_branch))
         end
       end
       return ret_val
       rescue Exception=>e
            log_exception(e)
            return nil
     end
   #@branch the [TreeNode] under which to search
     #@param label the hash key for the value to match value against
     #@return [Array] all service_hash(s) which contain the hash pair label=value    
     #@return empty array if none
     def get_matched_leafs(branch,label,value)
       ret_val = Array.new
       SystemUtils.debug_output("top node",branch.name)
       branch.children.each do |sub_branch|
         SystemUtils.debug_output("sub node",sub_branch.name)
         if sub_branch.children.count == 0
           if sub_branch.content.is_a?(Hash) 
             if  sub_branch.content[label] == value
               ret_val.push(sub_branch.content)   
             end
           else
            SystemUtils.debug_output("Leaf Content not a hash ",sub_branch.content)
              end
         else #children.count > 0
           ret_val.concat(get_matched_leafs(sub_branch,label,value))
         end #if children.count == 0
       end #do
       return ret_val
     end
end