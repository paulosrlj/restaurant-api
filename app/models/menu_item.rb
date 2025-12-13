class MenuItem < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :menu_id }
  # The price is stored in cents, to avoid rounding errors
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :menu

  def convert_cents
    price / 100.to_f
  end
end

