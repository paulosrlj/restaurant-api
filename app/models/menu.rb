class Menu < ApplicationRecord
  validates :name, presence: true

  has_many :menu_items, dependent: :destroy
  accepts_nested_attributes_for :menu_items, allow_destroy: true

  belongs_to :restaurant
end
