namespace :db do
  desc "Create default admin"
  task populate: :environment do
    admin = User.create!(#FIXME this is to be dynamic 
                email: "admin@engineos.com",
                username: "admin",
                 password: "EngOS2014",
                 password_confirmation: "EngOS2014")   
  end
end