class Api::V1::MenuItemsController < ApplicationController
  before_action :set_menu_item, only: %i[ show update destroy ]

  # GET /menu_items
  def index
    @menu_items = MenuItem.all

    render_success(data: @menu_items)
  end

  # GET /menu_items/1
  def show
    render_success(data: @menu_item)
  end

  # POST /menu_items
  def create
    @menu_item = MenuItem.new(menu_item_params)

    if @menu_item.save
      render_success(data: @menu_item, status: :created)
    else
      render_error(errors: @menu_item.errors.full_messages, status: :unprocessable_entity)
    end
  end

  # PATCH/PUT /menu_items/1
  def update
    if @menu_item.update(menu_item_params)
      render_success(data: @menu_item)
    else
      render_error(errors: @menu_item.errors.full_messages, status: :unprocessable_entity)
    end
  end

  # DELETE /menu_items/1
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
