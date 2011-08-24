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

  before do
    @corrector_role = Fabricate(:role, :kind => 'corrector')
    @publisher_role = Fabricate(:role, :kind => 'publisher')
  end

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
    (1..3).each do | number |
      Fabricate(:entry, :title => "Entry-#{number}", :created_at => Time.new + number.second )
    end
    entries = Entry.all
    entries[0].title.should == "Entry-3"
    entries[1].title.should == "Entry-2"
    entries[2].title.should == "Entry-1"
  end

  it 'должна корректно сохранять и отображать дату' do
    I18n.l(draft_entry(:since => "19.07.2011 09:20").since, :format => :datetime).should == "19.07.2011 09:20"
  end

  it 'должна знать кто к ней имеет отношение' do
    first_user = Fabricate(:user)
    second_user = Fabricate(:user)
    second_user.roles << @corrector_role
    second_user.roles << @publisher_role
    User.current = first_user
    entry = Fabricate(:entry)
    entry.related_to(first_user).should be_true
    entry.related_to(second_user).should be_false
  end

  describe 'после создания должна' do
    it 'иметь статус "черновик"' do
      draft_entry.should be_draft
    end
  end

  describe 'после отправки корректору должна' do

    it 'иметь событие со статусом "отправлена корректору"' do
      awaiting_correction_entry.events.first.kind.should eql 'request_correcting'
    end

    it 'иметь статус "ожидает корректировки"' do
      awaiting_correction_entry.reload.should be_awaiting_correction
    end
  end

  describe 'после отправки публикатору должна' do
    it 'иметь статус "ожидает публикации"' do
      awaiting_publication_entry.reload.should be_awaiting_publication
    end
  end

  describe 'после возвращения инициатору должна' do
    it 'иметь статус "черновик"' do
      returned_to_author_entry.should be_draft
    end
  end

  describe 'после взятия на корректуру должна' do
    it 'иметь статус "корректируется"' do
      correcting_entry.reload.should be_correcting
    end
  end

  describe 'после возвращения корректору должна' do
    it 'иметь статус "ожидает корректировки"' do
      returned_to_corrector_entry.reload.should be_awaiting_correction
    end
  end

  describe 'после публикации должна' do
    it 'иметь статус "опубликована"' do
      published_entry.reload.should be_published
    end
  end

  describe 'после удаления в корзину должна' do
    it 'иметь статус "помещена в корзину"' do
      trashed_entry.reload.should be_trash
    end
  end

  describe 'после восстановления должна' do
    it 'иметь статус "черновик"' do
      untrashed_entry.should be_draft
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

