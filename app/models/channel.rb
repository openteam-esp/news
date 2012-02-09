class Channel < ActiveRecord::Base

  attr_accessor :polymorphic_context

  belongs_to :context

  has_many :recipients
  has_and_belongs_to_many :entries, :uniq => true

  validates_presence_of :title, :polymorphic_context

  before_validation :set_context

  default_scope order('ancestry_depth').order('title')

  has_ancestry :cache_depth => true

  def depth
    ancestry_depth + context.depth + 1
  end

  alias_attribute :to_s, :title

  protected

    def set_context
      context_type, context_id = polymorphic_context.split('_')
      if context_type == 'context'
        self.context_id = context_id
      else
        self.parent_id = context_id
        self.context_id = parent.context_id
      end
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

