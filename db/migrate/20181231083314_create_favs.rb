class CreateFavs < ActiveRecord::Migration[5.2]
  def change
    create_table :favs do |t|
      t.string :target_postLink
      t.string :target_postImage
      t.string :target_username
      t.string :target_name
      t.integer :fav_flg
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
