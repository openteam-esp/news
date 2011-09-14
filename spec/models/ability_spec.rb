# encoding: utf-8

require "spec_helper"


describe Ability do
  let(:ability) { Ability.new }

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

    describe 'возобновить' do
      before { set_current_user initiator }

      it "может исполнитель" do
        correcting_with_tasks.prepare.state = 'completed'
        correcting_with_tasks.review.state = 'fresh'
        ability.should be_able_to(:restore, correcting_with_tasks.prepare)
      end

      it "не может другой пользователь" do
        set_current_user corrector
        correcting_with_tasks.prepare.state = 'completed'
        ability.should_not be_able_to(:restore, correcting_with_tasks.prepare)
      end

      it "можно если нет следующей задачи" do
        set_current_user publisher
        published_with_tasks.publish.executor = publisher
        published_with_tasks.publish.state = 'completed'
        ability.should be_able_to(:restore, published_with_tasks.publish )
      end

      it "review может любой корректор" do
        set_current_user corrector
        publishing_with_tasks.review.state = 'completed'
        publishing_with_tasks.publish.state = 'fresh'
        ability.should be_able_to(:restore, publishing_with_tasks.review)
      end

      it "publish может любой публикатор" do
        set_current_user publisher
        published_with_tasks.publish.state = 'completed'
        ability.should be_able_to(:restore, published_with_tasks.publish )
      end

      describe 'нельзя' do
        it "если состояние не completed" do
          ability.should_not be_able_to(:restore, correcting_with_tasks.prepare)
        end

        it "если следующая задача не fresh" do
          correcting_with_tasks.prepare.state = 'completed'
          %w[processing completed].each do |next_task_state|
            correcting_with_tasks.review.state = next_task_state
            ability.should_not be_able_to(:restore, correcting_with_tasks.prepare)
          end
        end
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
