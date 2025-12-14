class Api::V1::MenusController < ApplicationController
  before_action :set_menu, only: %i[ show update destroy ]

  # GET /api/v1/menus
  def index
    @pagy, @menus = pagy(:offset, Menu.all)

    render_success(data: MenuSerializer.collection(@menus))
  end

  # GET /api/v1/menus/1
  def show
    render_success(data: MenuSerializer.new(@menu), status: :ok)
  end

  # POST /api/v1/menus
  def create
    @menu = Menu.create!(menu_params)

    render_success(data: MenuSerializer.new(@menu), status: :created)
  end

  # PATCH/PUT /api/v1/menus/1
  def update
    @menu.update!(menu_params)
    render_success(data: MenuSerializer.new(@menu), status: :ok)
  end

  # DELETE /api/v1/menus/1
  def destroy
    @menu.destroy!

    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_menu
      @menu = Menu.find(params.fetch(:id))
    end

    # Only allow a list of trusted parameters through.
    def menu_params
      params.require(:menu).permit(:name, :restaurant_id, menu_items_attributes: [ :name, :price ])
    end
end
