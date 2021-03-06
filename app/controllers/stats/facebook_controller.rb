class Stats::FacebookController < ApplicationController

  layout "admin"


  before_action :authenticate_user! unless Rails.env.development? || ENV['IMPERSONATE_ADMIN'].present?
  before_action :banned_user?, except: [:about, :impersonate, :dashboard]
  helper_method :current_user


  def index

  end

  def current_user
    if Rails.env.development? || ENV['IMPERSONATE_ADMIN'].present?
      if session[:user_id] && User.where(id: session[:user_id]).count > 0
        @current_user ||= User.find(session[:user_id])
      else
        @current_user ||= User.where(role: 2).first
      end
    else
      @current_user ||= warden.authenticate(scope: :user)
    end
  end

  def banned_user?
    if current_user.banned?
      redirect_to admin_about_path, status: 302, notice: "You have been banned from the system you may want to email an admin directly if you believe this to be in error."
    end
  end

  def require_admin
    if !current_user.admin?
      redirect_to admin_dashboards_path, notice: "You shouldn't be going there... here is the dashboard instead."
    end
  end

  def require_admin_or_owner
    if !current_user.admin? && current_user.id != @user.id
      redirect_to admin_dashboards_path, notice: "Hey, thats not your account, check out the dashboard!"
    end
  end

end
