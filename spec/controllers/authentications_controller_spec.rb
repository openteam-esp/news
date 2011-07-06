require 'spec_helper'

describe AuthenticationsController do

  describe "POST / from twitter" do

    def mock_omniauth_fields *fields
      request.env['omniauth.auth'] = {
        'uid'       => '12345',
        'provider'  => 'twitter',
        'user.info' => user.select{|k,v| fields.include? k}.with_indifferent_access
      }
    end

    let :user do {name: 'Vasily Terkin', nickname: 'VasyaTerkin', email: 'vasya@terkin.ru'} end

    def current_user
      subject.current_user
    end

    context "anonymous user could create authentication" do
      #current_user.reload.should have(1).authentication

      describe "with twitter" do
        it "having name filled" do
          mock_omniauth_fields :name
          post :create
          current_user.name.should eql user[:name]
        end
        it "having nickname filled" do
          mock_omniauth_fields :nickname
          post :create
          current_user.name.should eql user[:nickname]
        end
        it "having nickname and name filled" do
          mock_omniauth_fields :nickname, :name
          post :create
          current_user.name.should eql user[:name]
        end
      end


      describe "with facebook" do
        it 'with email' do
          mock_omniauth_fields :email
          post :create
          current_user.email.should eql user[:email]
        end
      end
    end

  end

end
