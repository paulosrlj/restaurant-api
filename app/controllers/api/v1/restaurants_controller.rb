class Api::V1::RestaurantsController < ApplicationController
  before_action :set_restaurant, only: %i[ show update destroy ]

  # GET /api/v1/restaurants
  def index
    @restaurants = Restaurant.includes(:menus)

    render_success(data: RestaurantSerializer.collection(@restaurants))
  end

  # GET /api/v1/restaurants/1
  def show
    render_success(data: RestaurantSerializer.new(@restaurant))
  end

  # POST /api/v1/restaurants
  def create
    @restaurant = Restaurant.create!(restaurant_params)

    render_success(data: RestaurantSerializer.new(@restaurant).as_json, status: :created)

  end

  # PATCH/PUT /api/v1/restaurants/1
  def update
     @restaurant.update!(restaurant_params)
     render_success(data: RestaurantSerializer.new(@restaurant), status: :ok)
  end

  # DELETE /api/v1/restaurants/1
  def destroy
    @restaurant.destroy!

    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_restaurant
      @restaurant = Restaurant.includes(:menus).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def restaurant_params
      params.require(:restaurant).permit(:name)
    end
end
