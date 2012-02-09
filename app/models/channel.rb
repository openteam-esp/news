class Channel < ActiveRecord::Base

  attr_accessor :polymorphic_context

  belongs_to :context

  has_many :recipients
  has_and_belongs_to_many :entries, :uniq => true

  validates_presence_of :title, :context, :polymorphic_context

  before_validation :set_context_and_parent
  before_save :set_ancestry_path

  default_scope order(:weight)

  has_ancestry

  alias_method :ancestry_depth, :depth

  def depth
    ancestry_depth + context.depth + 1
  end

  alias_attribute :to_s, :title

  protected

    def set_context_and_parent
      context_type, context_id = polymorphic_context.split('_')
      case context_type
      when 'context'
        self.context_id = context_id
      when 'channel'
        self.parent_id = context_id
        self.context_id = parent.context_id
      end
    end

    def set_ancestry_path
      if parent
        self.weight = parent.weight + "/" + (parent.children.last.try(:next_position) || "00")
      else
        self.weight = context.subcontexts.where(:ancestry => nil).last.try(:next_position) || "00"
      end
    end

    def next_position
      sprintf("%02d", [position + 1, 99].min)
    end

    def position
      weight.split('/').last.to_i
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

