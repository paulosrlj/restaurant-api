class JsonToModel::JsonImporter
  ENTITY_MAP = {
    "restaurants" => Restaurant,
    "restaurant" => Restaurant,
    "menus" => Menu,
    "menu" => Menu,
    "menu_items" => MenuItem,
    "menu_item" => MenuItem
  }.freeze

  def initialize(payload)
    @payload = JsonToModel::Normalizer.call(payload)
    @logs = []
  end

  def call
    Rails.logger.info("Beginning JSON Importer")
    process_entity(@payload)

    report
  end

  private

  def process_entity(hash, parent: nil)
    hash.each do |key, value|
      model = ENTITY_MAP[key]

      unless model
        log_exception(key, {}, StandardError.new("No conversion available for model '#{key}'"))
        next
      end

      # If is an array of entities
      unless value.is_a?(Array)
        log_exception(
          model,
          {},
          StandardError.new("The root key '#{key}' value is not an array")
        )
        next
      end

      value.each { |attrs| create_record(model, attrs, parent) }
    end
  end

  def create_record(model, attrs, parent)
    associations, attributes = split_associations(model, attrs)

    record = parent ? build_with_parent(model, parent, attributes) : model.new(attributes)

    if record.save
      log_success(record, attributes)

      associations.each do |assoc_key, assoc_value|
        process_entity({ assoc_key => assoc_value }, parent: record)
      end
    else
      log_error(record, attributes)
    end

    record
  rescue StandardError => e
    log_exception(model, attributes, e)
    nil
  end

  def split_associations(model, attrs)
    associations = {}
    attributes = {}

    attrs.each do |key, value|
      if model.reflect_on_association(key.to_sym)
        associations[key] = value
      else
        attributes[key] = value
      end
    end

    [ associations, attributes ]
  end

  def build_with_parent(model, parent, attributes)
    association = parent.class.reflect_on_all_associations.find do |a|
      a.klass == model
    end

    raise "No association from #{parent.class} to #{model}" unless association

    parent.public_send(association.name).build(attributes)
  end

  def log_success(record, attributes)
    @logs << {
      id: record.id,
      entity: record.class.name,
      attributes: attributes,
      status: :success
    }
  end

  def log_error(record, attributes)
    @logs << {
      entity: record.class.name,
      attributes: attributes,
      status: :error,
      errors: record.errors.full_messages
    }
  end

  def log_exception(entity, attributes, exception)
    @logs << {
      entity: entity.respond_to?(:name) ? entity.name : entity.to_s,
      attributes: attributes,
      status: :exception,
      error: exception.message
    }
  end

  def report
    {
      total: @logs.size,
      success: @logs.count { |l| l[:status] == :success },
      errors: @logs.count { |l| l[:status] != :success },
      details: @logs
    }
  end
end
