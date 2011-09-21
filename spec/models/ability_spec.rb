# encoding: utf-8

require "spec_helper"

describe Ability do
  def ability(options={})
    Ability.new options[:for]
  end

  describe "задачy" do
    describe 'принять' do
      let(:fresh_review) {Review.new(:state => 'fresh')}
      let(:fresh_publish) {Publish.new(:state => 'fresh')}

      it "review может пользователь с ролью корректор" do
        Ability.new(corrector).should be_able_to(:accept, fresh_review)
        Ability.new(publisher).should_not be_able_to(:accept, fresh_review)
      end

      it "publish может пользователь с ролью публикатора" do
        Ability.new(publisher).should be_able_to(:accept, fresh_publish)
        Ability.new(corrector).should_not be_able_to(:accept, fresh_publish)
      end
    end

    describe "закрыть" do
      let(:processing_prepare_task) { Prepare.new(:state => 'processing', :executor => initiator) }
      let(:processing_review_task)  { Review.new(:state => 'processing', :executor => initiator) }
      let(:processing_publish_task) { Publish.new(:state => 'processing', :executor => initiator) }

      before { set_current_user initiator }

      describe "может исполнитель" do
        it { ability.should be_able_to(:complete, processing_prepare_task) }
        it { ability.should be_able_to(:complete, processing_review_task) }
        it { ability.should be_able_to(:complete, processing_publish_task) }
      end

      describe "не может другой пользователь" do
        before { set_current_user corrector }

        it { ability.should_not be_able_to(:complete, processing_prepare_task) }
        it { ability.should_not be_able_to(:complete, processing_review_task) }
        it { ability.should_not be_able_to(:complete, processing_publish_task) }
      end

      describe "нельзя, если состояние не processing" do
        it { ability.should_not be_able_to(:complete, Task.new(:state => :pending)) }
        it { ability.should_not be_able_to(:complete, Task.new(:state => :fresh)) }
      end
    end

    describe "подготовления черновика" do
      describe "возобновить" do
        it "может исполнитель" do
          ability(:for => initiator).should be_able_to(:restore, fresh_correcting.prepare)
        end
        it "не может другой пользователь" do
          ability(:for => another_initiator(:roles => [:corrector, :publisher])).should_not be_able_to(:restore, fresh_correcting.prepare)
        end
      end
    end

    describe "публикации" do
      describe "может возобновить" do
        it "любой публикатор" do
          ability(:for => another_publisher).should be_able_to(:restore, published.publish )
        end
      end
      describe "не может возобновить" do
        it { ability(:for => corrector).should_not be_able_to(:restore, published.publish) }
        it { ability(:for => initiator).should_not be_able_to(:restore, published.publish) }
      end
    end

    describe "редактирования" do
      it "может любой корректор" do
        ability(:for => another_corrector).should be_able_to(:restore, fresh_publishing.review)
      end
    end

    describe 'подзадачу' do
      it "может создать пользователь выполняющий задачу" do
        ability(:for => corrector).should be_able_to(:create, processing_correcting.review.subtasks.build(:issue => processing_correcting.review))
      end

      it "не может создать пользователь, не выполняющий задачу" do
        ability(:for => initiator).should_not be_able_to(:create, processing_correcting.review.subtasks.build(:issue => processing_correcting.review))
      end

      it "может отменить автор" do
        subtask = processing_correcting.review.subtasks.create! :initiator => corrector
        ability(:for => corrector).should be_able_to(:cancel, subtask)
      end

      it "может отвергнуть исполнитель" do
        subtask = processing_correcting.review.subtasks.create! :executor => initiator
        ability(:for => initiator).should be_able_to(:refuse, subtask)
      end
    end
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
