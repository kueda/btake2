class Photo < ActiveRecord::Base
  attr_accessor :response

  BEE_FIELDS = %w(authors locality county photog_notes url begin_date end_date record remote_resource collection_code media_url)
  FIELDS = BEE_FIELDS + %w(latitude longitude response)

  def latitude
    return nil unless response
    response['geometry']['coordinates'].last
  end

  def longitude
    return nil unless response
    response['geometry']['coordinates'].first
  end

  def method_missing(method, *args)
    return nil unless response
    response['properties'][method.to_s]
  rescue => e
    Rails.logger.debug "[DEBUG] e: #{e}"
    super
  end

  def self.from_features(features)
    features.map do |feature|
      new_from_api_response(feature)
    end
  end

  def self.new_from_api_response(response)
    new(:response => response)
  end

  def self.find_by_bee_record(id)
    p = Photo.find_by_bee_id(id)
    p ||= Photo.new_from_api_response(Bee.photo(id))
  end
end
