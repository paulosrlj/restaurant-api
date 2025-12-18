# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::JsonToModelConverter', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  let(:payload) do
    {
      restaurants: [
        {
          name: "Poppo's Cafe",
          menus: [
            {
              name: "lunch",
              menu_items: [
                { name: "Burger", price: 9.00 },
                { name: "Small Salad", price: 5.00 }
              ]
            },
            {
              name: "dinner",
              menu_items: [
                { name: "Burger", price: 15.00 },
                { name: "Large Salad", price: 8.00 }
              ]
            }
          ]
        },
        {
          name: "Casa del Poppo",
          menus: [
            {
              name: "lunch",
              dishes: [
                { name: "Chicken Wings", price: 9.00 },
                { name: "Burger", price: 9.00 },
                { name: "Chicken Wings", price: 9.00 }
              ]
            },
            {
              name: "dinner",
              dishes: [
                { name: "Mega \"Burger\"", price: 22.00 },
                { name: "Lobster Mac & Cheese", price: 31.00 }
              ]
            }
          ]
        }
      ]
    }
  end

  describe 'POST /api/v1/json_to_model/convert' do
    it 'returns a successful import report' do
      post '/api/v1/json_to_model/convert',
           params: payload.to_json,
           headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json).to have_key('data')
      expect(json['data']).to include('total', 'success', 'errors', 'details')
    end

    it 'persists all restaurants, menus and menu items' do
      expect {
        post '/api/v1/json_to_model/convert',
             params: payload.to_json,
             headers: headers
      }.to change(Restaurant, :count).by(2)
       .and change(Menu, :count).by(4)
       .and change(MenuItem, :count).by(8)
    end

    it 'normalizes dishes into menu_items' do
      post '/api/v1/json_to_model/convert',
           params: payload.to_json,
           headers: headers

      restaurant = Restaurant.find_by!(name: 'Casa del Poppo')
      lunch_menu = restaurant.menus.find_by!(name: 'lunch')

      expect(lunch_menu.menu_items.count).to eq(2)
      expect(lunch_menu.menu_items.pluck(:name))
        .to include('Chicken Wings', 'Burger')
    end

    it 'returns detailed success logs' do
      post '/api/v1/json_to_model/convert',
           params: payload.to_json,
           headers: headers

      json = JSON.parse(response.body)
      details = json['data']['details']

      expect(details).to all(include('entity', 'attributes', 'status'))
      expect(details.count { |d| d['status'] == 'success' }).to be > 0
    end

    it 'does not raise errors for duplicated menu item names in different menus' do
      expect {
        post '/api/v1/json_to_model/convert',
             params: payload.to_json,
             headers: headers
      }.not_to raise_error
    end
  end
end
