class CreateFollowSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :follow_settings do |t|
      t.integer :dayLimit
      t.integer :interval
      t.integer :count_by_interval
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
