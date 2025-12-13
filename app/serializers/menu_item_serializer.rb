# frozen_string_literal: true

class MenuItemSerializer
  def self.collection(menu_items)
    menu_items.map { |r| new(r).as_json }
  end

  def initialize(menu_item)
    @menu_item = menu_item
  end

  def as_json
    {
      id: @menu_item.id,
      name: @menu_item.name,
      price: @menu_item.convert_cents,
      menu_id: @menu_item.menu_id
    }
  end
end
