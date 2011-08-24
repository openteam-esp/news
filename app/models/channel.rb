class Channel < ActiveRecord::Base
  has_many :recipients
  has_and_belongs_to_many :entries

  def published_entries
    entries.state(:published).order 'updated_at desc'
  end
end


# == Schema Information
#
# Table name: channels
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

