class RelationType < Base
  attr_reader :id, :title, :inverse_title, :updated_at

  def initialize(attributes, options={})
    @id = attributes.fetch("id").underscore.dasherize
    @title = attributes.fetch("title", nil)
    @inverse_title = attributes.fetch("inverse_title", nil)
    @updated_at = attributes.fetch("timestamp", nil)
  end

  def self.get_query_url(options={})
    if options[:id].present?
      id = options[:id].underscore
      "#{url}/#{id}"
    else
      url
    end
  end

  def self.get_data(options={})
    [{
      "id"=> "bookmarks",
      "title"=> "Bookmarks",
      "inverse_title"=> "Is bookmarked by",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "cites",
      "title"=> "Cites",
      "inverse_title"=> "Is cited by",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "compiles",
      "title"=> "Compiles",
      "inverse_title"=> "Is compiled by",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "continues",
      "title"=> "Continues",
      "inverse_title"=> "Is continued by",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "corrects",
      "title"=> "Corrects",
      "inverse_title"=> "Is corrected by",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "discusses",
      "title"=> "Discusses",
      "inverse_title"=> "Is discussed by",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "documents",
      "title"=> "Documents",
      "inverse_title"=> "Is documented by",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "downloads",
      "title"=> "Downloads",
      "inverse_title"=> "Is downloaded by",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "has_metadata",
      "title"=> "Has metadata",
      "inverse_title"=> "Is metadata for",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "has_part",
      "title"=> "Has part",
      "inverse_title"=> "Is part of",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_bookmarked_by",
      "title"=> "Is Bookmarked by",
      "inverse_title"=> "Bookmarks",
      "timestamp"=> "2016-04-08T12:43:04Z"
    },
    {
      "id"=> "is_cited_by",
      "title"=> "Is cited by",
      "inverse_title"=> "Cites",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_compiled_by",
      "title"=> "Is compiled by",
      "inverse_title"=> "Compiles",
      "timestamp"=> "2016-03-22T17:41:55Z"
    },
    {
      "id"=> "is_continued_by",
      "title"=> "Is continued by",
      "inverse_title"=> "Continues",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_corrected_by",
      "title"=> "Is corrected by",
      "inverse_title"=> "Corrects",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_derived_from",
      "title"=> "Is derived from",
      "inverse_title"=> "Is source of",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_discussed_by",
      "title"=> "Is discussed by",
      "inverse_title"=> "Discusses",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_documented_by",
      "title"=> "Is documented by",
      "inverse_title"=> "Documents",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_downloaded_by",
      "title"=> "Is downloaded by",
      "inverse_title"=> "Downloads",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_identical_to",
      "title"=> "Is identical to",
      "inverse_title"=> "Is identical to",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_liked_by",
      "title"=> "Is Liked by",
      "inverse_title"=> "Likes",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_metadata_for",
      "title"=> "Is metadata for",
      "inverse_title"=> "Has metadata",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_new_version_of",
      "title"=> "Is new version of",
      "inverse_title"=> "Is previous version of",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_original_form_of",
      "title"=> "Is original form of",
      "inverse_title"=> "Is variant form of",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_part_of",
      "title"=> "Is part of",
      "inverse_title"=> "Has part",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_previous_version_of",
      "title"=> "Is previous version of",
      "inverse_title"=> "Is new version of",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_recommended_by",
      "title"=> "Is recommended by",
      "inverse_title"=> "Recommends",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_referenced_by",
      "title"=> "Is referenced by",
      "inverse_title"=> "References",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_reviewed_by",
      "title"=> "Is reviewed by",
      "inverse_title"=> "reviews",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_source_of",
      "title"=> "Is source of",
      "inverse_title"=> "Is derived from",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_supplement_to",
      "title"=> "Is supplement to",
      "inverse_title"=> "Is supplemented by",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_supplemented_by",
      "title"=> "Is supplemented by",
      "inverse_title"=> "Is supplement to",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "is_variant_form_of",
      "title"=> "Is variant form of",
      "inverse_title"=> "Is original form of",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "is_viewed_by",
      "title"=> "Is viewed by",
      "inverse_title"=> "Views",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "likes",
      "title"=> "Likes",
      "inverse_title"=> "Is Liked by",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "recommends",
      "title"=> "Recommends",
      "inverse_title"=> "Is recommended by",
      "timestamp"=> "2016-03-21T15:05:04Z"
    },
    {
      "id"=> "references",
      "title"=> "References",
      "inverse_title"=> "Is referenced by",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "reviews",
      "title"=> "Reviews",
      "inverse_title"=> "Is reviewed by",
      "timestamp"=> "2016-03-21T15:05:03Z"
    },
    {
      "id"=> "views",
      "title"=> "Views",
      "inverse_title"=> "Is viewed by",
      "timestamp"=> "2016-03-21T15:05:04Z"
    }]
  end

  def self.parse_data(items, options={})
    if options[:id]
      item = items.find { |i| i["id"] == options[:id] }
      return nil if item.nil?

      { data: parse_item(item) }
    else
      { data: parse_items(items), meta: { total: items.length } }
    end
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/relation_types"
  end
end
