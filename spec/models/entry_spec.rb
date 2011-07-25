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
      new_entry.events.first.type.should eql 'created'
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
      entry.events.create(:type => 'send_to_corrector')
      entry.events.create(:type => 'correct')
      entry
    end
    before do
      Fabricate(:folder, :title => 'correcting')
      entry.update_attribute(:title, 'Updated!!')
    end

    it 'иметь событие со статусом "новость изменена"' do
      entry.events.last.type.should eql 'updated'
    end

    it 'сохранять статус' do
      entry.should be_correcting
    end

    it 'оставаться в той же папке' do
      entry.folder.title.should eql 'correcting'
    end
  end

  describe 'после отправки корректору должна' do
    let :awaiting_correction_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'send_to_corrector')
      entry
    end
    before do Fabricate(:folder, :title => 'inbox') end

    it 'иметь событие со статусом "отправлена корректору"' do
      awaiting_correction_entry.events.last.type.should eql 'send_to_corrector'
    end

    it 'иметь статус "ожидает корректировки"' do
      awaiting_correction_entry.should be_awaiting_correction
    end

    it 'появиться в папке "Входящие"' do
      awaiting_correction_entry.folder.title.should eql 'inbox'
    end
  end

  describe 'после отправки публикатору должна' do
    let :awaiting_publication_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'send_to_corrector')
      entry.events.create(:type => 'correct')
      entry.events.create(:type => 'send_to_publisher')
      entry
    end
    before do Fabricate(:folder, :title => 'inbox') end

    it 'иметь событие со статусом "отправлена публикатору"' do
      awaiting_publication_entry.events.last.type.should eql 'send_to_publisher'
    end

    it 'иметь статус "ожидает публикации"' do
      awaiting_publication_entry.should be_awaiting_publication
    end

    it 'появиться в папке "Входящие"' do
      awaiting_publication_entry.folder.title.should eql 'inbox'
    end
  end

  describe 'после возвращения инициатору должна' do
    let :returned_to_author_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'send_to_corrector')
      entry.events.create(:type => 'return_to_author')
      entry
    end
    before do Fabricate(:folder, :title => 'draft') end

    it 'иметь событие со статусом "возвращена инициатору"' do
      returned_to_author_entry.events.last.type.should eql 'return_to_author'
    end

    it 'иметь статус "черновик"' do
      returned_to_author_entry.should be_draft
    end

    it 'появиться в папке "Черновики"' do
      returned_to_author_entry.folder.title.should eql 'draft'
    end
  end

  describe 'после взятия на корректуру должна' do
    let :correcting_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'send_to_corrector')
      entry.events.create(:type => 'correct')
      entry
    end
    before do Fabricate(:folder, :title => 'correcting') end

    it 'иметь событие со статусом "взята на корректуру"' do
      correcting_entry.events.last.type.should eql 'correct'
    end

    it 'иметь статус "корректируется"' do
      correcting_entry.should be_correcting
    end

    it 'появиться в папке "На корректуре"' do
      correcting_entry.folder.title.should eql 'correcting'
    end
  end

  describe 'после возвращения корректору должна' do
    let :returned_to_corrector_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'send_to_corrector')
      entry.events.create(:type => 'correct')
      entry.events.create(:type => 'send_to_publisher')
      entry.events.create(:type => 'return_to_corrector')
      entry
    end
    before do Fabricate(:folder, :title => 'inbox') end

    it 'иметь событие со статусом "возвращена корректору"' do
      returned_to_corrector_entry.events.last.type.should eql 'return_to_corrector'
    end

    it 'иметь статус "ожидает корректировки"' do
      returned_to_corrector_entry.should be_awaiting_correction
    end

    it 'появиться в папке "Входящие"' do
      returned_to_corrector_entry.folder.title.should eql 'inbox'
    end
  end

  describe 'после публикации должна' do
    let :published_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'send_to_corrector')
      entry.events.create(:type => 'correct')
      entry.events.create(:type => 'send_to_publisher')
      entry.events.create(:type => 'publish')
      entry
    end
    before do Fabricate(:folder, :title => 'published') end

    it 'иметь событие со статусом "опубликована"' do
      published_entry.events.last.type.should eql 'publish'
    end

    it 'иметь статус "опубликована"' do
      published_entry.should be_published
    end

    it 'появиться в папке "Опубликованные"' do
      published_entry.folder.title.should eql 'published'
    end
  end

  describe 'после удаления в корзину должна' do
    let :trashed_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'to_trash')
      entry
    end
    before do Fabricate(:folder, :title => 'trash') end

    it 'иметь событие со статусом "помещена в корзину"' do
      trashed_entry.events.last.type.should eql 'to_trash'
    end

    it 'иметь статус "помещена в корзину"' do
      trashed_entry.should be_trash
    end

    it 'появиться в папке "Корзина"' do
      trashed_entry.folder.title.should eql 'trash'
    end
  end

  describe 'после восстановления должна' do
    let :restored_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'to_trash')
      entry.events.create(:type => 'restore')
      entry
    end
    before do Fabricate(:folder, :title => 'draft') end

    it 'иметь событие со статусом "восстановлена"' do
      restored_entry.events.last.type.should eql 'restore'
    end

    it 'иметь статус "черновик"' do
      restored_entry.should be_draft
    end

    it 'появиться в папке "Черновики"' do
      restored_entry.folder.title.should eql 'draft'
    end
  end

  describe 'после немедленной публикации должна' do
    let :immediately_published_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'immediately_publish')
      entry
    end
    before do Fabricate(:folder, :title => 'published') end

    it 'иметь событие со статусом "опубликована"' do
      immediately_published_entry.events.last.type.should eql 'immediately_publish'
    end

    it 'иметь статус "опубликована"' do
      immediately_published_entry.should be_published
    end

    it 'появиться в папке "Опубликованные"' do
      immediately_published_entry.folder.title.should eql 'published'
    end
  end

  describe 'после немедленной отправки публикатору должна' do
    let :immediately_sended_to_publisher_entry do
      entry = Fabricate(:entry)
      entry.events.create(:type => 'immediately_send_to_publisher')
      entry
    end
    before do Fabricate(:folder, :title => 'inbox') end

    it 'иметь событие со статусом "ожидает публикации"' do
      immediately_sended_to_publisher_entry.events.last.type.should eql 'immediately_send_to_publisher'
    end

    it 'иметь статус "ожидает публикации"' do
      immediately_sended_to_publisher_entry.should be_awaiting_publication
    end

    it 'появиться в папке "Входящие"' do
      immediately_sended_to_publisher_entry.folder.title.should eql 'inbox'
    end
  end

  describe 'опубликованная новость должна иметь' do
    it 'заголовок'
    it 'аннотацию'
    it 'текст'
  end
end
