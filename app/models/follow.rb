class Follow < ApplicationRecord
  belongs_to :account
  validates :target_username, uniqueness: { scope: [:account_id] }
end
