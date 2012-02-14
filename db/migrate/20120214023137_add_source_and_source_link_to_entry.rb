class AddSourceAndSourceLinkToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :source, :string

    add_column :entries, :source_link, :string

  end
end
