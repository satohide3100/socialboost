class AddIntervalsecToFollowSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :follow_settings, :intervalsec, :integer
  end
end
