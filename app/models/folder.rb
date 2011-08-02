class Folder < ActiveRecord::Base

  has_many :entries

  def self.find_by_title(folder_id)
    where(:title => folder_id).first
  end

  def to_param
    title
  end

  [:awaiting_correction, :awaiting_publication, :published, :correcting, :draft, :trash].each do |method_name|
    define_method "#{method_name}?" do
      self.title == method_name.to_s
    end
  end
end

# == Schema Information
#
# Table name: folders
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

