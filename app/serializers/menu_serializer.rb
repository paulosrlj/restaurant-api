# frozen_string_literal: true

class MenuSerializer
  def self.collection(menus)
    menus.map { |r| new(r).as_json }
  end

  def initialize(menu)
    @menu = menu
  end

  def as_json
    {
      id: @menu.id,
      name: @menu.name,
      menu_items: MenuItemSerializer.collection(@menu.menu_items)
    }
  end
end
