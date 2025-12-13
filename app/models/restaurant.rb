class Restaurant < ApplicationRecord
  validates :name, presence: true

  has_many :menus, dependent: :destroy
end
