# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding users..."

admin = User.find_or_create_by!(email: "admin@taskflow.com") do |u|
  u.password = "Password123!"
  u.password_confirmation = "Password123!"
  u.role = :admin
end
puts "  ✓ Admin:   #{admin.email}"

manager = User.find_or_create_by!(email: "manager@taskflow.com") do |u|
  u.password = "Password123!"
  u.password_confirmation = "Password123!"
  u.role = :manager
end
puts "  ✓ Manager: #{manager.email}"

member = User.find_or_create_by!(email: "member@taskflow.com") do |u|
  u.password = "Password123!"
  u.password_confirmation = "Password123!"
  u.role = :member
end
puts "  ✓ Member:  #{member.email}"

puts "\nDone! Login credentials (all use password: 'Password123!'):"
puts "  Admin   → admin@taskflow.com"
puts "  Manager → manager@taskflow.com"
puts "  Member  → member@taskflow.com"
