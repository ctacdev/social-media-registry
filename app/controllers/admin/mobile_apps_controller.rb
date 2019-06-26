class Admin::MobileAppsController < Admin::AdminController
  helper_method :sort_column, :sort_direction
  respond_to :html, :xml, :json, :csv, :xls
  before_action :set_mobile_app, only: [:show, :edit, :update, :destroy,
    :archive, :publish, :request_archive, :request_publish]
    
  # before_filter :require_admin, only: [:publish]
  # GET /mobile_apps
  # GET /mobile_apps.json
  def index
    if !current_user.admin?
      params[:status] = "Published"
    end
    respond_to do |format|
      format.html { 
        @mobile_apps = MobileApp.where("draft_id IS NULL").includes(:official_tags,:agencies,:users).references(:official_tags,:agencies,:users).uniq
    
        if params[:platform] && params[:platform] != ""
          @mobile_apps= @mobile_apps.joins(:mobile_app_versions).where(mobile_app_versions: {platform: params[:platform]})
        end
        @platform_counts = @mobile_apps.platform_counts
        @mobile_apps = []}
      format.json {
        @total_mobile_apps = MobileApp.where("draft_id IS NULL").count
        @mobile_apps = MobileApp.es_search(params, sort_column, sort_direction)
        @result_count = @mobile_apps.total_count
        @mobile_apps = @mobile_apps.page(current_page).per(params["iDisplayLength"].to_i).results
      }
      format.csv { 
        @total_mobile_apps = MobileApp.where("draft_id IS NULL").count
        @mobile_apps = MobileApp.es_search(params, sort_column, sort_direction)
        @result_count = @mobile_apps.total_count
        @mobile_apps = @mobile_apps.page(current_page).per(params["iDisplayLength"].to_i).results
        send_data @mobile_apps.to_csv
      }
    end
  end

  def mobile_apps_export
    @mobile_apps = MobileApp.where("id in (?)", params[:ids].split(",")).includes(:official_tags,:users,:agencies,:mobile_app_versions)
     respond_to do |format|
      format.csv { send_data @mobile_apps.to_csv }
    end
  end

  def datatables
    @mobile_apps = MobileApp.where("draft_id IS NULL").uniq
    respond_to do |format|
      format.json {
        render json: {
          data: @mobile_apps
        }
      }
    end
  end
  # GET /mobile_apps/1
  # GET /mobile_apps/1.json
 # def show
  #end

  # GET /mobile_apps/new
  def new
    @mobile_app = MobileApp.new
    @mobile_app.language = "English"
    if current_user.agency
      @mobile_app.agencies << current_user.agency
    end
    @mobile_app.users << current_user
    @mobile_app.mobile_app_versions.build
  end

  # GET /mobile_apps/1/edit
  def edit
    if @mobile_app.mobile_app_versions.count == 0
      @mobile_app.mobile_app_versions.build
    end
  end

  def show

  end

  # POST /mobile_apps
  # POST /mobile_apps.json
  def create
    @mobile_app = MobileApp.new(mobile_app_params)

    respond_to do |format|
      if @mobile_app.save
        @mobile_app.build_notifications(:created)
        # @mobile_app.published!
        format.html { redirect_to admin_mobile_app_path(@mobile_app), notice: "Mobile Product was successfully created. Please review and click 'Publish' to publish this mobile product to the API." }
        format.json { render :show, status: :created, location: @mobile_app }
      else
        if @mobile_app.mobile_app_versions.empty?
          @mobile_app.mobile_app_versions.build
        end
        format.html { render :new }
        format.json { render json: @mobile_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mobile_apps/1
  # PATCH/PUT /mobile_apps/1.json
  def update
    respond_to do |format|
      if @mobile_app.update(mobile_app_params)
        @mobile_app.touch
        # if @mobile_app.published?
        #   @mobile_app.published!
        # end
        @mobile_app.build_notifications(:updated)
        format.html { redirect_to admin_mobile_app_path(@mobile_app), notice: "Mobile Product was successfully updated. Please review and click 'Publish' to publish these updates to the API." }
        format.json { render :show, status: :ok, location: admin_mobile_app_path(@mobile_app) }
      else
        format.html { render :edit }
        format.json { render json: @mobile_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mobile_apps/1
  # DELETE /mobile_apps/1.json
  def destroy
    @mobile_app.destroy!
    respond_to do |format|
      format.html { redirect_to admin_mobile_apps_url, notice: 'Mobile Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def activities
    @activities = PublicActivity::Activity.where(trackable_type: "MobileApp").order("created_at desc").page(params[:page]).per(25)
  end

  def publish
    @mobile_app.touch
    @mobile_app.published!
    @mobile_app.build_notifications(:published)
    redirect_to admin_mobile_app_path(@mobile_app), :notice => "Mobile App: #{@mobile_app.name}, is now published. #{view_context.link_to 'Undo', archive_admin_mobile_app_path(@mobile_app)}".html_safe

  end

  def archive
    @mobile_app.touch
    @mobile_app.archived!
    @mobile_app.build_notifications(:archived)
    redirect_to admin_mobile_app_path(@mobile_app), :notice => "Mobile App: #{@mobile_app.name}, is now archived. #{view_context.link_to 'Undo', publish_admin_mobile_app_path(@mobile_app)}".html_safe
  end

  def request_publish
    @mobile_app.publish_requested!
    @mobile_app.build_notifications(:publish_requested)
    redirect_to admin_mobile_app_path(@mobile_app), :notice => "Mobile App: #{@mobile_app.name}, has a request in with admins to be published."
  end

  def request_archive
    @mobile_app.archive_requested!
    @mobile_app.build_notifications(:archive_requested)
    redirect_to admin_mobile_app_path(@mobile_app), :notice => "Mobile App: #{@mobile_app.name}, has a request in with admins to be archived."
  end

  def version_details_for_url
    @details_object = AppStore.find_details_by_url(params[:store_url])
    respond_to do |format|
      format.json { render json: @details_object }
    end
  end

   private
    # Use callbacks to share common setup or constraints between actions.
    def set_mobile_app
      @mobile_app = MobileApp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mobile_app_params
      params.require(:mobile_app).permit(:name, :short_description, :long_description, :icon_url,
        :language, :agency_tokens, :user_tokens, :tag_tokens, :primary_contact_id, :secondary_contact_id, :primary_agency_id, :secondary_agency_id, :notes, mobile_app_versions_attributes: [:id, :store_url,:platform,
        :version_number,:publish_date,:description,:whats_new,:screenshot,:device,
        :language,:average_rating,:number_of_ratings, :_destroy])
    end

    def current_page
      return 0 if params["iDisplayStart"].to_i == 0
      params["iDisplayStart"].to_i / params["iDisplayLength"].to_i + 1
    end

    def sort_column
      columns = {
        "0" => "agencies",
        "1" => "contacts",
        "2" => "name",
        "3" => "updated_at",
        "4" => "status"
      }
      params["iSortCol_0"] ? columns[params["iSortCol_0"]] : "updated_at"
    end

    def sort_direction
      %w[asc desc].include?(params["sSortDir_0"]) ? params["sSortDir_0"] : "desc"
    end

    def items_per_page_handler
      per_page_count = 10 || params["iDisplayLength"].to_i
      return per_page_count.to_i
    end

    def get_tag(tag_id)
      !tag_id.nil? ? OfficialTag.find_by(id: tag_id) : nil
    end

    def tag_text(tag)
      !tag.nil? ? tag.tag_text : nil
    end
end
