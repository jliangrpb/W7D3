# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
    attr_reader :password
    before_validation :ensure_session_token

    def password=(password)
        self.password_digest = BCrypt::Password.create(password)
        @password = password
    end

    def generate_unique_session_token
        loop do
            session_token = SecureRandom::urlsafe_base64(16)
            return session_token unless User.exists?(session_token)
        end
    end

    def ensure_session_token
        self.session_token = generate_unique_session_token
    end
end
