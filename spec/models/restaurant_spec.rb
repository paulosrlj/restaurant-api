require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  it 'is valid with a name' do
    r = Restaurant.new(name: 'Test Restaurant')
    expect(r).to be_valid
  end

  it 'is invalid without a name' do
    r = Restaurant.new(name: nil)
    expect(r).not_to be_valid
    expect(r.errors[:name]).to include("can't be blank")
  end

  it 'has many menus' do
    r = Restaurant.create!(name: 'Test R')
    r.menus.create!(name: 'Brunch')
    expect(r.menus.count).to eq(1)
  end

  it 'can be created with menus and menu_items using nested attributes' do
    restaurant = Restaurant.create!(
      name: 'Test Restaurant',
      menus_attributes: [
        {
          name: 'Lunch',
          menu_items_attributes: [
            { name: 'Burger', price: 1200 },
            { name: 'Salad', price: 800 }
          ]
        }
      ]
    )

    expect(restaurant.menus.count).to eq(1)
    expect(restaurant.menus.first.menu_items.count).to eq(2)

    expect(restaurant.menus.first.menu_items.first.name).to eq('Burger')
  end

  it 'destroys dependent menus when destroyed' do
    r = Restaurant.create!(name: 'ToDelete')
    menu = r.menus.create!(name: 'Temp')
    expect { r.destroy }.to change { Menu.count }.by(-1)
    expect { Menu.find(menu.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'accepts nested attributes for menus' do
    params = { name: 'Nested', menus_attributes: [ { name: 'Nested Menu' } ] }
    r = Restaurant.create!(params)
    expect(r.menus.size).to eq(1)
    expect(r.menus.first.name).to eq('Nested Menu')
  end

  it 'allows nested attributes to destroy menus' do
    r = Restaurant.create!(name: 'Parent')
    m = r.menus.create!(name: 'Will be removed')

    attrs = { menus_attributes: [ { id: m.id, _destroy: '1' } ] }
    r.update(attrs)

    expect(r.menus.reload).to be_empty
  end
end
