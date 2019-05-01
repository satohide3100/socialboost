class Account < ApplicationRecord
  belongs_to :user
  has_many :favs, foreign_key: :account_id, dependent: :delete_all
  has_many :fav_settings, foreign_key: :account_id, dependent: :delete_all
  has_many :follows, foreign_key: :account_id, dependent: :delete_all
  has_many :unfollows, foreign_key: :account_id, dependent: :delete_all
  has_many :analyzes, foreign_key: :account_id, dependent: :delete_all
  has_many :follow_settings, foreign_key: :account_id, dependent: :delete_all
  has_many :un_follow_settings, foreign_key: :account_id, dependent: :delete_all
  has_many :notifications, foreign_key: :account_id, dependent: :delete_all

  validates :username, uniqueness: { scope: [:user_id,:sns_type] }
end
