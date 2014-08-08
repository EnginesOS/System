namespace :db do
  desc "Create default admin"
  task populate: :environment do
    admin = User.create!(#FIXME this is to be dynamic 
                email: "admin@engineos.com",
                username: "admin",
                 password: "EngOS",
                 password_confirmation: "EngOS")   
  end
end