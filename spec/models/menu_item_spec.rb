require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  let(:menu) { Menu.create!(name: 'Brunch') }

  it 'is valid with a name, price and menu' do
    item = menu.menu_items.build(name: 'Pancakes', price: 500)
    expect(item).to be_valid
  end

  it 'is invalid without a name' do
    item = menu.menu_items.build(name: nil, price: 300)
    expect(item).not_to be_valid
    expect(item.errors[:name]).to include("can't be blank")
  end

  it 'is invalid without a price' do
    item = menu.menu_items.build(name: 'Toast', price: nil)
    expect(item).not_to be_valid
    expect(item.errors[:price]).to include("can't be blank")
  end

  it 'is invalid with negative price' do
    item = menu.menu_items.build(name: 'Coffee', price: -1)
    expect(item).not_to be_valid
    expect(item.errors[:price]).to include('must be greater than or equal to 0')
  end

  it 'belongs to menu' do
    item = MenuItem.create!(name: 'Omelette', price: 700, menu: menu)
    expect(item.menu).to eq(menu)
  end

  it 'should convert cents' do
    item = MenuItem.create!(name: 'Burger', price: 700, menu: menu)
    expect(item.convert_cents).to eq(7)
  end
end
