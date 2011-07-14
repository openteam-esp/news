class Folder
  include Mongoid::Document

  field :title, :type => String

  has_many :entries

  def self.find_by_title(folder_id)
    where(:title => folder_id).first
  end

  def to_param
    title
  end
end
