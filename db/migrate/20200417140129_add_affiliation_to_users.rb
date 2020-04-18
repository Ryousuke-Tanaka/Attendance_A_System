class AddAffiliationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :affiliation, :string, default: "未所属" 
  end
end
