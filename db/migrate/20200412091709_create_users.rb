class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name, presence: true
      t.string :email, presence: true

      t.timestamps
    end
  end
end
