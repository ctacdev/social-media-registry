class Admin::RelatedPoliciesController < Admin::AdminController
  helper_method :sort_column, :sort_direction
  respond_to :html, :xml, :json, :csv, :xls
  before_action :set_related_policy, only: [:show, :edit, :update, :destroy, :history, :restore, :reassign]
  protect_from_forgery except: :tokeninput
 
  before_action :require_admin
  before_action :admin_two_factor
  
  def index 
    @related_policies = RelatedPolicy.all.order(sort_column + " " + sort_direction) 
    respond_to do |format|
      format.html { @related_policies = [] }
      format.json { render "index" }
      format.xml { render xml: @related_policies }

      format.csv { send_data @related_policies.to_csv }
      format.xls { send_data @related_policies.to_csv(col_sep: "\t")}
    end
  end

  def new
    @related_policy = RelatedPolicy.new
  end

  def show
   
  end

  def edit
    
  end

  def create
    @related_policy = RelatedPolicy.new(related_policy_params)
    respond_to do |format|
      if @related_policy.save
        format.html { redirect_to admin_related_policy_path(@related_policy), notice: 'Related Policy was successfully created.' }
        format.json { render :show, status: :created, location: @related_policy }
      else
        format.html { render :new }
        format.json { render json: @related_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @related_policy.update(related_policy_params)
        format.html {redirect_to admin_related_policy_path(@related_policy), notice: 'Related Policy was successfully updated.'}
        format.json  {render :show, status: :ok, location: admin_related_policy_path(@related_policy)}
      else
        format.html {render :edit }
        format.json {render json: @related_policy.errors, status: :unprocessable_entity }
      end
    end
  end
  def destroy
    @related_policy.destroy!
    respond_to do |format|
      format.html { redirect_to admin_agencies_url, notice: "Related Policy was successfully destroyed."}
      format.json { head :no_content }
    end
  end


  private
    def set_related_policy
      @related_policy = RelatedPolicy.find(params[:id])
    end
    def related_policy_params
      params.require(:related_policy).permit(:title, :service, :url, :description)
    end

    def sort_column
      RelatedPolicy.column_names.include?(params[:sort]) ? params[:sort] : "title"
    end
  
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end 
end
