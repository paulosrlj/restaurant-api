# frozen_string_literal: true

class RestaurantSerializer
  def self.collection(restaurants)
    restaurants.map { |r| new(r).as_json }
  end

  def initialize(restaurant)
    @restaurant = restaurant
  end

  def as_json
    {
      id: @restaurant.id,
      name: @restaurant.name,
      menus: MenuSerializer.collection(@restaurant.menus)
    }
  end
end
