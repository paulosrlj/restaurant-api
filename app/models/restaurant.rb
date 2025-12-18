class Restaurant < ApplicationRecord
  validates :name, presence: true

  has_many :menus, dependent: :destroy
  accepts_nested_attributes_for :menus, allow_destroy: true

end
