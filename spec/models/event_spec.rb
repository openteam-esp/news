# encoding: utf-8

require 'spec_helper'

describe Event do

  it { should belong_to :entry }
  it { should belong_to :task }
  it { should belong_to :user }
  it { should validate_presence_of :entry }
  it { should validate_presence_of :task }
  it { should validate_presence_of :user }

  describe "должен создаваться" do
    def updated_entry(options={})
      @updated_entry ||=  draft.tap do | entry |
                            entry.update_attributes({:author => 'Сидорова Анна Матвеевна'}, :without_protection => true)
                            entry.prepare.complete!
                          end
    end

    it "при создании новости" do
      draft.events.map(&:event).should == ['accept']
    end

    describe "при закрытии задачи" do
      def last_event(options={})
        @last_event ||= updated_entry(options).events(true).first
      end

      it { updated_entry.events.should have(2).items }
      it { last_event.user.should == initiator_of(channel) }
      it { last_event.event.should == 'complete' }
      it { last_event.versioned_entry.author.should == updated_entry.author }
    end
  end
end

# == Schema Information
#
# Table name: events
#
#  created_at       :datetime         not null
#  entry_id         :integer
#  event            :string(255)
#  id               :integer          not null, primary key
#  serialized_entry :text
#  task_id          :integer
#  text             :text
#  updated_at       :datetime         not null
#  user_id          :integer
#

