# encoding: utf-8

require 'spec_helper'

describe DestroyEntryJob do
  describe "у удалённой новости" do
    let(:job) { deleted_draft.destroy_entry_job }
    it { job.should be_a(Delayed::Backend::ActiveRecord::Job) }
    it { job.should be_persisted }
    it "после выполнения удаляет новость" do
      Entry.should_receive(:find).with(deleted_draft.id).and_return(deleted_draft)
      deleted_draft.should_receive :destroy_without_trash
      job.invoke_job
    end
  end
  describe "у черновика" do
    it { draft.destroy_entry_job.should be_nil }
  end
  describe "у восстановленной новости" do
    before { @job = deleted_draft.destroy_entry_job; @entry = deleted_draft.recycle }
    it { @job.should_not be_persisted }
    it { @entry.destroy_entry_job.should be_nil }
  end
end
