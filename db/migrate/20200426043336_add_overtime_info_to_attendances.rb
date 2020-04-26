class AddOvertimeInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :estimated_finished_time, :datetime
    add_column :attendances, :job_description, :string
    add_column :users, :boss, :string
  end
end
