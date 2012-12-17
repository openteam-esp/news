class Channel < ActiveRecord::Base

  attr_accessor :polymorphic_context

  belongs_to :context

  has_many :recipients
  has_and_belongs_to_many :entries, :uniq => true

  validates_presence_of :title

  before_save :set_ancestry_path
  before_save :set_title_path

  after_update :set_subtree_weights, :if => :weight_changed?

  default_scope order(:weight)

  scope :without_entries, where('entry_type IS NULL')

  scope :with_manager_permissions_for, ->(user) {
    context_ids = user.permissions.for_role(:manager).pluck('distinct context_id')
    where(:id => Channel.where(:id => context_ids).flat_map(&:subtree_ids))
  }

  has_ancestry

  has_enums

  audited

  def absolute_depth
    dept = depth + 1
    dept += parent.depth if parent
    dept
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

    def set_ancestry_path
      self.weight = '00'
      self.weight = parent.weight + '/' + ((parent.children - [self]).last.try(:next_position) || '00') if parent
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
#  ancestry    :string(255)
#  context_id  :integer
#  created_at  :datetime         not null
#  deleted_at  :datetime
#  description :text
#  entry_type  :string(255)
#  id          :integer          not null, primary key
#  title       :string(255)
#  title_path  :text
#  updated_at  :datetime         not null
#  weight      :text
#

