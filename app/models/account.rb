class Account < ApplicationRecord
  belongs_to :user
  validates :username, uniqueness: { scope: [:user_id,:sns_type] }
end
