class Admin::OfficialTagsController < Admin::AdminController
  helper_method :sort_column, :sort_direction
  respond_to :html, :xml, :json, :csv, :xls
  before_action :set_tag, only: [:edit, :show, :update, :destroy]

  before_action :require_admin, except: [:tokeninput]
  before_action :admin_two_factor, except: [:tokeninput]
  # GET /tags
  # GET /tags.json
  def index
    if params[:type] && params[:type] != ""
      @official_tags = OfficialTag.where(tag_type: params[:type])
    else
      @official_tags = OfficialTag.all
    end
    num_items = items_per_page_handler
    @total_tags = OfficialTag.all.count
    @types = OfficialTag.group(:tag_type).count
    @official_tags = @official_tags
     respond_to do |format|
      format.html {  @official_tags = [] }
      format.json { render "index" }
    end
  end

  # GET /tags/1
  # GET /tags/1.json

  # GET /tags/new
  def new
    @official_tag = OfficialTag.new
  end

  # GET /tags/1/edit
  def edit
  end

  def show
    if @official_tag
      @official_tag = OfficialTag.where(:id=> @official_tag.id).includes(:outlets,:mobile_apps,:galleries).first
    end
  end


  # POST /tags
  # POST /tags.json
  def create
    @official_tag = OfficialTag.new(tag_params)

    respond_to do |format|
      if @official_tag.save
        format.html { redirect_to admin_official_tag_path(@official_tag), notice: 'tag was successfully created.' }
        format.json { render :show, status: :created, location: @official_tag }
      else
        format.html { render :new }
        format.json { render json: @official_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
      if @official_tag.update(tag_params)
        format.html { redirect_to admin_official_tag_path(@official_tag), notice: 'tag was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_tag_path(@official_tag) }
      else
        format.html { render :edit }
        format.json { render json: @official_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @official_tag.destroy
    respond_to do |format|
      format.html { redirect_to admin_official_tags_path, notice: 'tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def tokeninput
    @official_tags = OfficialTag.where("tag_Text LIKE ?", "%#{params[:q]}%")
    @official_tags << OfficialTag.new(tag_text: params[:q]) if !@official_tags.any? {|tag| tag.tag_text == params[:q]}
    respond_to do |format|
      format.json { render 'tokeninput'}
    end
  end

   private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @official_tag = OfficialTag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:official_tag).permit(:id, :tag_text, :tag_type)
    end

    def sort_column
      OfficialTag.column_names.include?(params[:sort]) ? params[:sort] : "tag_text"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def items_per_page_handler
      per_page_count = 25
      if cookies[:per_page_count_tags]
        per_page_count = cookies[:per_page_count_tags]
      end
      if params[:per_page]
        per_page_count = params[:per_page]
        cookies[:per_page_count_tags] = per_page_count
      end
      return per_page_count.to_i
    end

end
