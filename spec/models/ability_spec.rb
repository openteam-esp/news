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
      describe "создать" do
        it "может пользователь выполняющий задачу" do
          ability(:for => initiator).should be_able_to(:create, draft.prepare.subtasks.build(:issue => draft.prepare))
        end
        it "не может другой пользователь" do
          ability(:for => corrector).should_not be_able_to(:create, draft.prepare.subtasks.build(:issue => draft.prepare))
        end
      end

      describe "принять" do
        it {ability(:for => another_initiator).should be_able_to(:accept, prepare_subtask_for(another_initiator))}
        it {ability(:for => corrector).should_not be_able_to(:cancel, prepare_subtask_for(another_initiator))}
      end

      describe "отменить" do
        it {ability(:for => initiator).should be_able_to(:cancel, prepare_subtask_for(corrector))}
        it {ability(:for => corrector).should_not be_able_to(:cancel, prepare_subtask_for(corrector))}
      end

      describe "отвергнуть" do
        it {ability(:for => initiator).should_not be_able_to(:refuse, prepare_subtask_for(corrector))}
        it {ability(:for => corrector).should be_able_to(:refuse, prepare_subtask_for(corrector))}
      end
    end
  end

  describe "на entries" do
    def mock_participation(participation = true)
      User.current.should_receive(:takes_participation_on?).with(draft).any_number_of_times.and_return(participation)
    end

    describe "draft" do
      shared_examples_for "не может управлять черновиком" do
        it { ability.should_not be_able_to(:read, draft) }
        it { ability.should_not be_able_to(:update, draft) }
        it { ability.should_not be_able_to(:destroy, draft) }
        it { ability.should_not be_able_to(:recycle, deleted_draft) }
      end

      describe "initiator" do
        before { set_current_user initiator }
        it { ability.should be_able_to(:create, Entry.new) }
        it { ability.should be_able_to(:read, draft) }
        it { ability.should be_able_to(:update, draft) }
        it { ability.should be_able_to(:destroy, draft) }
        it { ability.should be_able_to(:recycle, deleted_draft) }
      end

      describe "another_initiator" do
        before { set_current_user another_initiator }
        it_behaves_like "не может управлять черновиком"
      end

      describe "anonymous" do
        it { ability.should_not be_able_to(:create, Entry.new)}
        it_behaves_like "не может управлять черновиком"
      end

      describe "corrector" do
        before { set_current_user corrector_and_publisher }
        it_behaves_like "не может управлять черновиком"
      end
    end

    shared_examples_for "может только просматривать" do
      it { ability.should be_able_to(:read, entry) }
      it { ability.should_not be_able_to(:update, entry) }
      it { ability.should_not be_able_to(:destroy, entry) }
    end

    shared_examples_for "все могут только просматривать" do
      describe "initiator" do
        before { set_current_user initiator }
        it_behaves_like "может только просматривать"
      end
      describe "corrector" do
        before { set_current_user initiator }
        it_behaves_like "может только просматривать"
      end
      describe "publisher" do
        before { set_current_user publisher }
        it_behaves_like "может только просматривать"
      end
    end

    shared_examples_for "может управлять" do
      it { ability.should be_able_to(:read, entry) }
      it { ability.should be_able_to(:update, entry) }
      it { ability.should be_able_to(:destroy, entry) }
    end

    describe "fresh correcting" do
      let(:entry) { fresh_correcting }
      it_behaves_like "все могут только просматривать"
    end

    describe "processing correcting" do
      let(:entry) { processing_correcting }
      describe "initiator" do
        before { set_current_user initiator }
        it_behaves_like "может только просматривать"
      end

      describe "corrector" do
        before { set_current_user corrector }
        it_behaves_like "может управлять"
      end

      describe "other corrector" do
        before { set_current_user another_corrector }
        it_behaves_like "может только просматривать"
      end
    end

    describe "fresh publishing" do
      let(:entry) { fresh_publishing }
      it_behaves_like "все могут только просматривать"
    end

    describe "processing publishing" do
      let(:entry) { processing_publishing }
      describe "initiator" do
        before { set_current_user initiator }
        it_behaves_like "может только просматривать"
      end

      describe "corrector" do
        before { set_current_user corrector }
        it_behaves_like "может только просматривать"
      end

      describe "publisher" do
        before { set_current_user publisher }
        it_behaves_like "может управлять"
      end

      describe "other publisher" do
        before { set_current_user another_publisher }
        it_behaves_like "может только просматривать"
      end
    end

    describe "published" do
      let(:entry) { published }
      it_behaves_like "все могут только просматривать"
      it { ability.should be_able_to(:read, entry) }
    end

    describe "locked entry" do
      before do
        as corrector do
          prepare_subtask_for(corrector).accept
          draft.lock
        end
      end
      it { ability(:for => corrector).should be_able_to(:update, draft) }
      it { ability(:for => corrector).should_not be_able_to(:destroy, draft) }
      it { ability(:for => initiator).should_not be_able_to(:update, draft) }
      it { ability(:for => initiator).should_not be_able_to(:destroy, draft) }
    end

    describe "deleted entry" do
      let(:entry) {as publisher do processing_publishing.destroy end}
      it_behaves_like "все могут только просматривать"
    end

  end

  describe "на assets" do
    describe "создавать" do
      describe "может исполнитель выполняемой задачи" do
        it { ability(:for => initiator).should be_able_to(:create, draft.assets.build)}
        it { ability(:for => corrector).should be_able_to(:create, processing_correcting.assets.build)}
        it { ability(:for => publisher).should be_able_to(:create, processing_publishing.assets.build)}
      end
      it "может исполнитель подзадачи" do
        as another_initiator do prepare_subtask_for(another_initiator).accept end
        ability(:for => another_initiator).should be_able_to(:create, draft.assets.build)
      end

      describe "не может другой пользователь" do

      end

      describe "нельзя если новость удалены" do

      end

      describe "нельзя если новость заблокирована другим пользователем" do

      end

    end
  end

end
