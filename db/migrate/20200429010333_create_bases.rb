class CreateBases < ActiveRecord::Migration[5.1]
  def change
    create_table :bases do |t|
      t.string :base_id
      t.string :integer
      t.string :base_name
      t.string :attendance_type
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :bases, [:base_id, :user_id], unique: true
  end
end
