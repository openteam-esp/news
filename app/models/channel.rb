class Channel < ActiveRecord::Base
  extend FriendlyId

  has_many :recipients
  has_and_belongs_to_many :entries, :uniq => true

  friendly_id :title, :use => :slugged

  def published_entries
    #entries.published.order 'updated_at desc'
    []
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
#  slug       :string(255)
#

