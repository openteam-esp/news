# encoding: utf-8

require 'spec_helper'

describe Migrator::Entry do

  def legacy(options={})
    asset = options.delete(:asset)
    Fabricate('legacy/entry', options).tap do | legacy |
      if asset
        file = File.open(Rails.root.join "spec", "fixtures", asset.to_s)
        legacy.assets.create! :file_file_name => asset.to_s,
                              :description => "Файл #{asset}",
                              :type => 'AttachmentFile'
      end
    end
  end

  def migrated(legacy)
    legacy.migrate
  end

  describe "после миграции" do
    it "должен установить инициатора" do
      migrated(legacy).initiator.name.should == "Мигратор"
    end

    it "должен установить title" do
      migrated(legacy).title.should == legacy.title
    end

    it "должен упрощать annotation" do
      migrated(legacy).annotation.should =~ /^<p>В конце минувшей/
    end

    it "должен форматировать body" do
      migrated(legacy).body.should == RDiscount.new(legacy.body).to_html
      migrated(legacy).body.should =~ /^<p>/
      migrated(legacy).body.scan("<p>").size.should == 4
    end

    it "должен проставлять created_at, updated_at" do
      migrated(legacy).created_at.should == legacy.created_at
      I18n.l(migrated(legacy).created_at, :format => "%d.%m.%Y %H:%M").should == "20.07.2011 17:21"
      migrated(legacy).updated_at.should == legacy.updated_at
    end
    it "должен проставлять since, until" do
      migrated(legacy).since.should == legacy.date_time
      migrated(legacy).until.should == legacy.end_date_time
    end
  end

  describe "должен в зависимости от status" do
    let (:prepare) { @entry.prepare }
    let (:review) { @entry.review }
    let (:publish) { @entry.publish }

    describe "blank" do
      before { @entry = migrated(legacy(:status => :blank)) }
      it { @entry.state.should == "correcting" }
      it { prepare.should be_completed }
      it { prepare.executor_id.should_not be_nil }
    end
    describe "ready_to_publish" do
      before { @entry = migrated(legacy(:status => :ready_to_publish)) }
      it { @entry.state.should == 'publishing' }
      it { review.should be_completed }
      it { review.executor_id.should_not be_nil }
      it { publish.should be_fresh }
    end
    describe "publish" do
      before { @entry = migrated(legacy(:status => :publish)) }
      it { @entry.state.should == "published" }
      it { publish.should be_completed }
      it { publish.executor_id.should_not be_nil }
    end
  end

  describe "должны проставляться каналы в зависимости от target_id" do
    it "nil => []" do
      migrated(legacy(:target_id => nil)).channels.should be_empty
    end
    it "1 => 'Анонсы'" do
      migrated(legacy(:target_id => 1)).channels.map(&:title).should == ["tomsk.gov.ru/ru/announces"]
    end
    it "2 => 'Новости'" do
      migrated(legacy(:target_id => 2)).channels.map(&:title).should == ["tomsk.gov.ru/ru/news"]
    end
  end

  describe "старых новостей с файлами" do
    describe 'должны смигрироваться' do
      it "файлы" do
        migrated(legacy(:asset => :attachment)).assets[0].file_size.should > 0
      end
    end
    describe "должны проставиться" do
      it "имена файлов" do
        migrated(legacy(:asset => :attachment)).assets[0].file_name.should == 'attachment'
      end
      it "размеры картинок" do
        migrated(legacy(:asset => :image)).assets[0].file_width.should > 0
      end
      it "описания" do
        migrated(legacy(:asset => :image)).assets[0].description.should == "Файл image"
      end
    end

    describe "в новостях должны проставляться ссылки" do
      it "на картинки" do
        pending
        migrated(legacy(:asset => :image)).body.should =~ /<li><a.*?>\s*<img .*?>\s*<\/a><\/li>/
      end
      it "на аттачи" do
        pending
        migrated(legacy(:asset => :attachment)).body.should =~ /<li><a.*?>Файл attachment<\/a><\/li>/
      end
    end
  end

end
