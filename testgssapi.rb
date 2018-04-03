
require 'rubygems'
require 'net/ldap'
require 'gssapi'
host='uadmin.engines.internal'
service='host'

gsscli = GSSAPI::Simple.new(host, service, '/var/lib/engines/services/auth/etc/krb5kdc/services/uadmin/uadmin.keytab')
token = gsscli.init_context.force_encoding('binary')

puts 'token ' + token.to_s



def response
end

auth_params = {
  method: :sasl,
  mechanism: 'GSSAPI',
  initial_credential: token,
  challenge_response: lambda do |inp|
      puts "INP #{inp.size}"
        puts "INP #"
    end
}

ldap = Net::LDAP.new( host: 'ldap.engines.internal', auth: auth_params)
if ldap.bind
        puts "Connection successful!  Code:  #{ldap.get_operation_result.code}, message: #{ldap.get_operation_result.message}"
else
        puts "Connection failed!  Code:  #{ldap.get_operation_result.code}, message: #{ldap.get_operation_result.message}"
end
