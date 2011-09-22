# encoding: utf-8
require 'spec_helper'

describe Prepare do
  describe "авторизованный пользователь с ролями публикатора и корректора может выполнять" do
    before { User.current = initiator(:roles => [:corrector, :publisher]) }
    describe "закрытие" do
      it { fresh_correcting.should be_correcting }
      it { fresh_correcting.review.should be_fresh }
    end

    describe "восстановление" do
      before { fresh_correcting.prepare.restore! }
      it { fresh_correcting.should be_draft }
      it { fresh_correcting.review.should be_pending }
    end
  end

end



# == Schema Information
#
# Table name: tasks
#
#  id           :integer         not null, primary key
#  entry_id     :integer
#  initiator_id :integer
#  executor_id  :integer
#  state        :string(255)
#  type         :string(255)
#  comment      :text
#  created_at   :datetime
#  updated_at   :datetime
#  issue_id     :integer
#  description  :text
#

