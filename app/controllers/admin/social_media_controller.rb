class Admin::SocialMediaController < Admin::AdminController
  helper_method :sort_column, :sort_direction, :current_page
  respond_to :html, :xml, :json, :csv, :xls

  before_action :set_outlet, only: [:show, :edit, :update, :destroy,
    :publish, :archive, :request_publish, :request_archive]

  # before_filter :require_admin, only: [:publish]
  # GET /outlets
  # GET /outlets.json
  def index
    if !current_user.admin?
      params[:status] = "Published"
    end
    respond_to do |format|
      format.html { 
        @outlets = Outlet.includes(:official_tags,:agencies,:users).references(:official_tags,:agencies,:users).where("draft_id IS NULL")
        num_items = items_per_page_handler
        @total_outlets = @outlets.count
        if(params[:service] && !params[:service].blank?)
          @outlets = @outlets.where(service: params[:service])
        end
        @services = @outlets.group(:service).count
        @outlets = [] }
      format.json {
        @total_outlets = Outlet.where("draft_id IS NULL").count
        @outlets = Outlet.es_search(params, sort_column, sort_direction)
        @result_count = @outlets.total_count
        @outlets = @outlets.page(current_page).per(params["iDisplayLength"].to_i).results
      }
      format.csv { 
        @outlets = Outlet.es_search(params, sort_column, sort_direction)
        @result_count = @outlets.total_count
        @outlets = @outlets.results
        send_data @outlets.to_csv 
      }
    end
  end

  def social_media_export
    if !params[:agency].blank?
      @outlets = Outlet.es_search(params, sort_column, sort_direction).per(1000).records
    else
      @outlets = Outlet.es_search(params, sort_column, sort_direction).per(1000).records
    end
    respond_to do |format|
      format.html { send_data @outlets.to_csv }
      format.csv { send_data @outlets.to_csv }
    end
  end

  def datatables
    @outlets = Outlet.where("draft_id IS NULL").uniq
    respond_to do |format|
      format.json {
        render json: {
          data: @outlets
        }
      }
    end
  end

  def account_for_url
    service = Admin::Service.find_by_url(params[:url])
    account = { account: "", service: ""}
    if service
      account = { account: service.account,
        service: service.shortname }
    end
    render json: account
  end
  # GET /outlets/1
  # GET /outlets/1.json

  # GET /outlets/new
  def new
    @outlet = Outlet.new
    @outlet.language = "English"
    if current_user.agency
      @outlet.primary_agency_id = current_user.agency.id 
    end
    @outlet.primary_contact_id = current_user.id
  end

  # GET /outlets/1/edit
  def edit
    if @outlet.agencies.count == 0
      @outlet.agences << current_user.agency
    end
  end

  def show
  end


  # POST /outlets
  # POST /outlets.json
  def create
    @outlet = Outlet.new(outlet_params)
    @outlet.status = Outlet.statuses[:published]
    respond_to do |format|
      if @outlet.save
        @outlet.published!
        # @outlet.build_notifications(:created) #may want to remove
        format.html { redirect_to admin_outlet_path(@outlet), notice: "Social Media Account was successfully created and published." }
        format.json { render :show, status: :created, location: @outlet }
      else
        format.html { render :new }
        format.json { render json: @outlet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /outlets/1
  # PATCH/PUT /outlets/1.json
  def update
    respond_to do |format|
      if @outlet.update(outlet_params)
        @outlet.touch
        if @outlet.published?
          @outlet.published!
        end
        # @outlet.build_notifications(:updated) #may want to remove
        format.html { redirect_to admin_outlet_path(@outlet), notice: "Social Media Account was successfully updated." }
        format.json { render :show, status: :ok, location: admin_outlet_path(@outlet) }
      else
        format.html { render :edit }
        format.json { render json: @outlet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /outlets/1
  # DELETE /outlets/1.json
  def destroy
    @outlet.destroy!
    respond_to do |format|
      format.html { redirect_to admin_outlets_url, notice: 'Social Media Account was successfully destroyed.' }
      format.json { head :no_content }
    end
    redirect_to action: :index
  end

  def activities
    @activities = PublicActivity::Activity.where(trackable_type: "Outlet").order("created_at desc").page(params[:page]).per(25)
  end

  def publish
    @outlet.touch
    @outlet.published!
    @outlet.build_notifications(:published)
    redirect_to admin_outlet_path(@outlet), :notice => "Social Media Account: #{@outlet.organization}, is now published. #{view_context.link_to 'Undo', archive_admin_outlet_path(@outlet)}".html_safe
  end

  def archive
    @outlet.touch
    @outlet.archived!
    @outlet.build_notifications(:archived)
    redirect_to admin_outlet_path(@outlet), :notice => "Social Media Account: #{@outlet.organization}, is now archived. #{view_context.link_to 'Undo', publish_admin_outlet_path(@outlet)}".html_safe
  end

  def request_publish
    @outlet.publish_requested!
    # @outlet.build_notifications(:publish_requested)
    redirect_to admin_outlet_path(@outlet), :notice => "Social Media Account: #{@outlet.organization}, has a request in with admins to be published."
  end

  def request_archive
    @outlet.archive_requested!
    # @outlet.build_notifications(:archive_requested)
    redirect_to admin_outlet_path(@outlet), :notice => "Social Media Account: #{@outlet.organization}, has a request in with admins to be archived."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_outlet
      @outlet = Outlet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def outlet_params
      params.require(:outlet).permit(:organization, :service_url, :location, :location_id, :status,
        :account, :service, :language, :agency_tokens, :user_tokens, :tag_tokens,
        :short_description, :long_description, :primary_contact_id, :secondary_contact_id, :primary_agency_id, :secondary_agency_id, :notes)
    end

    def current_page
      return 0 if params["iDisplayStart"].to_i == 0
      params["iDisplayStart"].to_i / params["iDisplayLength"].to_i + 1
    end
    
    def sort_column
      columns = {
        "0" => "agencies",
        "1" => "contacts",
        "2" => "service",
        "3" => "account_name",
        "4" => "account",
        "5" => "updated_at",
        "6" => "status"
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
