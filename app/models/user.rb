class User < ActiveRecord::Base
	attr_accessor :remember_token, :activation_token, :reset_token
	attr_accessible  :name, :email, :password, :password_confirmation
	has_secure_password
	validates :password, length: {minimum: 6, maximum: 50}, presence: true 
	validates :password_confirmation, length: {minimum: 6, maximum: 50}, presence: true
	validates :email, uniqueness: true, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i}, length: {maximum: 32}, presence: true
	before_save { |user| user.email = email.downcase }
	before_save :create_remember_token
	before_create :created_activation_digest
	
	def clear_remember_token
		update_attribute(:remember_digest, nil)
		# binding.pry
	end
	def authenticate?(attribute, token)
		digest = send("#{attribute}_digest")	
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)	
	end
	#Activates an account
	def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end
	#Sets the password Reset Attributes C10
    def create_reset_digest
      self.reset_token = User.new_token
      update_attribute(:reset_digest, User.digest(reset_token))
      update_attribute(:reset_sent_at, Time.zone.now)
    end
    #Sends password reset email
 	def send_password_reset_email
 		UserMailer.password_reset(self).deliver_now
 	end
	# Sends activation email
	def send_email_activation
		UserMailer.account_activation(self).deliver_now
	end
	# C10 Password rs expired
	def password_reset_expired?
    reset_sent_at < 2.hours.ago
  	end

	private
	def User.digest string
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : 
		BCrypt::Password.create(string, cost: cost)
	end

	def create_remember_token
		self.remember_token = SecureRandom.urlsafe_base64
	end

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end
	
	def User.new_token
		SecureRandom.urlsafe_base64		
	end
	def created_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end


end
