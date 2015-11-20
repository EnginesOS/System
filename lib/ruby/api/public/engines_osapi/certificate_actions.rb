module CertificateActions
  def get_system_ca
    File.read(SystemConfig.EnginesInternalCA)
  rescue StandardError => e
    failed('Failed to load CA', e.to_s, 'system ca')
  end

  def upload_ssl_certificate(params)
    return failed('invalid parameter', 'upload Cert ', params.to_s) unless params.is_a?(Hash)
    unless params.has_key?(:certificate) || params.key?(:domain_name)
      return failed('error expect keys  :certificate :domain_name with optional :use_as_default', 'uploads cert', params.to_s)
    end
    return success('Sucess', 'upload Cert' + params[:domain_name]) if @core_api.upload_ssl_certificate(params)
    return failed('Failed to install cert:',  @core_api.last_error, params.to_s)
  end

end