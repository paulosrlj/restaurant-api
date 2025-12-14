class ApplicationController < ActionController::API
  include Pagy::Method

  rescue_from StandardError, with: :render_internal_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActiveRecord::RecordNotUnique, with: :render_conflict_error

  private

  def render_success(data:, status: :ok)
    render json: {
      data: data
    }, status: status
  end

  def render_error(errors:, status:)
    render json: {
      errors: Array(errors)
    }, status: status
  end

  def render_not_found(error)
    render_error(errors: error.message, status: :not_found)
  end

  def render_unprocessable_entity(error)
    Rails.logger.error(error)
    render_error(errors: error.record.errors.full_messages, status: :unprocessable_entity)
  end

  def render_internal_server_error(error)
    Rails.logger.error(error)
    render_error(errors: error.message, status: :internal_server_error)
  end

  def render_conflict_error(error)
    Rails.logger.error(error)

    message =
      if error.cause.is_a?(SQLite3::ConstraintException)
        humanize_sqlite_unique_error(error.cause.message)
      else
        "Resource already exists"
      end

    render_error(errors: message, status: :conflict)
  end

  def humanize_sqlite_unique_error(message)
    if message.include?("menu_items.name, menu_items.menu_id")
      "Menu item name must be unique within the menu"
    else
      "Duplicate resource"
    end
  end
end
