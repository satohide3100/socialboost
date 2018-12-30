class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.integer :sns_type
      t.string :username
      t.string :pass
      t.integer :active_flg
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
