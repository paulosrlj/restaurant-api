class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from StandardError, with: :render_internal_server_error

  private

  def render_success(data:, status: :ok)
    render json: {
      status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
      data: data
    }, status: status
  end

  def render_error(errors:, status:)
    render json: {
      status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
      errors: Array(errors)
    }, status: status
  end

  def render_not_found(error)
    render_error(errors: error.message, status: :not_found)
  end

  def render_unprocessable_entity(error)
    render_error(errors: error.record.errors.full_messages, status: :unprocessable_entity)
  end

  def render_internal_server_error(error)
    render_error(errors: error.message, status: :internal_server_error)
  end
end
