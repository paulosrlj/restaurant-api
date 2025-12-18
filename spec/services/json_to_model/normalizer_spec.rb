require "rails_helper"

RSpec.describe JsonToModel::Normalizer do
  describe ".call" do
    let(:payload) do
      {
        "restaurants" => [
          {
            "name" => "Poppo's Cafe",
            "menus" => [
              {
                "name" => "lunch",
                "dishes" => [
                  { "name" => "Burger", "price" => 9.0 }
                ]
              }
            ]
          }
        ]
      }
    end

    it "normalizes aliases recursively" do
      result = described_class.call(payload)

      menu = result["restaurants"].first["menus"].first

      expect(menu).to have_key("menu_items")
      expect(menu).not_to have_key("dishes")
      expect(menu["menu_items"]).to eq([ { "name" => "Burger", "price" => 9.0 } ])
    end

    it "does not mutate the original payload" do
      described_class.call(payload)

      original_menu = payload["restaurants"].first["menus"].first

      expect(original_menu).to have_key("dishes")
      expect(original_menu).not_to have_key("menu_items")
    end
  end

  describe ".normalize!" do
    it "handles deeply nested arrays and hashes" do
      data = {
        "menus" => [
          {
            "dishes" => [
              { "name" => "Pizza", "price" => 12 }
            ]
          }
        ]
      }

      described_class.normalize!(data)

      expect(data["menus"].first).to have_key("menu_items")
      expect(data["menus"].first["menu_items"].first["name"]).to eq("Pizza")
    end

    it "ignores primitive values without raising errors" do
      expect do
        described_class.normalize!("string")
        described_class.normalize!(123)
        described_class.normalize!(true)
        described_class.normalize!(nil)
      end.not_to raise_error
    end
  end

  describe ".normalize_aliases!" do
    it "replaces alias keys with model correct keys" do
      hash = {
        "dishes" => [ { "name" => "Salad" } ]
      }

      described_class.normalize_aliases!(hash)

      expect(hash).to eq("menu_items" => [ { "name" => "Salad" } ])
    end

    it "does not override menu_items if it already exists" do
      hash = {
        "menu_items" => [ { "name" => "Burger" } ],
        "dishes" => [ { "name" => "Salad" } ]
      }

      described_class.normalize_aliases!(hash)

      expect(hash["menu_items"]).to eq([ { "name" => "Burger" }, { "name" => "Salad" } ])
      expect(hash).not_to have_key("dishes")
    end

    it "does nothing if alias key does not exist" do
      hash = { "name" => "Lunch Menu" }

      expect {
        described_class.normalize_aliases!(hash)
      }.not_to change { hash }
    end
  end
end
