class PasswordResetController < ApplicationController
  before_action :get_user, only: [:edit, :udpate]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only:[:edit, :update]

  def new
  end

  def edit
  end

  def create
    	user = User.find_by email: params[:password_reset][:email].downcase
  		if user
        user.create_reset_digest
  			user.send_password_reset_email
  			flash[:info] = "Emails sent with password reset instructions"
  			redirect_to root_url
  		else
  			flash[:danger] = "Email address not found"
  			render 'new'	
  		end
  end

  def update
    if params[:user][:password].empty?
      flash.now[:danger] ="Password can't be blank"
      render 'edit'
    elsif @user.update_attributes!(user_params)
      sign_in @user
      flash.now[:info] = "Password has been reset"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  #C10: get user for password reset
  def get_user
    @user = User.find_by(email: params[:email])
  end
  #C10: Confirm valid User
  def valid_user
    get_user
    unless @user && @user.activated? && @user.authenticate?(:reset, params[:id])
      redirect_to root_url
    end
  end
  def check_expiration
    if @user.password_reset_expired?
      flash[:error] = "Password reset has expirated"
      redirect_to new_password_reser_url
    end
  end

end
