class Channel < ActiveRecord::Base

  attr_accessor :polymorphic_context

  belongs_to :context

  has_many :recipients
  has_and_belongs_to_many :entries, :uniq => true

  validates_presence_of :title, :context, :polymorphic_context

  before_validation :set_context_and_parent
  before_save :set_ancestry_path
  before_save :set_title_path

  after_update :set_subtree_weights, :if => :weight_changed?

  default_scope order(:weight)

  scope :without_entries, where('entry_type IS NULL')

  has_ancestry

  has_enums

  def absolute_depth
    depth + context.depth + 1
  end

  def as_json(options)
    super(:only => [:id, :title, :entry_type, :description], :methods => :depth)
  end

  alias_attribute :to_s, :title

  def polymorphic_context_value
    "#{self.class.name.underscore}_#{self.id}"
  end

  def disabled_contexts
    [self.polymorphic_context_value] + descendants.map(&:polymorphic_context_value) unless new_record?
  end

  def selected_context
    parent ? parent.polymorphic_context_value : context ? context.polymorphic_context_value : nil
  end

  protected

    def set_context_and_parent
      context_type, context_id = polymorphic_context.split('_')
      self.parent = nil

      case context_type
        when 'context'
          self.parent_id = nil
          self.context_id = context_id
        when 'channel'
          self.parent_id = context_id
          self.context_id = parent.context_id
        end
    end

    def set_ancestry_path
      if parent
        self.weight = parent.weight + '/' + ((parent.children - [self]).last.try(:next_position) || '00')
      else
        self.weight = context.subcontexts.where(:ancestry => nil).last.try(:next_position) || '00'
      end
    end

    def set_title_path
      self.title_path = [parent.try(:title_path), title].compact.join('/')
    end

    def next_position
      sprintf('%02d', [position + 1, 99].min)
    end

    def position
      weight.split('/').last.to_i
    end

    def set_subtree_weights
      self.reload.descendants.each do |channel|
        channel.update_attributes! :polymorphic_context => channel.parent ? channel.parent.polymorphic_context_value : channel.context.polymorphic_context_value
      end
    end
end



# == Schema Information
#
# Table name: channels
#
#  id          :integer         not null, primary key
#  deleted_at  :datetime
#  context_id  :integer
#  ancestry    :string(255)
#  title       :string(255)
#  weight      :text
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  entry_type  :string(255)
#  title_path  :text
#  description :text
#

