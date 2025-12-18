require 'rails_helper'

RSpec.describe 'Api::V1::Restaurants', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
  let(:restaurant) { Restaurant.create!(name: 'Test Restaurant') }

  describe 'GET /api/v1/restaurants' do
    it 'returns all restaurants with "menu" and "menu_item" associations' do
      menu1 = Menu.create!(name: 'Breakfast', restaurant:)
      menu2 = Menu.create!(name: 'Lunch', restaurant:)
      MenuItem.create!(name: 'Burger', price: 700, menu: menu1)
      MenuItem.create!(name: 'Cheesebread', price: 300, menu: menu2)

      get '/api/v1/restaurants', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data'].length).to eq(1)
      expect(json['data'][0]['menus'].length).to eq(2)
      expect(json['data'][0]['menus'][0]['menu_items'].length).to eq(1)
      expect(json['data'][0]['menus'][1]['menu_items'].length).to eq(1)
    end

    it 'returns only 10 restaurants due to pagination' do
      30.times do |num|
        Restaurant.create!(name: "Test Restaurant#{num}")
      end

      get '/api/v1/restaurants?page=1', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data'].length).to eq(20)
    end
  end

  describe 'GET /api/v1/restaurants/:id' do
    it 'returns the restaurant' do
      restaurant = Restaurant.create!(name: 'Test Restaurant')

      get "/api/v1/restaurants/#{restaurant.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(restaurant.id)
      expect(json['data']['name']).to eq('Test Restaurant')
    end
  end

  describe 'POST /api/v1/restaurants' do
    it 'creates a restaurant' do
      params = { restaurant: { name: 'Test Restaurant' } }.to_json

      post '/api/v1/restaurants', params: params, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('Test Restaurant')
    end

    it 'creates a restaurant with nested associations' do
      params = {
        restaurant: {
          name: 'Test Restaurant',
          menus_attributes: [
            {
              name: 'Test Menu',
              menu_items_attributes: [
                { name: 'Item 1 test', price: 200 },
                { name: 'Item 2 test', price: 200 }
              ]
            }
          ]
        }
      }.to_json

      post '/api/v1/restaurants', params: params, headers: headers

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      data = json['data']

      # Restaurant
      expect(data['name']).to eq('Test Restaurant')
      expect(data['menus'].size).to eq(1)

      # Menu
      menu = data['menus'].first
      expect(menu['name']).to eq('Test Menu')
      expect(menu['menu_items'].size).to eq(2)

      # MenuItem
      item = menu['menu_items'].first
      expect(item['name']).to eq('Item 1 test')
      expect(item['price']).to eq(2)
    end

    it 'returns unprocessable entity when invalid' do
      params = { restaurant: { name: nil } }.to_json

      post '/api/v1/restaurants', params: params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include("Name can't be blank").or include("can't be blank")
    end
  end

  describe 'PATCH /api/v1/restaurants/:id' do
    it 'updates the restaurant' do
      restaurant = Restaurant.create!(name: 'Test Restaurant')
      params = { restaurant: { name: 'Test Restaurant Updated' } }.to_json

      patch "/api/v1/restaurants/#{restaurant.id}", params: params, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('Test Restaurant Updated')
      expect(restaurant.reload.name).to eq('Test Restaurant Updated')
    end
  end

  describe 'DELETE /api/v1/restaurants/:id' do
    it 'deletes the restaurant' do
      restaurant = Restaurant.create!(name: 'Test Restaurant')

      delete "/api/v1/restaurants/#{restaurant.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect { Restaurant.find(restaurant.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
