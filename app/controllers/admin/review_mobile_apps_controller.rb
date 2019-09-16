class Admin::ReviewMobileAppsController < Admin::AdminController
  helper_method :sort_column, :sort_direction, :current_page
  respond_to :html, :xml, :json, :csv, :xls

  before_action :set_mobile_app, only: [:validate, :archive, :publish]

  # before_filter :require_admin, only: [:publish]
  # GET /mobile_apps
  # GET /mobile_apps.json
  def index
    if params[:status] == "archived"
      @mobile_apps = MobileApp.joins(:users).where("users.email = ?", current_user.email).where("mobile_apps.status" => 2).order("mobile_apps.validated_at ASC").page(current_page).per(10)
    elsif params[:status] == "published"
      if params[:review] == "needs"
        @mobile_apps = MobileApp.joins(:users).where("users.email = ?", current_user.email).where("mobile_apps.status" => 1).where("mobile_apps.validated_at <= ?",180.days.ago).order("mobile_apps.validated_at ASC").page(current_page).per(10)
      else
        @mobile_apps = MobileApp.joins(:users).where("users.email = ?", current_user.email).where("mobile_apps.status" => 1).order("mobile_apps.validated_at ASC").page(current_page).per(10)
      end
    else
      @mobile_apps = MobileApp.joins(:users).where("users.email = ?", current_user.email).order("mobile_apps.validated_at ASC").page(current_page).per(10)
    
    end
    
  end

  def publish
    @mobile_app.published!
    @mobile_app.validated_at = Time.now
    @mobile_app.save(validate: false)
    redirect_to admin_mobile_app_path(@mobile_app), :notice => "Mobile App: #{@mobile_app.name}, is now published. #{view_context.link_to 'Undo', archive_admin_mobile_app_path(@mobile_app)}".html_safe
  end
  
  def validate
    @mobile_app.validated_at = Time.now
    @mobile_app.save(validate: false)
    @mobile_app.create_activity :certified
    redirect_to admin_mobile_app_path(@mobile_app), :notice => "Mobile App: #{@mobile_app.name}, is now certified.".html_safe
  end

  def archive
    @mobile_app.touch
    @mobile_app.archived!
    # @mobile_app.build_notifications(:archived)
    redirect_to admin_mobile_app_path(@mobile_app), :notice => "Mobile App: #{@mobile_app.name}, is now archived. #{view_context.link_to 'Undo', publish_admin_mobile_app_path(@mobile_app)}".html_safe
  end

  private
    
  def set_mobile_app
    @mobile_app = MobileApp.find(params[:id])
  end

  def current_page
    if params[:page]
      return params[:page].to_i
    else
      return 1
    end
  end
end