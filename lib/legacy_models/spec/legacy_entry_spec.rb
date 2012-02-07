# encoding: utf-8

require 'spec_helper'

describe LegacyEntry do

  def legacy(options={})
    @legacy ||= begin
                  asset = options.delete(:asset)
                  Fabricate(:legacy_entry, options).tap do | legacy |
                    if asset
                      file = File.open(Rails.root.join "spec", "fixtures", asset.to_s)
                      legacy.assets.create!  :file_file_name => asset.to_s,
                                             :file_content_type => "#{asset}/some",
                                             :description => "Файл #{asset}"
                    end
                  end
                end
  end

  def migrated(legacy=nil)
    @migrated ||= legacy.migrate
  end

  let(:entry) { migrated(legacy) }

  #context "после миграции" do
    #it "должен установить инициатора" do
      #entry.initiator.name.should == "Мигратор"
    #end
    #it "должен установить title" do
      #entry.title.should == legacy.title.gilensize(:html => false, :raw_output => true)
    #end
    #it "должен упрощать annotation" do
      #entry.annotation.should =~ /^<p>В конце минувшей/
    #end
    #it "должен форматировать body" do
      #entry.body.should == RDiscount.new(legacy.body).to_html.gilensize.gsub(/&#160;/, '&nbsp;')
      #entry.body.should =~ /^<p>/
      #entry.body.scan("<p>").size.should == 4
    #end
    #it "должен проставлять created_at, updated_at" do
      #entry.created_at.should == legacy.created_at
      #entry.updated_at.should == legacy.updated_at
    #end
    #it "должен проставлять since, until" do
      #entry.since.should == legacy.date_time
      #entry.until.should == legacy.end_date_time
    #end
  #end

  #describe "должен в зависимости от status" do
    #let (:prepare) { entry.prepare }
    #let (:review) { entry.review }
    #let (:publish) { entry.publish }

    #describe "blank" do
      #let(:entry) { migrated(legacy(:status => :blank)) }
      #it { entry.state.should == "correcting" }
      #it { prepare.should be_completed }
      #it { prepare.executor_id.should_not be_nil }
    #end
    #describe "ready_to_publish" do
      #let(:entry) { migrated(legacy(:status => :ready_to_publish)) }
      #it { entry.state.should == 'publishing' }
      #it { review.should be_completed }
      #it { review.executor_id.should_not be_nil }
      #it { publish.should be_fresh }
    #end
    #describe "publish" do
      #let(:entry) { migrated(legacy(:status => :publish)) }
      #it { entry.state.should == "published" }
      #it { publish.should be_completed }
      #it { publish.executor_id.should_not be_nil }
    #end
  #end

  #describe "должны проставляться каналы в зависимости от target_id" do
    #it "nil => []" do
      #migrated(legacy(:target_id => nil)).channels.should be_empty
    #end
    #it "1 => 'Анонсы'" do
      #migrated(legacy(:target_id => 1)).channels.map(&:title).should == ["tomsk.gov.ru/ru/announces"]
    #end
    #it "2 => 'Новости'" do
      #migrated(legacy(:target_id => 2)).channels.map(&:title).should == ["tomsk.gov.ru/ru/news"]
    #end
  #end

  context "с файлами" do
    let(:audio) { migrated(legacy(:asset => :audio)).audios[0] }
    let(:attachment) { migrated(legacy(:asset => :attachment)).attachments[0] }

    context "после миграции" do

      before { ElVfsClient::Client.any_instance.should_receive(:upload).and_return(result) }

      context 'картинками' do
        let(:url) {'http://pool.openteam.ru/files/1/image'}
        let(:resized_url) {'http://pool.openteam.ru/files/1/32-150/image'}
        let(:result) { {:url => url, :width => 129, :height => 600} }
        subject { migrated(legacy(:asset => :image)) }
        its(:body) { should =~ %r{<a href="#{url}" target="_blank"><img alt="Файл image" height="150" src="#{resized_url}" width="32"} }
      end

      context 'аудио' do
        let(:url) {'http://pool.openteam.ru/files/1/audio'}
        let(:result) { {:url => url} }
        subject { migrated(legacy(:asset => :audio)) }
        its(:body) { should =~ %r{<audio controls="controls" src="#{url}">.*<a href="#{url}".*>Файл audio</a></audio>} }
      end

      context 'просто файлик' do
        let(:url) {'http://pool.openteam.ru/files/1/attachment'}
        let(:result) { {:url => url} }
        subject { migrated(legacy(:asset => :attachment)) }
        its(:body) { should =~ %r{<a href="#{url}" target="_blank">Файл attachment</a>} }
      end
    end
  end

end
