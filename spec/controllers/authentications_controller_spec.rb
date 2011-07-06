# encoding: utf-8

require 'spec_helper'

describe AuthenticationsController do

  describe "POST / from twitter" do

    def mock_omniauth_fields(provider, *fields)
      request.env['omniauth.auth'] = {
        'uid'       => '12345',
        'provider'  => provider,
        'user_info' => user.select{|k,v| fields.include? k}.with_indifferent_access
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
          mock_omniauth_fields :twitter, :name
          post :create
          current_user.name.should eql user[:name]
        end
        it "having nickname filled" do
          mock_omniauth_fields :twitter, :nickname
          post :create
          current_user.name.should eql user[:nickname]
        end
        it "having nickname and name filled" do
          mock_omniauth_fields :twitter, :nickname, :name
          post :create
          current_user.name.should eql user[:name]
        end
      end


      describe "with facebook" do
        it 'with email' do
          mock_omniauth_fields :twitter, :email
          post :create
          current_user.email.should eql user[:email]
        end
      end
    end

    context "аутентифицированный пользователь" do
      it "при попытке аутентификации должен получить сообщение о том что он уже аутентифицировался" do
        mock_omniauth_fields :twitter, :name
        post :create
        mock_omniauth_fields :vkontakte, :email
        post :create
        flash[:notice].should eql "Вы уже зашли как #{user[:name]} (twitter)"
      end
    end

  end

end
