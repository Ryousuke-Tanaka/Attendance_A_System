class AddSpreadDayToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :spread_day, :boolean, default: false
    add_column :attendances, :overtime_spread_day, :boolean, default: false
  end
end
