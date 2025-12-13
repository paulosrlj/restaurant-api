class Api::V1::MenuItemsController < ApplicationController
  before_action :set_menu_item, only: %i[ show update destroy ]

  # GET /api/v1/menu_items
  def index
    @menu_items = MenuItem.all

    render_success(data: MenuItemSerializer.collection(@menu_items))
  end

  # GET /api/v1/menu_items/1
  def show
    render_success(data: MenuItemSerializer.new(@menu_item))
  end

  # POST /api/v1/menu_items
  def create
    @menu_item = MenuItem.create!(menu_item_params)

    render_success(
      data: MenuItemSerializer.new(@menu_item).as_json,
      status: :created
    )
  end

  # PATCH/PUT /api/v1/menu_items/1
  def update
    if @menu_item.update(menu_item_params)
      render_success(data: MenuItemSerializer.new(@menu_item))
    else
      render_error(errors: MenuItemSerializer.new(@menu_item).errors.full_messages, status: :unprocessable_entity)
    end
  end

  # DELETE /api/v1/menu_items/1
  def destroy
    @menu_item.destroy!

    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_menu_item
      @menu_item = MenuItem.find(params.fetch(:id))
    end

    # Only allow a list of trusted parameters through.
    def menu_item_params
      params.require(:menu_item).permit(:name, :price, :menu_id)
    end
end
