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

  it 'должна корректно сохранять и отображать дату' do
    entry = Fabricate(:entry, :user_id => Fabricate(:user))
    entry.since = "19.07.2011 09:20"
    entry.save!
    I18n.l(entry.since, :format => :datetime).should eql "19.07.2011 09:20"
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

  it 'должна знать кто к ней имеет отношение' do
    first_user = Fabricate(:user)
    second_user = Fabricate(:user)
    second_user.roles << @corrector_role
    second_user.roles << @publisher_role
    entry = Fabricate(:entry, :user_id => first_user.id)
    entry.related_to(first_user).should be_true
    entry.related_to(second_user).should be_false
  end

  describe 'после создания должна' do
    let :new_entry do Fabricate(:entry, :user_id => Fabricate(:user)) end

    before do Fabricate(:folder, :title => 'draft') end

    it 'иметь событие со статусом "новость создана"' do
      new_entry.events.last.kind.should eql 'created'
    end

    it 'иметь статус "черновик"' do
      new_entry.should be_draft
    end

    it 'появиться в папке "Черновики"' do
      new_entry.folder.title.should eql 'draft'
    end
  end

  describe 'после редактирования должна' do
    let :entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create!(:kind => 'send_to_corrector')
      entry.events.create!(:kind => 'correct')
      entry
    end

    before(:each) do
      Fabricate(:folder, :title => 'correcting')
      entry.update_attribute(:title, 'Updated!!')
    end

    it 'иметь событие со статусом "новость изменена"' do
      entry.reload.events.first.kind.should eql 'updated'
    end

    it 'сохранять статус' do
      entry.reload.should be_correcting
    end

    it 'оставаться в той же папке' do
      entry.reload.folder.title.should eql 'correcting'
    end
  end

  describe 'после отправки корректору должна' do
    let :awaiting_correction_entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create(:kind => 'send_to_corrector')
      entry
    end
    before do Fabricate(:folder, :title => 'awaiting_correction') end

    it 'иметь событие со статусом "отправлена корректору"' do
      awaiting_correction_entry.events.first.kind.should eql 'send_to_corrector'
    end

    it 'иметь статус "ожидает корректировки"' do
      awaiting_correction_entry.reload.should be_awaiting_correction
    end

    it 'появиться в папке "Ожидающие корректировки"' do
      awaiting_correction_entry.reload.folder.title.should eql 'awaiting_correction'
    end
  end

  describe 'после отправки публикатору должна' do
    let :awaiting_publication_entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create(:kind => 'send_to_corrector')
      entry.events.create(:kind => 'correct')
      entry.events.create(:kind => 'send_to_publisher')
      entry
    end
    before do
      Fabricate(:folder, :title => 'awaiting_correction')
      Fabricate(:folder, :title => 'awaiting_publication')
    end

    it 'иметь событие со статусом "отправлена публикатору"' do
      awaiting_publication_entry.events.first.kind.should eql 'send_to_publisher'
    end

    it 'иметь статус "ожидает публикации"' do
      awaiting_publication_entry.reload.should be_awaiting_publication
    end

    it 'появиться в папке "Входящие"' do
      awaiting_publication_entry.reload.folder.title.should eql 'awaiting_publication'
    end
  end

  describe 'после возвращения инициатору должна' do
    let :returned_to_author_entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create(:kind => 'send_to_corrector')
      entry.events.create(:kind => 'return_to_author')
      entry
    end
    before do Fabricate(:folder, :title => 'draft') end

    it 'иметь событие со статусом "возвращена инициатору"' do
      returned_to_author_entry.events.first.kind.should eql 'return_to_author'
    end

    it 'иметь статус "черновик"' do
      returned_to_author_entry.should be_draft
    end

    it 'появиться в папке "Черновики"' do
      returned_to_author_entry.reload.folder.title.should eql 'draft'
    end
  end

  describe 'после взятия на корректуру должна' do
    let :correcting_entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create(:kind => 'send_to_corrector')
      entry.events.create(:kind => 'correct')
      entry
    end
    before do Fabricate(:folder, :title => 'correcting') end

    it 'иметь событие со статусом "взята на корректуру"' do
      correcting_entry.events.first.kind.should eql 'correct'
    end

    it 'иметь статус "корректируется"' do
      correcting_entry.reload.should be_correcting
    end

    it 'появиться в папке "На корректуре"' do
      correcting_entry.reload.folder.title.should eql 'correcting'
    end
  end

  describe 'после возвращения корректору должна' do
    let :returned_to_corrector_entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create(:kind => 'send_to_corrector')
      entry.events.create(:kind => 'correct')
      entry.events.create(:kind => 'send_to_publisher')
      entry.events.create(:kind => 'return_to_corrector')
      entry
    end
    before do
      Fabricate(:folder, :title => 'awaiting_correction')
      Fabricate(:folder, :title => 'awaiting_publication')
    end

    it 'иметь событие со статусом "возвращена корректору"' do
      returned_to_corrector_entry.events.first.kind.should eql 'return_to_corrector'
    end

    it 'иметь статус "ожидает корректировки"' do
      returned_to_corrector_entry.reload.should be_awaiting_correction
    end

    it 'появиться в папке "Ожидающие корректировки"' do
      returned_to_corrector_entry.reload.folder.title.should eql 'awaiting_correction'
    end
  end

  describe 'после публикации должна' do
    let :published_entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create(:kind => 'send_to_corrector')
      entry.events.create(:kind => 'correct')
      entry.events.create(:kind => 'send_to_publisher')
      entry.events.create(:kind => 'publish')
      entry
    end
    before do Fabricate(:folder, :title => 'published') end

    it 'иметь событие со статусом "опубликована"' do
      published_entry.reload.events.first.kind.should eql 'publish'
    end

    it 'иметь статус "опубликована"' do
      published_entry.reload.should be_published
    end

    it 'появиться в папке "Опубликованные"' do
      published_entry.reload.folder.title.should eql 'published'
    end
  end

  describe 'после удаления в корзину должна' do
    let :trashed_entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create(:kind => 'to_trash')
      entry
    end
    before do Fabricate(:folder, :title => 'trash') end

    it 'иметь событие со статусом "помещена в корзину"' do
      trashed_entry.events.first.kind.should eql 'to_trash'
    end

    it 'иметь статус "помещена в корзину"' do
      trashed_entry.reload.should be_trash
    end

    it 'появиться в папке "Корзина"' do
      trashed_entry.reload.folder.title.should eql 'trash'
    end
  end

  describe 'после восстановления должна' do
    let :restored_entry do
      user = Fabricate(:user)
      entry = Fabricate(:entry, :user_id => user.id)
      entry.events.create(:kind => 'to_trash')
      entry.events.create(:kind => 'restore', :user => user)
      entry
    end
    before do Fabricate(:folder, :title => 'draft') end

    it 'иметь событие со статусом "восстановлена"' do
      restored_entry.events.first.kind.should eql 'restore'
    end

    it 'иметь статус "черновик"' do
      restored_entry.should be_draft
    end

    it 'появиться в папке "Черновики"' do
      restored_entry.reload.folder.title.should eql 'draft'
    end
  end

  describe 'после немедленной публикации должна' do
    let :immediately_published_entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create(:kind => 'immediately_publish')
      entry
    end
    before do Fabricate(:folder, :title => 'published') end

    it 'иметь событие со статусом "опубликована"' do
      immediately_published_entry.events.first.kind.should eql 'immediately_publish'
    end

    it 'иметь статус "опубликована"' do
      immediately_published_entry.reload.should be_published
    end

    it 'появиться в папке "Опубликованные"' do
      immediately_published_entry.reload.folder.title.should eql 'published'
    end
  end

  describe 'после немедленной отправки публикатору должна' do
    let :immediately_sended_to_publisher_entry do
      entry = Fabricate(:entry, :user_id => Fabricate(:user))
      entry.events.create(:kind => 'immediately_send_to_publisher')
      entry
    end
    before do
      Fabricate(:folder, :title => 'awaiting_correction')
      Fabricate(:folder, :title => 'awaiting_publication')
    end

    it 'иметь событие со статусом "ожидает публикации"' do
      immediately_sended_to_publisher_entry.events.first.kind.should eql 'immediately_send_to_publisher'
    end

    it 'иметь статус "ожидает публикации"' do
      immediately_sended_to_publisher_entry.reload.should be_awaiting_publication
    end

    it 'появиться в папке "Ожидающие публикации"' do
      immediately_sended_to_publisher_entry.reload.folder.title.should eql 'awaiting_publication'
    end
  end
end




# == Schema Information
#
# Table name: entries
#
#  id                :integer         not null, primary key
#  title             :text
#  annotation        :text
#  body              :text
#  since             :datetime
#  until             :datetime
#  state             :string(255)
#  deleted           :boolean
#  author            :string(255)
#  initiator_id      :integer
#  folder_id         :integer
#  created_at        :datetime
#  updated_at        :datetime
#  old_id            :integer
#  old_channel_id    :integer
#  serialized_assets :text
#

