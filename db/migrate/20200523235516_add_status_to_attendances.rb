class AddStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :status, :integer, null: false, default: 0
  end
end
