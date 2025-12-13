require 'rails_helper'

RSpec.describe 'Api::V1::MenuItems', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  describe 'GET /api/v1/menu_items' do
    it 'returns all menu items' do
      menu = Menu.create!(name: 'Sides')
      menu.menu_items.create!(name: 'Fries', price: 300)
      menu.menu_items.create!(name: 'Salad', price: 400)

      get '/api/v1/menu_items', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(2)
    end
  end

  describe 'GET /api/v1/menu_items/:id' do
    it 'returns the menu item' do
      menu = Menu.create!(name: 'Mains')
      item = menu.menu_items.create!(name: 'Burger', price: 850)

      get "/api/v1/menu_items/#{item.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(item.id)
      expect(json['data']['name']).to eq('Burger')
    end
  end

  describe 'POST /api/v1/menu_items' do
    it 'creates a menu_item' do
      menu = Menu.create!(name: 'Desserts')
      params = { menu_item: { name: 'Cake', price: 600, menu_id: menu.id } }.to_json

      post '/api/v1/menu_items', params: params, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('Cake')
      expect(json['data']['menu_id']).to eq(menu.id)
    end

    it 'returns unprocessable entity when invalid' do
      params = { menu_item: { name: nil, price: nil } }.to_json

      post '/api/v1/menu_items', params: params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include("Name can't be blank").or include("Price can't be blank")
    end
  end

  describe 'PATCH /api/v1/menu_items/:id' do
    it 'updates the menu_item' do
      menu = Menu.create!(name: 'Drinks')
      item = menu.menu_items.create!(name: 'Tea', price: 200)
      params = { menu_item: { name: 'Iced Tea', price: 250 } }.to_json

      patch "/api/v1/menu_items/#{item.id}", params: params, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('Iced Tea')
      expect(item.reload.name).to eq('Iced Tea')
    end
  end

  describe 'DELETE /api/v1/menu_items/:id' do
    it 'deletes the menu_item' do
      menu = Menu.create!(name: 'Appetizers')
      item = menu.menu_items.create!(name: 'Wings', price: 500)

      delete "/api/v1/menu_items/#{item.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect { MenuItem.find(item.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
