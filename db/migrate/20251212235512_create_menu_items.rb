class CreateMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items do |t|
      t.string :name, null: false
      t.integer :price, null: false

      t.belongs_to :menu, null: false

      t.timestamps
    end

    add_index :menu_items, [ :name, :menu_id ], unique: true
  end
end
