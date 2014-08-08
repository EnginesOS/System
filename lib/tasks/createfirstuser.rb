namespace :db do
  desc "Create default admin"
  task populate: :environment do
    admin = User.create!(name: "Admin User",
                 login: "admin",
                 password: "EngOS",
                 password_confirmation: "EngOS")
    admin.toggle!(:admin)
  end
end