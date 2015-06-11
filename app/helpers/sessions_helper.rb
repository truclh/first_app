module SessionsHelper
	def sign_in user
		cookies.permanent[:remember_token] = user.remember_token
		session[:user_id] = user.id
	end
	def sign_out
		session.delete(:user_id)
		@current_user = nil
	end

	def signed_in?
		!session[:user_id].nil?	
	end
	def remember user
		cookies.permanent.signed[:user_id] = used.id
		cookies.remember_token.signed[:remember_token]= user.remember_token
	end
	def current_user
		if user_id = session[:user_id]
			@current_user ||= User.find_by id: user_id
			elsif user_id = cookies.signed[:user_id]
				user = User.find_by id: user_id
				if user && user.authenticate?(:remember, cookies[:remember_token])
					sign_in user
					@current_user = user				
				end
		end
	end
	def forget user
		user.clear_remember_token
		cookies.delete :user_id
		cookies.delete :remember_token
	end
	def current_user? user
		user == current_user
	end

	#chap 9 Redirects to stored location (or to the default).
	def redirect_back_or default
		redirect_to(session[:forwarding_url] || default)
		session.delete :forwarding_url
	end
	def store_location
		session[:forwarding_url] = request.url if request.get?
	end
end
