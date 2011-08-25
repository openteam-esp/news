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
    I18n.l(draft_entry(:since => "19.07.2011 09:20").since, :format => :datetime).should == "19.07.2011 09:20"
  end

  it 'должна знать кто к ней имеет отношение' do
    first_user = Fabricate(:user)
    second_user = Fabricate(:user)
    second_user.roles << corrector_role
    second_user.roles << publisher_role
    User.current = first_user
    entry = Fabricate(:entry)
    entry.related_to(first_user).should be_true
    entry.related_to(second_user).should be_false
  end

  it 'переходы по состояниям' do
    set_current_user
    %w[draft awaiting_correction correcting awaiting_publication publicating published trash].each do | state |
      self.send("#{state}_entry").state.should == state.to_s
    end
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

  describe "удаление" do
    it "аттача" do
      pending
      draft_entry_with_asset.assets.first.destroy
      draft_entry_with_asset.events.first.versioned_entry.assets.count.should == 0
    end

    it "физическое удаление новости должно приводить к удалению всех assets и events" do
      pending
      draft_entry_with_asset
    end
  end

  describe "возможные действия для" do
    describe "пользователя" do
      before(:each) do
        set_current_user(initiator)
      end
      it { draft_entry.permitted_events.should == [:request_correcting, :store, :to_trash ] }
      it { awaiting_correction_entry.permitted_events.should == [:request_reworking, :to_trash] }
      it { correcting_entry.permitted_events.should == [] }
      it { awaiting_publication_entry.permitted_events.should == [] }
      it { publicating_entry.permitted_events.should == [] }
      it { published_entry.permitted_events.should == [] }
      it { trash_entry.permitted_events.should == [ :untrash ] }
    end

    describe "редактора" do
      before(:each) do
        set_current_user(corrector)
      end
      it { draft_entry.permitted_events.should == [:request_publicating, :request_correcting, :store, :to_trash] }
      it { awaiting_correction_entry.permitted_events.should == [:accept_correcting, :request_reworking, :to_trash] }
      it { correcting_entry.permitted_events.should == [:request_publicating, :store, :request_reworking, :to_trash] }
      it { awaiting_publication_entry.permitted_events.should == [:to_trash] }
      it { publicating_entry.permitted_events.should == [] }
      it { published_entry.permitted_events.should == [] }
      it { trash_entry.permitted_events.should == [:untrash, :accept_correcting] }
    end

    describe "публикатора" do
      before(:each) do
        set_current_user(publisher)
      end
      it { draft_entry.permitted_events.should == [:publish, :request_correcting, :store, :to_trash]}
      it { awaiting_correction_entry.permitted_events.should == [:request_reworking, :to_trash]}
      it { correcting_entry.permitted_events.should == [:publish]}
      it { awaiting_publication_entry.permitted_events.should == [:accept_publicating, :request_correcting, :to_trash]}
      it { publicating_entry.permitted_events.should == [:publish, :request_correcting, :store, :to_trash] }
      it { published_entry.permitted_events.should == [:store, :to_trash] }
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

