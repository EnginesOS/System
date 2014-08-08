namespace :db do
  desc "Create default admin"
  task populate: :environment do
    admin = User.create!(name: "Admin User",
                username: "admin",
                 password: "EngOS",
                 password_confirmation: "EngOS")   
  end
end