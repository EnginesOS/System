namespace :db do
  desc "Create default admin"
  task populate: :environment do
    admin = User.create!(
                username: "admin",
                 password: "EngOS",
                 password_confirmation: "EngOS")   
  end
end