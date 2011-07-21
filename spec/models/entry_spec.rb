# encoding: utf-8

require 'spec_helper'

describe Entry do
  before do
    @draft = Fabricate(:folder, :title => 'draft')
    @inbox = Fabricate(:folder, :title => 'inbox')
    @correcting = Fabricate(:folder, :title => 'correcting')
    @published = Fabricate(:folder, :title => 'published')
    @trash = Fabricate(:folder, :title => 'trash')
  end

  let :entry do Fabricate(:entry) end
  let :awaiting_correction_entry do entry.send_to_corrector!; entry end
  let :returned_to_author_entry do awaiting_correction_entry.return_to_author!; entry end
  let :correcting_entry do awaiting_correction_entry.correct!; entry end
  let :awaiting_publication_entry do correcting_entry.send_to_publisher!; entry end
  let :published_entry do awaiting_publication_entry.publish!; entry end
  let :trash_entry do awaiting_publication_entry.to_trash!; entry end

  describe "дата публикации" do
    it "должна корректно проставляться и отображаться" do
      entry.since = "19.07.2011 09:20"
      entry.save!
      I18n.l(entry.since, :format => :datetime).should eql "19.07.2011 09:20"
    end
  end

  describe "после создания" do
    it "должно появится событие 'новость создана'" do
      entry.events.first.type.should == 'created'
    end

    it "статус должен быть draft" do
      entry.should be_draft
    end

    it "доступны следующие действия" do
      entry.state_events.should eql [:immediately_publish, :immediately_send_to_publisher, :send_to_corrector, :to_trash]
    end

    it 'должна быть в папке draft' do
      entry.folder.title.should eql 'draft'
    end
  end

  describe 'после редактирования' do
    it 'должно появиться событие updated' do
      entry.update_attribute(:title, 'ololo')
      entry.events.last.type.should == 'updated'
    end
  end

  describe "после отправки на корректуру" do
    it "возможны переходы 'корректировать' и 'вернуть автору'" do
      awaiting_correction_entry.state_events.should eql [:correct, :return_to_author, :to_trash]
    end

    it 'должна быть в папке inbox' do
      awaiting_correction_entry.folder.title.should eql 'inbox'
    end
  end

  describe "после возвращения на доработку" do
    it "новость должна стать черновиком" do
      returned_to_author_entry.should be_draft
    end

    it 'должна быть в папке draft' do
      returned_to_author_entry.folder.title.should eql 'draft'
    end
  end

  describe "после взятия на корректуру" do
    it "возможны переходы 'отправить публикатору'" do
      correcting_entry.state_events.should eql [:send_to_publisher]
    end

    it 'должна быть в папке correcting' do
      correcting_entry.folder.title.should eql 'correcting'
    end
  end

  describe "после отправки публикатору" do
    it "возможны переходы 'опубликовать' и 'вернуть корректору'" do
      awaiting_publication_entry.state_events.should == [:publish, :return_to_corrector, :to_trash]
    end

    it 'должна быть в папке draft' do
      entry.folder.title.should eql 'draft'
    end
  end

  describe "после публикации" do
    it "возможны переходы 'вернуть корректору'" do
      published_entry.state_events.should == [:return_to_corrector]
    end

    it 'должна быть в папке published' do
      published_entry.folder.title.should eql 'published'
    end
  end

  describe "после удаления" do
    it 'должна быть в папке trash' do
      trash_entry.folder.title.should eql 'trash'
    end
  end

  describe 'пользователи' do
    before do
      @joe = Fabricate(:user)
      @chandler = Fabricate(:user)

      @entry = Fabricate(:entry, :user_id => @joe.id)
    end

    it 'могут оперировать только со своими новостями' do
      @entry.state_events_for_user(@joe).should eql [:send_to_corrector, :to_trash]
      @entry.state_events_for_user(@chandler).should be_empty
    end
  end
end
