class CreateFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :follows do |t|
      t.string :target_username
      t.string :target_name
      t.string :target_image
      t.integer :follow_flg
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
