class ResourceType < Base
  attr_reader :id, :title, :updated, :cache_key

  def initialize(attributes, options={})
    @id = attributes.fetch("id").underscore.dasherize
    @title = attributes.fetch("title", nil)
    @updated = DATACITE_SCHEMA_DATE + "T00:00:00Z"
    @cache_key = "resource-type/#{@id}-#{@updated}"
  end

  def self.get_query_url(options={})
    RESOURCE_TYPES_URL
  end

  def self.parse_data(result, options={})
    return nil if result.body.blank? || result.body['errors']

    items = result.body.fetch("data", {}).fetch("schema", {}).fetch("simpleType", {}).fetch('restriction', {}).fetch('enumeration', [])
    items = items.map do |item|
      id = item.fetch("value").underscore.dasherize

      { "id" => id, "title" => id.underscore.humanize }
    end

    if options[:id]
      item = items.find { |i| i["id"] == options[:id] }
      return nil if item.nil?

      { data: parse_item(item) }
    else
      { data: parse_items(items), meta: { total: items.length } }
    end
  end
end
