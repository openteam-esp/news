# encoding: utf-8
require 'spec_helper'

describe Review do
  describe "авторизованный пользователь с ролями публикатора и корректора может выполнять" do
    describe "закрытие" do
      before { as corrector do processing_correcting.review.complete! end }
      it { processing_correcting.should be_publishing }
      it { processing_correcting.publish.should be_fresh }
    end

    describe 'отказ от выполнения' do
      before { as corrector do processing_correcting.review.refuse! end }
      it { processing_correcting.review.should be_fresh }
      it { processing_correcting.should be_correcting }
    end

    describe "восстановление" do
      before { as corrector do fresh_publishing.review.restore! end }
      it { fresh_publishing.should be_correcting }
      it { fresh_publishing.publish.should be_pending }
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
#  deleted_at   :datetime
#

