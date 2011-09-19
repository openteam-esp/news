# encoding: utf-8

require 'spec_helper'

describe Entry do

  it { should have_many(:assets) }
  it { should have_many(:images) }
  it { should have_many(:videos) }
  it { should have_many(:audios) }
  it { should have_many(:attachments) }
  it { should have_many(:tasks) }

  it { expect { Fabricate(:entry, :assets_attributes => [ Fabricate.attributes_for(:asset)] ) }.to change(Asset, :count).by(1) }
  it { expect { Fabricate(:entry, :assets_attributes => [ {} ] ) }.to_not change(Asset, :count) }

  describe "composed_title" do
    it "для пустой новости" do
      Entry.new.composed_title.should == "(без заголовка)"
    end

    it "для новости с заголовком" do
      Entry.new(:title => "заголовок").composed_title.should == "заголовок"
    end

    it "для новости с текстом" do
      Entry.new(:body => "текст").composed_title.should == "(без заголовка) – текст"
    end

    it "для новости с заголовком и текстом" do
      Entry.new(:title => "заголовок", :body => "текст").composed_title.should == "заголовок – текст"
    end

    it "большой текст" do
      Entry.new(:body => "a"*100).composed_title.should == "(без заголовка) – #{'a'*81}…"
    end

    it "большой заголовок" do
      Entry.new(:title => "a"*100).composed_title.should == "#{'a'*79}…"
    end

    it "большой заголовок + большой текст" do
      Entry.new(:title => "a"*100, :body => "<p>" + "a"*100 + "</p>").composed_title.should == "#{'a'*79}… – #{'a'*16}…"
    end
  end

  it 'сортировка должна быть по убыванию по дате-времени создания' do
    Entry.scoped.to_sql.should == Entry.unscoped.order('created_at desc').to_sql
  end

  it 'должна корректно сохранять и отображать дату' do
    I18n.l(draft(:since => "19.07.2011 09:20").since, :format => :datetime).should == "19.07.2011 09:20"
  end

  describe "папки новостей" do
    it "инициатору показываются только его новости" do
      set_current_user(initiator)
      Entry.all_states.each do |state|
        Entry.state(state).where_values_hash.should == {:state => state, :initiator_id => initiator.id}
      end
    end

    it "личные папки для корректора и публикатора" do
      [corrector, publisher].each do |user|
        set_current_user(user)
        Entry.state(:draft).where_values_hash.should == {:state => :draft, :initiator_id => user.id}
      end
    end

    it "папки корректора и публикатора для новостей в процесса" do
      [corrector, publisher].each do |user|
        set_current_user(user)
        Entry.state('processing').where_values_hash.should == {:state => Entry.processing_states}
      end
    end

  end

  describe "после сохранения" do
    before(:each) do
      set_current_user initiator
    end
    let (:prepare) { stored_draft.prepare.reload }
    let (:review) { stored_draft.review.reload }
    let (:publish) { stored_draft.publish.reload }
    it { stored_draft.tasks.should == [prepare, review, publish] }

    describe "задача подготовки" do
      it { prepare.initiator.should == initiator }
      it { prepare.executor.should == initiator }
      it { prepare.state.should == 'processing' }
    end

    describe "задача корретировки" do
      it { review.initiator.should == initiator }
      it { review.executor.should == nil }
      it { review.state.should == 'pending' }
    end

    describe "задача публикации" do
      it { publish.initiator.should == initiator }
      it { publish.executor.should == nil }
      it { publish.state.should == 'pending' }
    end
  end

  describe "при публикации" do
    before { set_current_user corrector_and_publisher }
    it "если нет канала, должна быть ошибка" do
      processing_publishing.channels = []
      processing_publishing.save!
      expect { processing_publishing.publish.complete! }.to raise_error
    end
  end

end








# == Schema Information
#
# Table name: entries
#
#  id           :integer         not null, primary key
#  title        :text
#  annotation   :text
#  body         :text
#  since        :datetime
#  until        :datetime
#  state        :string(255)
#  author       :string(255)
#  initiator_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  legacy_id    :integer
#

