class AddStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :status, :integer, null: false, default: 0
    add_column :attendances, :change, :boolean, default: false
  end
end