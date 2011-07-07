# encoding: utf-8

require 'spec_helper'

describe Entry do

  let :entry do Fabricate :entry end
  let :awaiting_correction_entry do entry.send_to_corrector!; entry end
  let :correcting_entry do awaiting_correction_entry.correct!; entry end
  let :awaiting_publication_entry do correcting_entry.send_to_publisher!; entry end
  let :published_entry do awaiting_publication_entry.publish!; entry end

  describe "после создания" do
    it "должно появится событие 'новость создана'" do
      entry.events.first.type.should == 'created'
    end

    it "статус должен быть draft" do
      entry.should be_draft
    end

    it "можно отправить корректору" do
      entry.state_events.should eql [:send_to_corrector]
    end
  end

  describe "после отправки на корректуру" do
    it "должно появится событие 'отправлено на корректуру'" do
      awaiting_correction_entry.events.last.type.should eql 'send_to_corrector'
    end

    it "возможны переходы 'корректировать' и 'вернуть автору'" do
      awaiting_correction_entry.state_events.should eql [:correct, :return_to_author]
    end

    describe "после возвращения на доработку" do

      let :returned_to_author_entry do awaiting_correction_entry.return_to_author!; awaiting_correction_entry end

      it "должно появиться соответствующее событие" do
        returned_to_author_entry.events.last.type.should == 'return_to_author'
      end

      it "новость должна стать черновиком" do
        returned_to_author_entry.should be_draft
      end
    end
  end

  describe "после взятия на корректуру" do

    it "должно появиться событие" do
      correcting_entry.events.last.type.should == 'correct'
    end

    it "возможны переходы 'отправить публикатору'" do
      correcting_entry.state_events.should eql [:send_to_publisher]
    end
  end


  describe "после отправки публикатору" do
    it "должно появиться событие 'отправлено на публикацию'" do
      awaiting_publication_entry.events.last.type.should eql 'send_to_publisher'
    end

    it "возможны переходы 'опубликовать' и 'вернуть корректору'" do
      awaiting_publication_entry.state_events.should == [:publish, :return_to_corrector]
    end
  end

  describe "после публикации" do
    it "должно после событие 'опубликовано'" do
      published_entry.events.last.type.should eql 'publish'
    end

    it "возможны переходы 'вернуть корректору'" do
      published_entry.state_events.should == [:return_to_corrector]
    end
  end

end
