class AddYoutubeToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :youtube_code, :string
  end
end
