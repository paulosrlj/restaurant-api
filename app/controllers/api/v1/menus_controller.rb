class Api::V1::MenusController < ApplicationController
  before_action :set_menu, only: %i[ show update destroy ]

  # GET /menus
  def index
    @menus = Menu.all

    render_success(data: @menus)
  end

  # GET /menus/1
  def show
    render_success(data: @menu)
  end

  # POST /menus
  def create
    @menu = Menu.new(menu_params)

    if @menu.save
      render_success(data: @menu, status: :created)
    else
      render_error(errors: @menu.errors.full_messages, status: :unprocessable_entity)
    end
  end

  # PATCH/PUT /menus/1
  def update
    if @menu.update(menu_params)
      render_success(data: @menu, status: :ok)
    else
      render_error(errors: @menu.errors.full_messages, status: :unprocessable_entity)
    end
  end

  # DELETE /menus/1
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
      params.require(:menu).permit(:name)
    end
end
