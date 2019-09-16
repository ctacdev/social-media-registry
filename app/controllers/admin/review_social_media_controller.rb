class Admin::ReviewSocialMediaController < Admin::AdminController
  helper_method :sort_column, :sort_direction, :current_page
  respond_to :html, :xml, :json, :csv, :xls

  before_action :set_outlet, only: [:validate, :archive, :publish]

  # before_filter :require_admin, only: [:publish]
  # GET /outlets
  # GET /outlets.json
  def index
    if params[:status] == "archived"
      @outlets = Outlet.joins(:users).where("users.email = ?", current_user.email).where("outlets.status" => 2).order("outlets.validated_at ASC").page(current_page).per(10)
    elsif params[:status] == "published"
      if params[:review] == "needs"
        @outlets = Outlet.joins(:users).where("users.email = ?", current_user.email).where( "outlets.status" => 1).where("outlets.validated_at <= ?",180.days.ago).order("outlets.validated_at ASC").page(current_page).per(10)
      else
        @outlets = Outlet.joins(:users).where("users.email = ?", current_user.email).where("outlets.status" => 1).order("outlets.validated_at ASC").page(current_page).per(10)
      end
    else
      @outlets = Outlet.joins(:users).where("users.email = ?", current_user.email).order("outlets.validated_at ASC").page(current_page).per(10)
    
    end
    
  end

  def publish
    @outlet.published!
    @outlet.validated_at = Time.now
    @outlet.save(validate: false)
    redirect_to admin_outlet_path(@outlet), :notice => "Social Media Account: #{@outlet.organization}, is now published. #{view_context.link_to 'Undo', archive_admin_outlet_path(@outlet)}".html_safe
  end
  
  def validate
    @outlet.validated_at = Time.now
    @outlet.save(validate: false)
    @outlet.create_activity :certified
    redirect_to admin_outlet_path(@outlet), :notice => "Social Media Account: #{@outlet.organization}, is now certified.".html_safe
  end

  def archive
    @outlet.touch
    @outlet.archived!
    # @outlet.build_notifications(:archived)
    redirect_to admin_outlet_path(@outlet), :notice => "Social Media Account: #{@outlet.organization}, is now archived. #{view_context.link_to 'Undo', publish_admin_outlet_path(@outlet)}".html_safe
  end

  private
    
  def set_outlet
    @outlet = Outlet.find(params[:id])
  end

  def current_page
    if params[:page]
      return params[:page].to_i
    else
      return 1
    end
  end
end