require 'rails_helper'

RSpec.describe 'Api::V1::Menus', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
  let(:restaurant) { Restaurant.create!(name: 'Test Restaurant') }

  describe 'GET /api/v1/menus' do
    it 'returns all menus' do
      Menu.create!(name: 'Breakfast', restaurant:)
      Menu.create!(name: 'Lunch', restaurant:)

      get '/api/v1/menus', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns only 20 menus due to pagination' do
      30.times do |num|
        Menu.create!(name: "Test Menu#{num}", restaurant:)
      end

      get '/api/v1/menus?page=1', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data'].length).to eq(20)
    end
  end

  describe 'GET /api/v1/menus/:id' do
    it 'returns the menu' do
      menu = Menu.create!(name: 'Dinner', restaurant:)

      get "/api/v1/menus/#{menu.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(menu.id)
      expect(json['data']['name']).to eq('Dinner')
    end
  end

  describe 'POST /api/v1/menus' do
    it 'creates a menu' do
      params = { menu: { name: 'Specials', restaurant_id: restaurant.id } }.to_json

      post '/api/v1/menus', params: params, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('Specials')
    end

    it 'creates a menu with menu_items' do
      menu_items_attributes = [{ "name": "Bread", "price": 200 }]
      params = { menu: { name: 'Specials', restaurant_id: restaurant.id, menu_items_attributes: } }.to_json

      post '/api/v1/menus', params: params, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      p json
      expect(json['data']['name']).to eq('Specials')
      expect(json['data']['menu_items']).to match([a_hash_including('name' => 'Bread', 'price' => 2.0)])
    end

    it 'returns unprocessable entity when invalid' do
      params = { menu: { name: nil } }.to_json

      post '/api/v1/menus', params: params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include("Name can't be blank").or include("can't be blank")
    end
  end

  describe 'PATCH /api/v1/menus/:id' do
    it 'updates the menu' do
      menu = Menu.create!(name: 'Old', restaurant:)
      params = { menu: { name: 'Updated' } }.to_json

      patch "/api/v1/menus/#{menu.id}", params: params, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('Updated')
      expect(menu.reload.name).to eq('Updated')
    end
  end

  describe 'DELETE /api/v1/menus/:id' do
    it 'deletes the menu' do
      menu = Menu.create!(name: 'ToDelete', restaurant:)

      delete "/api/v1/menus/#{menu.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect { Menu.find(menu.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
