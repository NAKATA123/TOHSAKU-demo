class User < ApplicationRecord
  authenticates_with_sorcery!

  enum role: { employee: 0, admin: 1 }

  validates :name, presence: true
  validates :employee_number, presence: true, uniqueness: true, format: { with: /\A\d{4}\z/, message: "は4桁の数字で入力してください" }
end
