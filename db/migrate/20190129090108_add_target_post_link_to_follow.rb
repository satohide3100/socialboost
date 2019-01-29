class AddTargetPostLinkToFollow < ActiveRecord::Migration[5.2]
  def change
    add_column :follows, :target_postLink, :string
  end
end
