class Base < ApplicationRecord
  validates :base_id, presence: true, uniqueness: true
  validates :base_name, presence: true
end
