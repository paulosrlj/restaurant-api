class Api::V1::JsonToModelConverterController < ApplicationController

  def convert
    data = extract_data_from_payload
    result = JsonToModel::JsonImporter.new(data).call

    render_success(data: result, status: :ok)
  end

  private

  def extract_data_from_payload
    if params[:file].present?
      parse_multipart_json
    else
      parse_body_json
    end
  end

  def parse_multipart_json
    file = params.require(:file)

    unless file.content_type == "application/json"
      raise ActionController::BadRequest, "File must be application/json"
    end

    JSON.parse(file.read)
  end

  def parse_body_json
    JSON.parse(request.raw_post)
  end

  def convert_params
    params.require(:file)
  end

end
