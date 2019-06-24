class Admin::EmailMessagesController < Admin::AdminController

	before_action :require_admin, except: [:new, :create, :show]
	before_action :admin_two_factor, except: [:new, :create, :show]
	def index
		@email_messages = EmailMessage.all.page(params[:page]).per(15)
	end
	
	def new
		@emails = []
		if params[:include_admins]
			@emails = ["usdigitalregistry@gsa.gov"]
		end
		if params[:param1]
			if !@emails.include? params[:param1]
				@emails << params[:param1]
			end
		end
		if !@emails.include? current_user.email
			@emails << current_user.email
		end
		@email = EmailMessage.new(to: @emails.map(&:to_s).join(', '))
	end

	def show
		@email = EmailMessage.find(params[:id])
	end

	def create
		@email = EmailMessage.new(email_message_params)
		@email.user = current_user
		if @email.save
			flash[:notice] = "Email successfully sent!"
			EmailMessageMailer.email(@email).deliver_later
			render 'sent'
		else
			render "new"
		end
	end	


	private 

		def set_email_message
			@email = EmailMessage.find(params[:id])
		end

		def email_message_params 
			params.require(:email_message).permit(:to, :subject, :body)
		end

end
