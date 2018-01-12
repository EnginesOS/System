require 'rubygems'
require 'net/ldap'
require 'gssapi'
host='uadmin.engines.internal'
service='uadmin'

gsscli = GSSAPI::Simple.new(uri.host, service)
token = gsscli.init_context

proc response(*args) {
  STDERR.puts('Response args')
}
auth_params = { 
  method: :sasl,
  mechanism: 'GSSAPI',
  initial_credential: token,
  challenge_response: response
}  

ldap = Net::LDAP.new( host: ldap, auth: auth_params)