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
require 'rails_helper'

RSpec.describe User, type: :model do
  subject { User.create!(username: 'Joyce Davis', password: 'password')}
  
  describe "validations" do
    it {should validate_presence_of(:username)}
    it {should validate_presence_of(:password_digest)}
    it {should validate_presence_of(:session_token)}
    it {should validate_length_of(:password).is_at_least(6)}
  end

  describe "uniqueness" do
    before :each do
      create(:user)
    end
    it {should validate_uniqueness_of(:username)}
    it {should validate_uniqueness_of(:session_token)}
  end

  describe "associations" do
    it {should have_many(:goals)}
  end

  describe "::find_by_credentials" do
    let(:user) {create(:schmiegel)}
    # username = :user.username
    # password = 'password'
    it "find the correct user given valid params" do
      user = User.find_by(username: 'Schmiegel')

      expect(User.find_by_credentials('Schmiegel', 'password')).to eq(user)
    end
  end

  describe "#is_password?" do
    let(:user) {create(:user)}
    context "with a valid password" do
      it "should return true" do
        expect(user.is_password?('password')).to be true
      end  
    end

    context "with a invalid password" do
      it "should return false" do
        expect(user.is_password?('notpassword')).to be false
      end  
    end
  end

  describe "#password=" do
    # FactoryBot.create(:schmiegel)
    it "does not save plain password to the database" do
      user = User.find_by(username: 'Schmiegel')
      expect(user.password).to_not eq('password')
    end

    it "properly sets the password reader" do
      user = User.new(username: 'Jack', password: 'abcdef')
      expect(user.password).to eq('abcdef')
    end

    it "secures password using BCrypt" do
      expect(BCrypt::Password).to receive(:create).with('youshallnotpass')
      FactoryBot.build(:user, password: 'youshallnotpass')
    end
  end

  describe "session token" do
    it "assigns a session token if one is not given" do
      expect(subject.session_token).to_not be_nil
    end

    it "uses '#reset_session_token!' to reset a session on a user" do
      old_token = subject.session_token
      new_token = subject.reset_session_token!
      expect(old_token).to_not eq(new_token)
    end
  end



end
