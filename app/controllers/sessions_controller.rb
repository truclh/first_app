class SessionsController < ApplicationController
  def new

  end

  def create
  	user = User.find_by_email(params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])

      if user.activated?
        sign_in user
        redirect_back_or user
        params[:session][:remember_me] == 1 ? remember(user) : forget(user)
      else
        message = "Account not activated"
        message += "Please check your email for the activation link"
        flash[:warning] = message 
        redirect_to root_url
      end
  	else
  		flash[:errors] = 'Invalid email/password combination' # Not quite right!	
		  render 'new'
	  end
  end
  def destroy
    sign_out if signed_in?
    sign_out
    redirect_to root_url
  end
end