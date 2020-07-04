class CreateApplies < ActiveRecord::Migration[5.1]
  def change
    create_table :applies do |t|
      t.date :one_month
      t.integer :one_month_request_status, null: false, default: 0
      t.integer :one_month_boss
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
