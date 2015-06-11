class AccountActivationsController < ApplicationController
	def edit
		user = User.find_by(email: params[:email])
		# binding.pry
		if user && !user.activated? && user.authenticate?(:activation, params[:id])
			user.activate
			sign_in user
			flash[:success] = "Account Activated"
			redirect_to user
		else
			flash[:danger] = "Invalid Activation Link"
			redirect_to root_url
		end
	end
end
