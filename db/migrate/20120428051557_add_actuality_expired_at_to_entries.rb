class AddActualityExpiredAtToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :actuality_expired_at, :datetime

  end
end
