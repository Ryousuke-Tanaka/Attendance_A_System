class Base < ApplicationRecord
  belongs_to :users
  
  validates :base_id, presence: true, uniqueness: true
  validates :base_name, presence: true
end
