# encoding: utf-8

require "spec_helper"


describe Ability do
  let(:ability) { Ability.new }

  describe "задачи" do
    let(:processing_prepare_issue) { Prepare.new(:state => 'processing', :executor => initiator) }
    let(:processing_review_issue)  { Review.new(:state => 'processing', :executor => initiator) }
    let(:processing_publish_issue) { Publish.new(:state => 'processing', :executor => initiator) }

    before { set_current_user initiator }

    describe "может закрывать исполнитель" do
      it { ability.should be_able_to(:complete, processing_prepare_issue) }
      it { ability.should be_able_to(:complete, processing_review_issue) }
      it { ability.should be_able_to(:complete, processing_publish_issue) }
    end

    describe "не может закрывать другой пользователь" do
      before { set_current_user corrector }

      it { ability.should_not be_able_to(:complete, processing_prepare_issue) }
      it { ability.should_not be_able_to(:complete, processing_review_issue) }
      it { ability.should_not be_able_to(:complete, processing_publish_issue) }
    end

    it { ability.should_not be_able_to(:complete, Issue.new(:state => :pending)) }
    it { ability.should_not be_able_to(:complete, Issue.new(:state => :fresh)) }
    it { ability.should_not be_able_to(:complete, Issue.new(:state => :completed, :executor => initiator)) }
  end

if false
  describe "просмотр новости" do
    describe "инициатором" do
      before(:each) do
        set_current_user initiator
      end
      it { ability.should be_able_to(:read, draft) }
      it { ability.should be_able_to(:read, awaiting_correction) }
      it { ability.should be_able_to(:read, correcting) }
      it { ability.should be_able_to(:read, awaiting_publication) }
      it { ability.should be_able_to(:read, publicating) }
      it { ability.should be_able_to(:read, published) }
      it { ability.should be_able_to(:read, trash) }
      it { ability.should_not be_able_to(:destroy, Asset.new(:entry => trash)) }
      it { ability.should be_able_to(:create, Asset.new(:entry => draft)) }
      it { ability.should be_able_to(:read, Asset.new(:entry => published, :deleted_at => Time.now)) }
      it { ability.should be_able_to(:read, Image.new(:entry => published, :deleted_at => Time.now)) }
    end
    describe "корректором" do
      before(:each) do
        set_current_user another_initiator(:roles => [:corrector])
      end
      it { ability.should_not be_able_to(:read, draft) }
      it { ability.should be_able_to(:read, awaiting_correction) }
      it { ability.should be_able_to(:read, correcting) }
      it { ability.should be_able_to(:read, awaiting_publication) }
      it { ability.should be_able_to(:read, publicating) }
      it { ability.should be_able_to(:read, published) }
      it { ability.should_not be_able_to(:read, trash) }
      it { ability.should be_able_to(:read, my_trash) }
    end
    describe "публикатором" do
      before(:each) do
        set_current_user another_initiator(:roles => [:publisher])
      end
      it { ability.should_not be_able_to(:read, draft) }
      it { ability.should be_able_to(:read, awaiting_correction) }
      it { ability.should be_able_to(:read, correcting) }
      it { ability.should be_able_to(:read, awaiting_publication) }
      it { ability.should be_able_to(:read, publicating) }
      it { ability.should be_able_to(:read, published) }
      it { ability.should_not be_able_to(:read, trash) }
      it { ability.should be_able_to(:read, my_trash) }
    end
    describe "другим инициатором" do
      before(:each) do
        set_current_user another_initiator
      end
      it { ability.should_not be_able_to(:read, draft) }
      it { ability.should_not be_able_to(:read, awaiting_correction) }
      it { ability.should_not be_able_to(:read, correcting) }
      it { ability.should_not be_able_to(:read, awaiting_publication) }
      it { ability.should_not be_able_to(:read, publicating) }
      it { ability.should be_able_to(:read, published) }
      it { ability.should_not be_able_to(:read, trash) }
      it { ability.should_not be_able_to(:read, Asset.new(:entry => draft)) }
      it { ability.should be_able_to(:read, Asset.new(:entry => published)) }
      it { ability.should_not be_able_to(:read, Asset.new(:entry => published, :deleted_at => Time.now)) }
    end
  end

  describe "редактирование новости" do
    describe "инициатором" do
      before(:each) do
        set_current_user initiator
      end
      it { ability.should be_able_to(:edit, draft) }
      it { ability.should_not be_able_to(:edit, awaiting_correction) }
      it { ability.should_not be_able_to(:edit, correcting) }
      it { ability.should_not be_able_to(:edit, awaiting_publication) }
      it { ability.should_not be_able_to(:edit, publicating) }
      it { ability.should_not be_able_to(:edit, published) }
      it { ability.should_not be_able_to(:edit, trash) }
    end
    describe "корректором" do
      before(:each) do
        set_current_user another_initiator(:roles => [:corrector])
      end
      it { ability.should_not be_able_to(:edit, draft) }
      it { ability.should_not be_able_to(:edit, awaiting_correction) }
      it { ability.should be_able_to(:edit, correcting) }
      it { ability.should_not be_able_to(:edit, awaiting_publication) }
      it { ability.should_not be_able_to(:edit, publicating) }
      it { ability.should_not be_able_to(:edit, published) }
      it { ability.should_not be_able_to(:edit, trash) }
      it { ability.should_not be_able_to(:edit, my_trash) }
    end
    describe "публикатором" do
      before(:each) do
        set_current_user another_initiator(:roles => [:publisher])
      end
      it { ability.should_not be_able_to(:edit, draft) }
      it { ability.should_not be_able_to(:edit, awaiting_correction) }
      it { ability.should_not be_able_to(:edit, correcting) }
      it { ability.should_not be_able_to(:edit, awaiting_publication) }
      it { ability.should be_able_to(:edit, publicating) }
      it { ability.should be_able_to(:edit, published) }
      it { ability.should_not be_able_to(:edit, trash) }
      it { ability.should_not be_able_to(:edit, my_trash) }
    end
    describe "публикатором + корректором" do
      before(:each) do
        set_current_user another_initiator(:roles => [:publisher, :corrector])
      end
      it { ability.should_not be_able_to(:edit, draft) }
      it { ability.should_not be_able_to(:edit, awaiting_correction) }
      it { ability.should be_able_to(:edit, correcting) }
      it { ability.should_not be_able_to(:edit, awaiting_publication) }
      it { ability.should be_able_to(:edit, publicating) }
      it { ability.should be_able_to(:edit, published) }
      it { ability.should_not be_able_to(:edit, trash) }
      it { ability.should_not be_able_to(:edit, my_trash) }
    end
    describe "другим инициатором" do
      before(:each) do
        set_current_user another_initiator
      end
      it { ability.should_not be_able_to(:edit, draft) }
      it { ability.should_not be_able_to(:edit, awaiting_correction) }
      it { ability.should_not be_able_to(:edit, correcting) }
      it { ability.should_not be_able_to(:edit, awaiting_publication) }
      it { ability.should_not be_able_to(:edit, publicating) }
      it { ability.should_not be_able_to(:edit, published) }
      it { ability.should_not be_able_to(:edit, trash) }
    end
  end
end
end
