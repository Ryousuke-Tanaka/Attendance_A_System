class Base < ApplicationRecord
  
  validates :base_id, presence: true, uniqueness: true, numericality: { greater_than: 0 } 
  validates :base_name, presence: true, uniqueness: true
end
