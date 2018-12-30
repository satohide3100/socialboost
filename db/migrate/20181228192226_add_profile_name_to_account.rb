class AddProfileNameToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :profile_name, :string
  end
end
