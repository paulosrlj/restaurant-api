# frozen_string_literal: true

class JsonToModel::Normalizer
  ALIASES = {
    "dishes" => "menu_items"
  }.freeze

  def self.call(payload)
    payload.deep_dup.tap { |data| normalize!(data) }
  end

  def self.normalize!(node)
    case node
    when Hash
      normalize_aliases!(node)
      node.each_value { |v| normalize!(v) }

    when Array
      node.each { |v| normalize!(v) }

    # Primitive value, no need for treatment
    else
      nil
    end
  end

  def self.normalize_aliases!(hash)
    ALIASES.each do |key, value|
      next unless hash.key?(key)

      if hash.key?(value)
        hash[value] = Array(hash[value]).concat(Array(hash[key]))
        hash.delete(key)
      else
        hash[value] = hash.delete(key)
      end
    end
  end
end


