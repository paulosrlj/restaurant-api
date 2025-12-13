require 'rails_helper'

RSpec.describe Menu, type: :model do
  let(:restaurant) { Restaurant.create(name: 'Test Restaurant') }

  it 'is valid with a name' do
    menu = Menu.new(name: 'Lunch', restaurant:)

    expect(menu).to be_valid
  end

  it 'is invalid without a name' do
    menu = Menu.new(name: nil, restaurant:)
    expect(menu).not_to be_valid
    expect(menu.errors[:name]).to include("can't be blank")
  end

  it 'can have many menu_items' do
    menu = Menu.create!(name: 'Dinner', restaurant:)
    menu.menu_items.create!(name: 'Steak', price: 20.0)
    expect(menu.menu_items.count).to eq(1)
  end

end
