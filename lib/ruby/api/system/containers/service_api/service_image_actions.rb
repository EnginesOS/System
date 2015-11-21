module ServiceImageActions
  
  # @returns [Boolean]
   # whether pulled or no false if no new image
   def pull_image(image_name)
     @engines_core.pull_image(image_name)
   end
end