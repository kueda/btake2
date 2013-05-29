class Photo < ActiveRecord::Base
  opinio_subjectum
  attr_accessor :response

  BEE_FIELDS = %w(authors locality county photog_notes url begin_date end_date record remote_resource collection_code media_url)
  FIELDS = BEE_FIELDS + %w(latitude longitude response)

  def latitude
    return nil unless response
    response['geometry']['coordinates'].last if response['geometry']
  end

  def longitude
    return nil unless response
    response['geometry']['coordinates'].first if response['geometry']
  end

  def method_missing(method, *args)
    return nil unless response
    response['properties'][method.to_s]
  rescue => e
    if FIELDS.include?(method.to_s)
      Rails.logger.debug "[DEBUG] e: #{e}"
    else
      raise e
    end
  end

  def update_with_api_response(response)
    self.bee_id = response['properties']['record']
    save!
    self.response = response
    self
  end

  def self.from_features(features)
    bee_ids = features.map{|f| f['properties']['record']}
    existing = Photo.where("bee_id IN (?)", bee_ids)
    existing_by_bee_id = existing.index_by(&:bee_id)
    features.map do |feature|
      bee_id = feature['properties']['record']
      if existing_photo = existing_by_bee_id[bee_id]
        existing_photo.update_with_api_response(feature)
        existing_photo
      else
        create_from_api_response(feature)
      end
    end
  end

  def self.create_from_api_response(response)
    p = new_from_api_response(response)
    p.save
    p
  end

  def self.new_from_api_response(response)
    new(:response => response, :bee_id => response['properties']['record'])
  end

  def self.find_by_bee_record(id)
    p = Photo.find_by_bee_id(id)
    p ||= Photo.new_from_api_response(Bee.photo(id))
    if p && p.response.blank? && p.bee_id
      p.update_with_api_response(Bee.photo(p.bee_id))
    end
  end
end
