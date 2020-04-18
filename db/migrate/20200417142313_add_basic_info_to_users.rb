class AddBasicInfoToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :basic_time, :datetime, default: Time.current.change(hour: 8, min: 0, sec: 0)
    add_column :users, :start_work_time, :datetime, default: Time.current.change(hour: 9, min: 0, sec: 0)
    add_column :users, :finish_work_time, :datetime, default: Time.current.change(hour: 18, min: 0, sec: 0)
  end
end
