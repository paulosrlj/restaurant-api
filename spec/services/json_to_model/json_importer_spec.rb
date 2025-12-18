require "rails_helper"

RSpec.describe JsonToModel::JsonImporter do
  subject(:importer) { described_class.new(payload) }

  describe "#call" do
    context "with a valid payload" do
      let(:payload) do
        {
          "restaurants" => [
            {
              "name" => "Poppo's Cafe",
              "menus" => [
                {
                  "name" => "lunch",
                  "menu_items" => [
                    { "name" => "Burger", "price" => 900 }
                  ]
                }
              ]
            }
          ]
        }
      end

      it "creates all records successfully" do
        result = importer.call

        expect(Restaurant.count).to eq(1)
        expect(Menu.count).to eq(1)
        expect(MenuItem.count).to eq(1)

        expect(result[:success]).to eq(3)
        expect(result[:errors]).to eq(0)
      end

      it "returns a detailed report" do
        result = importer.call

        expect(result).to include(:total, :success, :errors, :details)
        expect(result[:details]).to all(include(:entity, :status))
      end
    end

    context "when using alias dishes instead of menu_items" do
      let(:payload) do
        {
          "restaurants" => [
            {
              "name" => "Casa del Poppo",
              "menus" => [
                {
                  "name" => "dinner",
                  "dishes" => [
                    { "name" => "Pasta", "price" => 1200 }
                  ]
                }
              ]
            }
          ]
        }
      end

      it "normalizes and persists menu_items correctly" do
        importer.call

        menu = Menu.last
        expect(menu.menu_items.count).to eq(1)
        expect(menu.menu_items.first.name).to eq("Pasta")
      end
    end

    context "when a record is invalid" do
      let(:payload) do
        {
          "restaurants" => [
            {
              "name" => nil
            }
          ]
        }
      end

      it "logs an error and continues processing" do
        result = importer.call

        expect(Restaurant.count).to eq(0)
        expect(result[:errors]).to eq(1)

        error = result[:details].first
        expect(error[:status]).to eq(:error).or eq(:exception)
      end
    end

    context "when an unknown entity key is provided" do
      let(:payload) do
        {
          "unknowns" => [
            { "name" => "Foo" }
          ]
        }
      end

      it "logs an exception" do
        result = importer.call

        expect(result[:errors]).to eq(1)
        expect(result[:details].first[:status]).to eq(:exception)
      end
    end

    context "when the root value is not an array" do
      let(:payload) do
        {
          "restaurants" => {
            "name" => "Invalid"
          }
        }
      end

      it "logs an exception for invalid root structure" do
        result = importer.call

        expect(result[:errors]).to eq(1)
        expect(result[:details].first[:error])
          .to match(/value is not an array/)
      end
    end

    context "when a child association fails but parent succeeds" do
      let(:payload) do
        {
          "restaurants" => [
            {
              "name" => "Valid Restaurant",
              "menus" => [
                {
                  "name" => nil
                }
              ]
            }
          ]
        }
      end

      it "creates the parent and logs the child error" do
        result = importer.call

        expect(Restaurant.count).to eq(1)
        expect(Menu.count).to eq(0)

        expect(result[:success]).to eq(1)
        expect(result[:errors]).to eq(1)
      end
    end
  end
end
