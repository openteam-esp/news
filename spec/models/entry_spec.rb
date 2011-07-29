# encoding: utf-8

require 'spec_helper'

describe Entry do
  it 'должна корректно сохранять и отображать дату' do
    entry = Fabricate(:entry)
    entry.since = "19.07.2011 09:20"
    entry.save!
    I18n.l(entry.since, :format => :datetime).should eql "19.07.2011 09:20"
  end

  it 'должна знать кто к ней имеет отношение' do
    first_user = Fabricate(:user)
    second_user = Fabricate(:user, :roles => ['corrector', 'publisher'])
    entry = Fabricate(:entry, :user_id => first_user.id)
    entry.related_to(first_user).should be_true
    entry.related_to(second_user).should be_false
  end

  describe 'после создания должна' do
    let :new_entry do Fabricate(:entry) end

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
      entry = Fabricate(:entry)
      entry.events.create!(:kind => 'send_to_corrector')
      entry.events.create!(:kind => 'correct')
      entry
    end

    before(:each) do
      Fabricate(:folder, :title => 'correcting')
      entry.update_attribute(:title, 'Updated!!')
    end

    it 'иметь событие со статусом "новость изменена"' do
      entry.events.first.kind.should eql 'updated'
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
      entry = Fabricate(:entry)
      entry.events.create(:kind => 'send_to_corrector')
      entry
    end
    before do Fabricate(:folder, :title => 'inbox') end

    it 'иметь событие со статусом "отправлена корректору"' do
      awaiting_correction_entry.events.first.kind.should eql 'send_to_corrector'
    end

    it 'иметь статус "ожидает корректировки"' do
      awaiting_correction_entry.reload.should be_awaiting_correction
    end

    it 'появиться в папке "Входящие"' do
      awaiting_correction_entry.reload.folder.title.should eql 'inbox'
    end
  end

  describe 'после отправки публикатору должна' do
    let :awaiting_publication_entry do
      entry = Fabricate(:entry)
      entry.events.create(:kind => 'send_to_corrector')
      entry.events.create(:kind => 'correct')
      entry.events.create(:kind => 'send_to_publisher')
      entry
    end
    before do Fabricate(:folder, :title => 'inbox') end

    it 'иметь событие со статусом "отправлена публикатору"' do
      awaiting_publication_entry.events.first.kind.should eql 'send_to_publisher'
    end

    it 'иметь статус "ожидает публикации"' do
      awaiting_publication_entry.reload.should be_awaiting_publication
    end

    it 'появиться в папке "Входящие"' do
      awaiting_publication_entry.reload.folder.title.should eql 'inbox'
    end
  end

  describe 'после возвращения инициатору должна' do
    let :returned_to_author_entry do
      entry = Fabricate(:entry)
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
      entry = Fabricate(:entry)
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
      entry = Fabricate(:entry)
      entry.events.create(:kind => 'send_to_corrector')
      entry.events.create(:kind => 'correct')
      entry.events.create(:kind => 'send_to_publisher')
      entry.events.create(:kind => 'return_to_corrector')
      entry
    end
    before do Fabricate(:folder, :title => 'inbox') end

    it 'иметь событие со статусом "возвращена корректору"' do
      returned_to_corrector_entry.events.first.kind.should eql 'return_to_corrector'
    end

    it 'иметь статус "ожидает корректировки"' do
      returned_to_corrector_entry.reload.should be_awaiting_correction
    end

    it 'появиться в папке "Входящие"' do
      returned_to_corrector_entry.reload.folder.title.should eql 'inbox'
    end
  end

  describe 'после публикации должна' do
    let :published_entry do
      entry = Fabricate(:entry)
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
      entry = Fabricate(:entry)
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
      entry = Fabricate(:entry)
      entry.events.create(:kind => 'to_trash')
      entry.events.create(:kind => 'restore')
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
      entry = Fabricate(:entry)
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
      entry = Fabricate(:entry)
      entry.events.create(:kind => 'immediately_send_to_publisher')
      entry
    end
    before do Fabricate(:folder, :title => 'inbox') end

    it 'иметь событие со статусом "ожидает публикации"' do
      immediately_sended_to_publisher_entry.events.first.kind.should eql 'immediately_send_to_publisher'
    end

    it 'иметь статус "ожидает публикации"' do
      immediately_sended_to_publisher_entry.reload.should be_awaiting_publication
    end

    it 'появиться в папке "Входящие"' do
      immediately_sended_to_publisher_entry.reload.folder.title.should eql 'inbox'
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
#  deleted      :boolean
#  author       :string(255)
#  initiator_id :integer
#  folder_id    :integer
#  created_at   :datetime
#  updated_at   :datetime
#

