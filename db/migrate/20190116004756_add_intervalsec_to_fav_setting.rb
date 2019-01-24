class AddIntervalsecToFavSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :fav_settings, :intervalsec, :integer
  end
end
