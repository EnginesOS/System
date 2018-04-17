use Warden::Manager do |config|
  config.scope_defaults :default,
  strategies: [:access_token, :user_access_token], # Set your authorization strategy
  action: 'v0/unauthenticated'
  config.failure_app = AuthFailureApp.new
end

