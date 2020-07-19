class CreateBases < ActiveRecord::Migration[5.1]
  def change
    create_table :bases do |t|
      t.integer :base_id, unique: true
      t.string :base_name, unique: true
      t.string :attendance_type

      t.timestamps
    end
    add_index :bases, [:base_id], unique: true
  end
end
