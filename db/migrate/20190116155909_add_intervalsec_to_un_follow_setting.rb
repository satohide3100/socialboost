class AddIntervalsecToUnFollowSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :un_follow_settings, :intervalsec, :integer
  end
end
