# app/controllers/users/omniauth_controller.rb
module Users
  class OmniauthCallbacksController < ApplicationController
    def login_dot_gov
      omniauth_info = request.env['omniauth.auth']['info']
      @user = User.find_by(email: omniauth_info['email'])
      if @user
        @user.update!(user: omniauth_info['uuid'])
        sign_in @user
        redirect_to admin_path

      # Can't find an account, tell user to contact login.gov team
      else
        redirect_to admin_about_path, status: 302, notice: "Your account could not be found.  Please contact the administrators."
      end
    end


    def failure
      redirect_to admin_about_path, status: 302, notice: "Your account could not be found.  Please contact the administrators."
    end
  end
end