class AddChannelCodeToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :channel_code, :string
  end
end
