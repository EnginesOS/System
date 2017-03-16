module UserAuth
  def user_login(params)
    @core_api.user_login(params)
  rescue StandardError => e
    handle_exception(e)
  end
end