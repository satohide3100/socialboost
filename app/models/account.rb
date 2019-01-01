class Account < ApplicationRecord
  belongs_to :user
  has_many :fav, foreign_key: :account_id, dependent: :destroy
  has_many :follow, foreign_key: :account_id, dependent: :destroy
  has_many :unfollow, foreign_key: :account_id, dependent: :destroy
  has_many :analyze, foreign_key: :account_id, dependent: :destroy
  has_many :follow_setting, foreign_key: :account_id, dependent: :destroy
  validates :username, uniqueness: { scope: [:user_id,:sns_type] }
end
