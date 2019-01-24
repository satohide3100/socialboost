class Fav < ApplicationRecord
  belongs_to :account
  validates :target_postLink, uniqueness: { scope: [:account_id] }
  
end
