# encoding: utf-8

require 'spec_helper'

describe EventsController do
  describe 'POST create' do
    before do
      @user = Fabricate(:user)
      @draft = Fabricate(:folder, :title => 'draft')
      @entry = Fabricate(:entry, :folder => @draft, :user_id => @user.id)
    end

    describe 'user' do
      before do
        sign_in @user
      end

      it 'может создать событие с типом send_to_corrector' do
        expect {
          post :create, :event => {:type => 'send_to_corrector'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)
      end

      it 'может создать событие с типом to_trash' do
        expect {
          post :create, :event => {:type => 'to_trash'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)
      end
    end

    describe 'corrector' do
      before do
        user = Fabricate(:user, :roles => ['corrector'])
        sign_in user
      end

      it 'может отправить созданную новость публикатору' do
        Fabricate(:folder, :title => 'inbox')

        expect {
          post :create, :event => {:type => 'immediately_send_to_publisher'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)

        @entry.reload.folder.title.should eql 'inbox'
      end

      it 'может создать событие с типом correct' do
        expect {
          post :create, :event => {:type => 'correct'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)
      end

      it 'может создать событие с типом return_to_author' do
        expect {
          post :create, :event => {:type => 'return_to_author'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)
      end

      it 'может создать событие с типом send_to_publisher' do
        expect {
          post :create, :event => {:type => 'send_to_publisher'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)
      end

      it 'может создать событие с типом to_trash' do
        expect {
          post :create, :event => {:type => 'to_trash'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)
      end
    end

    describe 'publisher' do
      before do
        user = Fabricate(:user, :roles => ['publisher'])
        sign_in user
      end

      it 'может опубликовать созданную новость' do
        Fabricate(:folder, :title => 'published')

        expect {
          post :create, :event => {:type => 'immediately_publish'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)

        @entry.reload.folder.title.should eql 'published'
      end

      it 'может создать событие с типом return_to_corrector' do
        expect {
          post :create, :event => {:type => 'return_to_corrector'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)
      end

      it 'может создать событие с типом publish' do
        expect {
          post :create, :event => {:type => 'publish'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)
      end

      it 'может создать событие с типом to_trash' do
        expect {
          post :create, :event => {:type => 'to_trash'}, :folder_id => @draft.title, :entry_id => @entry.id
        }.to change(Event, :count).by(1)
      end
    end
  end
end
