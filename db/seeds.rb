user = User.find_or_initialize_by(email: "demo@example.com")
user.employee_number ||= "0001"
user.name            ||= "管理者"
user.role               = :admin
if user.new_record?
  user.password              = "demo1234"
  user.password_confirmation = "demo1234"
end
user.save!
