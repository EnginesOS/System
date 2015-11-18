module SystemKeyActions
  # @returns EnginesOSapiResult on sucess with private ssh key in repsonse messages
  def generate_engines_user_ssh_key
    return success('Engines ssh key regen', 'OK') if @core_api.generate_engines_user_ssh_key
    failed('Update System SSH key', @core_api.last_error, 'Update System SSH key')
  end
  def generate_private_key
      res = @core_api.generate_engines_user_ssh_key
      return failed('Failed update key ', @core_api.last_error, res.to_s) unless res.is_a?(String)
      return res
    end
  
    def update_public_key(key)
      return success('Access', 'update public key') if @core_api.update_public_key(key)
      failed('Failed update key ', @core_api.last_error, key.to_s)
    end

end