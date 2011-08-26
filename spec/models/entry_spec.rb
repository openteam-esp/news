# encoding: utf-8

require 'spec_helper'

describe Entry do

  it { should have_many(:assets) }
  it { should have_many(:images) }
  it { should have_many(:videos) }
  it { should have_many(:audios) }
  it { should have_many(:attachments) }

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
        Entry.owned_states.each do |state|
          Entry.state(state).where_values_hash.should == {:state => state, :initiator_id => user.id}
        end
      end
    end

    it "папки корректора и публикатора для новостей в процесса" do
      [corrector, publisher].each do |user|
        set_current_user(user)
        Entry.shared_states.each do |state|
          Entry.state(state).where_values_hash.should == {:state => state}
        end
      end
    end

  end

  describe "собственные новости" do
    describe "инициатора" do
      before(:each) do
        set_current_user initiator
      end
      it { draft.permitted_events.should == [:request_correcting, :store, :discard ] }
      it { awaiting_correction.permitted_events.should == [:request_reworking, :discard] }
      it { correcting.permitted_events.should == [] }
      it { awaiting_publication.permitted_events.should == [] }
      it { publicating.permitted_events.should == [] }
      it { published.permitted_events.should == [] }
      it { trash.permitted_events.should == [:recover] }
    end

    describe "корректора и инициатора" do
      before(:each) do
        set_current_user initiator(:roles => [:corrector])
      end
      it { draft.permitted_events.should == [:request_publicating, :request_correcting, :store, :discard] }
      it { awaiting_correction.permitted_events.should == [:accept_correcting, :request_reworking, :discard] }
      it { correcting.permitted_events.should == [:request_publicating, :store, :request_reworking, :discard] }
      it { awaiting_publication.permitted_events.should == [:accept_correcting, :discard] }
      it { publicating.permitted_events.should == [] }
      it { published.permitted_events.should == [] }
      it { trash.permitted_events.should == [:recover, :accept_correcting] }
    end

    describe "публикатора и инициатора" do
      before(:each) do
        set_current_user initiator(:roles => [:publisher])
      end
      it { draft.permitted_events.should == [:publish, :request_correcting, :store, :discard]}
      it { awaiting_correction.permitted_events.should == [:request_reworking, :discard]}
      it { correcting.permitted_events.should == []}
      it { awaiting_publication.permitted_events.should == [:accept_publicating, :request_correcting, :discard]}
      it { publicating.permitted_events.should == [:publish, :request_correcting, :store, :discard] }
      it { published.permitted_events.should == [:store, :discard] }
      it { trash.permitted_events.should == [:recover, :accept_publicating] }
    end

    describe "инициатора корректора и публикатора" do
      before(:each) do
        set_current_user initiator(:roles => [:corrector, :publisher])
      end
      it { draft.permitted_events.should == [:publish, :request_publicating, :request_correcting, :store, :discard]}
      it { awaiting_correction.permitted_events.should == [:accept_correcting, :request_reworking, :discard]}
      it { correcting.permitted_events.should == [:publish, :request_publicating, :store, :request_reworking, :discard]}
      it { awaiting_publication.permitted_events.should == [:accept_publicating, :request_correcting, :accept_correcting, :discard]}
      it { publicating.permitted_events.should == [:publish, :request_correcting, :store, :discard] }
      it { published.permitted_events.should == [:store, :discard] }
      it { trash.permitted_events.should == [:recover, :accept_publicating, :accept_correcting] }
    end
  end

  describe "чужие новости" do
    describe "другого пользователя" do
      before(:each) do
        set_current_user another_initiator
      end
      it { draft.permitted_events.should == [] }
      it { awaiting_correction.permitted_events.should == [] }
      it { correcting.permitted_events.should == [] }
      it { awaiting_publication.permitted_events.should == [] }
      it { publicating.permitted_events.should == [] }
      it { published.permitted_events.should == [] }
      it { trash.permitted_events.should == [] }
    end

    describe "корректора" do
      before(:each) do
        set_current_user another_initiator(:roles => [:corrector])
      end
      it { draft.permitted_events.should == [] }
      it { awaiting_correction.permitted_events.should == [:accept_correcting, :request_reworking, :discard] }
      it { correcting.permitted_events.should == [:request_publicating, :store, :request_reworking, :discard] }
      it { awaiting_publication.permitted_events.should == [:accept_correcting, :discard] }
      it { publicating.permitted_events.should == [] }
      it { published.permitted_events.should == [] }
      it { trash.permitted_events.should == [] }
      it { discard(awaiting_correction).permitted_events.should == [:recover, :accept_correcting] }
    end

    describe "публикатора" do
      before(:each) do
        set_current_user another_initiator(:roles => [:publisher])
      end
      it { draft.permitted_events.should == []}
      it { awaiting_correction.permitted_events.should == []}
      it { correcting.permitted_events.should == []}
      it { awaiting_publication.permitted_events.should == [:accept_publicating, :request_correcting, :discard]}
      it { publicating.permitted_events.should == [:publish, :request_correcting, :store, :discard] }
      it { published.permitted_events.should == [:store, :discard] }
      it { trash.permitted_events.should == [] }
      it { discard(awaiting_publication).permitted_events.should == [:recover, :accept_publicating] }
    end

    describe "публикатора и корректора" do
      before(:each) do
        set_current_user another_initiator(:roles => [:corrector, :publisher])
      end
      it { draft.permitted_events.should == []}
      it { awaiting_correction.permitted_events.should == [:accept_correcting, :request_reworking, :discard]}
      it { correcting.permitted_events.should == [:request_publicating, :store, :request_reworking, :discard]}
      it { awaiting_publication.permitted_events.should == [:accept_publicating, :request_correcting, :accept_correcting, :discard]}
      it { publicating.permitted_events.should == [:publish, :request_correcting, :store, :discard] }
      it { published.permitted_events.should == [:store, :discard] }
      it { trash.permitted_events.should == [] }
      it { discard(awaiting_publication).permitted_events.should == [:recover, :accept_publicating, :accept_correcting] }
    end
  end
end







# == Schema Information
#
# Table name: entries
#
#  id             :integer         not null, primary key
#  title          :text
#  annotation     :text
#  body           :text
#  since          :datetime
#  until          :datetime
#  state          :string(255)
#  author         :string(255)
#  initiator_id   :integer
#  created_at     :datetime
#  updated_at     :datetime
#  old_id         :integer
#  old_channel_id :integer
#

