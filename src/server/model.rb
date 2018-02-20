require 'rubygems'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'bcrypt'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")

class User
  include DataMapper::Resource
  include BCrypt
  property :id, Serial, :key => true
  property :username, String, length: 3..50
  property :group, String, length: 5..15
  property :token,  String, length: 64
  property :password, BCryptHash
  property :email, String, length: 5..200, required: true, format: :email_address
end

def authenticate(attempted_password)
  if self.password == attempted_password
    true
  else
    false
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!

