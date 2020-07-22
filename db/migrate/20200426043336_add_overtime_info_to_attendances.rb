class AddOvertimeInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :estimated_finished_time, :datetime
    add_column :attendances, :job_description, :string
    add_column :attendances, :overtime_boss, :integer
    add_column :attendances, :edit_attendance_boss, :integer
  end
end
