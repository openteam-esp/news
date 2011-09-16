# encoding: utf-8

require 'spec_helper'

describe Public::EntriesController do
  describe "GET index" do
    def searcher
      controller.send(:searcher)
    end

    it "должны показываться только опубликованные новости" do
      get :index
      assigns(:entries).where_values_hash.should == {:state => 'published'}
    end

    describe "должен отдавать результаты в формате" do
      it "xml" do
        get :index, :format => :xml
        response.header["Content-Type"].should match(/xml/)
      end

      it "json" do
        get :index, :format => :json
        response.header["Content-Type"].should match(/json/)
      end
    end

    describe "search object должен" do

      it "отрабатывать если передан параметр utf8" do
        searcher.should_receive(:results).any_number_of_times.and_return(Sunspot::Search::PaginatedCollection.new([], 1, 10, 13))
        get :index, :utf8 => true
      end

      it "проставлять channel_ids из параметра channel_id" do
        Channel.should_receive(:find).with('1').and_return(Channel.new)
        get :index, :channel_id => '1', :utf8 => true
        searcher.channel_ids.should == [1]
      end

      it "проставлять параметр keywords" do
        get :index, :keywords => 'лунтик', :utf8 => true
        searcher.keywords.should == 'лунтик'
      end

      it "проставлять per_page из параметров" do
        get :index, :per_page => 3, :utf8 => true
        searcher.pagination[:per_page].should == 3
      end

      it "ограничивать per_page минимум 1" do
        get :index, :per_page => 0, :utf8 => true
        searcher.pagination[:per_page].should == 1
      end

      it "ограничивать per_page максимум 20" do
        get :index, :per_page => 21, :utf8 => true
        searcher.pagination[:per_page].should == 20
      end

    end

    it "при поиске должен проставлять HTTP заголовки X-Total-Count, X-Total-Pages" do
      Channel.should_receive(:find).with(1).and_return(Channel.new)
      searcher.should_receive(:results).any_number_of_times.and_return(Sunspot::Search::PaginatedCollection.new([], 1, 10, 13))
      get :index, :channel_id => 1, :utf8 => true
      response.headers['X-Total-Count'].should == 13
      response.headers['X-Total-Pages'].should == 2
    end

    describe "GET show" do
      describe "должен отдавать результаты в формате" do
        before {Entry.should_receive(:find).with(1).and_return(Entry.new)}
        it "xml" do
          get :show, :id => 1, :format => :xml
          response.header["Content-Type"].should match(/xml/)
        end

        it "json" do
          get :show, :id => 1, :format => :json
          response.header["Content-Type"].should match(/json/)
        end
      end

      describe "должен возвращать новость из канала" do
        let (:entry) { "" }
        let (:channel) { "" }

        def mock_channel
          Channel.should_receive(:find).with(2).and_return(channel)
        end

        def mock_entries
          entries = []
          entries.should_receive(:find).with(1).and_return(entry)
          channel.should_receive(:entries).and_return(entries)
        end

        it "если новость есть" do
          mock_channel
          mock_entries
          get :show, :channel_id => 2, :id => 1
          assigns(:entry).should == entry
        end

        it "если нет новости в канале, то ошибку" do
          channel = Fabricate(:channel)
          expect {get(:show, :channel_id => channel.id, :id => 3)}.to raise_error
        end

        it "если нет канала, то ошибку" do
          expect {get(:show, :channel_id => 2, :id => 3)}.to raise_error
        end

      end
    end

  end
end

