class Base < ApplicationRecord
  has_many :users
  
  validates :base_id, presence: true, uniqueness: true
  validates :base_name, presence: true
end
