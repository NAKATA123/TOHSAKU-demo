User.find_or_create_by!(employee_number: "0001") do |u|
  u.email                 = "demo@example.com"
  u.name                  = "管理者"
  u.password              = "demo1234"
  u.password_confirmation = "demo1234"
  u.role                  = :admin
end
