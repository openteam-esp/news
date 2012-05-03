# encoding: utf-8

require 'spec_helper'

describe EntriesController do
  describe "GET index" do
    def searcher
      controller.send(:searcher)
    end

    it "должны показываться только опубликованные новости" do
      get :index
      assigns(:entries).should have_entries.with_state(:published).not_deleted.ordered_by(:since, :desc)
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

      it "ограничивать per_page максимум 50" do
        get :index, :per_page => 51, :utf8 => true
        searcher.pagination[:per_page].should == 50
      end
    end

    it "при поиске должен проставлять HTTP заголовки X-Total-Count, X-Total-Pages" do
      Channel.should_receive(:find).with('1').and_return(Channel.new)
      searcher.should_receive(:results).any_number_of_times.and_return(Sunspot::Search::PaginatedCollection.new([], 1, 10, 13))
      get :index, :channel_id => 1, :utf8 => true
      response.headers['X-Current-Page'].should == '1'
      response.headers['X-Total-Pages'].should == '2'
    end

    describe "GET show" do
      describe "должен отдавать результаты в формате" do
        it "xml" do
          get :show, :id => published, :format => :xml
          response.header["Content-Type"].should match(/xml/)
        end

        it "json" do
          get :show, :id => published, :format => :json
          response.header["Content-Type"].should match(/json/)
        end
      end

      describe "должен возвращать новость из канала" do
        it "если новость есть" do
          get :show, :channel_id => published.channels.first.id, :id => published
          assigns(:entry).should == published
        end

        it "если нет новости в канале, то ошибку" do
          expect {get(:show, :channel_id => channel.id, :id => 0)}.to raise_error
        end

        it "если нет канала, то ошибку" do
          expect {get(:show, :channel_id => 0, :id => published)}.to raise_error
        end

      end
    end

    describe 'поиск новостей для cms' do
      it 'по умолчанию' do
        get :index, :entry_search => {:channel_ids => [1], :entry_type => 'news'}, :per_page => 12, :page => 2, :utf8 => true

        searcher = Sunspot.session.searches[-3]

        searcher.should have_search_params(:with, :channel_ids, [1])
        searcher.should have_search_params(:with, :state, 'published')
        searcher.should have_search_params(:order_by, :since, :desc)
        searcher.should have_search_params(:paginate, :page => 2, :per_page => 12)
      end

      it 'для архива' do
        get :index, :entry_search => {:channel_ids => [1], :entry_type => 'news', :interval_year => 2012, :interval_month => 4}, :per_page => 12, :page => 2, :utf8 => true

        searcher = Sunspot.session.searches[-3]

        searcher.should have_search_params(:with, :channel_ids, [1])
        searcher.should have_search_params(:with, :state, 'published')
        searcher.should have_search_params(:order_by, :since, :desc)
        searcher.should have_search_params(:paginate, :page => 2, :per_page => 12)

        searcher.should have_search_params(:with, Proc.new { with(:since).greater_than(Time.local(2012, 4, 1)) })
        searcher.should have_search_params(:with, Proc.new { with(:since).less_than(Time.local(2012, 4, 1).end_of_month) })
      end
    end

    describe 'поиск анонсов для cms' do
      it 'по умолчанию' do
        Timecop.freeze(DateTime.now) do
          get :index, :entry_search => {:channel_ids => [1], :entry_type => 'announcements'}, :per_page => 12, :page => 2, :utf8 => true

          searcher = Sunspot.session.searches[-3]

          searcher.should have_search_params(:with, :channel_ids, [1])
          searcher.should have_search_params(:with, :state, 'published')
          searcher.should have_search_params(:order_by, :since, :desc)
          searcher.should have_search_params(:with, Proc.new { with(:actuality_expired_at).less_than(DateTime.now) })
          searcher.should have_search_params(:paginate, :page => 2, :per_page => 12)
        end
      end

      it 'для архива' do
        Timecop.freeze(DateTime.now) do
          get :index, :entry_search => {:channel_ids => [1], :entry_type => 'news', :interval_year => 2012, :interval_month => 4}, :per_page => 12, :page => 2, :utf8 => true

          searcher = Sunspot.session.searches[-3]

          searcher.should have_search_params(:with, :channel_ids, [1])
          searcher.should have_search_params(:with, :state, 'published')
          searcher.should have_search_params(:order_by, :since, :desc)
          searcher.should have_search_params(:paginate, :page => 2, :per_page => 12)
          searcher.should_not have_search_params(:with, Proc.new { with(:actuality_expired_at).less_than(DateTime.now) })

          searcher.should have_search_params(:with, Proc.new { with(:since).greater_than(Time.local(2012, 4, 1)) })
          searcher.should have_search_params(:with, Proc.new { with(:since).less_than(Time.local(2012, 4, 1).end_of_month) })
        end
      end
    end
  end
end

