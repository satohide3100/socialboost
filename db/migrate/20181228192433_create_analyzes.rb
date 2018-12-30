class CreateAnalyzes < ActiveRecord::Migration[5.2]
  def change
    create_table :analyzes do |t|
      t.integer :follow_count
      t.integer :follower_count
      t.integer :post_count
      t.integer :faved_count
      t.string :profile_image
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
