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
      require 'ryba'
      @updated_entry ||=  draft.tap do | entry |
                            entry.update_attributes :author => Ryba::Name.full_name
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
      it { last_event.user.should == initiator }
      it { last_event.event.should == 'complete' }
      it { last_event.versioned_entry.author.should == updated_entry.author }
    end
  end
end




# == Schema Information
#
# Table name: events
#
#  id               :integer         not null, primary key
#  event            :string(255)
#  text             :text
#  entry_id         :integer
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  serialized_entry :text
#  task_id          :integer
#

