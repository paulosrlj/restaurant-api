class Menu < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :menu_items, dependent: :destroy

  belongs_to :restaurant
end
