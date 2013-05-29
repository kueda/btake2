class PhotosController < ApplicationController
  before_filter :load_photo, :only => [:show, :edit, :update, :destroy]
  # GET /photos
  # GET /photos.json
  FILTERS = %w(state_province county genus scientific_name authors remote_id collection_code source min_date max_date page per_page)
  def index
    bee_params = {:per_page => 200}
    FILTERS.each do |a|
      instance_variable_set("@#{a}", params[a])
      bee_params[a] = params[a] unless params[a].blank?
    end

    r = Bee.photos(bee_params)
    @photos = Photo.from_features(r['features'])
    Rails.logger.debug "[DEBUG] @photos.size: #{@photos.size}"
    Rails.logger.debug "[DEBUG] @photos.first: #{@photos.first}"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @photos.as_json(:methods => Photo::FIELDS) }
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo.as_json(:methods => Photo::FIELDS) }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.new(params[:photo])

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
        format.json { render json: @photo, status: :created, location: @photo }
      else
        format.html { render action: "new" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to photos_url }
      format.json { head :no_content }
    end
  end

  private
  def load_photo
    @photo = if params[:id].to_i == 0
      Photo.find_by_bee_record(params[:id])
    else
      Photo.find_by_id(params[:id])
    end
    if @photo && @photo.response.blank? && @photo.bee_id
      @photo.update_with_api_response(Bee.photo(@photo.bee_id))
    end
    render(:status => 404) unless @photo
  end
end
