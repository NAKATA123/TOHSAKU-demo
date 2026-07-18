class User < ApplicationRecord
  authenticates_with_sorcery!

  enum role: { employee: 0, admin: 1 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :employee_number, presence: true, uniqueness: true, format: { with: /\A\d{4}\z/, message: "は4桁の数字で入力してください" }
  validates :password, presence: true, length: { minimum: 6 }, if: :new_record?
  validates :password, length: { minimum: 6 }, allow_blank: true, if: :persisted?
  validates :password_confirmation, presence: true, if: -> { password.present? }
end
