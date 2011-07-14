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

  [:inbox, :published, :correcting, :draft, :trash].each do |method_name|
    define_method "#{method_name}?" do
      self.title == method_name.to_s
    end
  end
end
