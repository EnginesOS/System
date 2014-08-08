namespace :db do
  desc "Create default admin"
  task populate: :environment do
    admin = User.create!(name: "Test User",
                 email: "admin",
                 password: "test1967",
                 password_confirmation: "test1967")
    admin.toggle!(:admin)
  end
end