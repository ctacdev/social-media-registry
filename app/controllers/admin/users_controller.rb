class Admin::UsersController < Admin::AdminController
  helper_method :sort_column, :sort_direction
  respond_to :html, :xml, :json

  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_notification_settings, :update_notification_settings, :notifications]
  before_action :require_admin, only: [:index, :destroy]
  before_action :require_admin_or_owner, except: [:index, :tokeninput]
  before_action :admin_two_factor, except: [:index, :tokeninput, :show]
  # GET /users
  # GET /users.json
  def index
    num_items = items_per_page_handler        
    @users = User.all
   
    @users = @users
    respond_to do |format|
      format.html { @users = [] }
      format.json { render "index" }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show

  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit

  end

  # Get /users/1/edit_notifications
  def edit_notification_settings

  end

  # PATCH/PUT /users/1/update_notifications
  def update_notification_settings
    respond_to do |format|
      if @user.update(notification_params)
        format.html { redirect_to edit_notification_settings_admin_user_path(@user), notice: 'Notifications were successfully updated.' }
        format.json { render :show, status: :ok, location: admin_user_path(@user) }
      else
        format.html { render :edit_notification_settings }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_user_path(@user) }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def tokeninput
    @users = User.where("first_name LIKE ? OR last_name LIKE ? OR email LIKE ?", "%#{params[:q]}%","%#{params[:q]}%","%#{params[:q]}%")
    respond_to do |format|
      format.json { render 'tokeninput'}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :user, :agency_id, :phone, :first_name, :last_name, :groups, :role)
  end

  def notification_params
    params.require(:user).permit(:agency_notifications, :agency_notifications_emails,:contact_notifications, :email_notification_type)
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "email"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def items_per_page_handler
    per_page_count = 25    
    if cookies[:per_page_count_users]
      per_page_count = cookies[:per_page_count_users]
    end
    if params[:per_page]
      per_page_count = params[:per_page]
      cookies[:per_page_count_users] = per_page_count
    end
    return per_page_count.to_i        
  end   

end
