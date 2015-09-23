# encoding: utf-8
# == Schema Information
#
# Table name: channels
#
#  id          :integer          not null, primary key
#  deleted_at  :datetime
#  ancestry    :string(255)
#  title       :string(255)
#  weight      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entry_type  :string(255)
#  title_path  :text
#  description :text
#

class Channel < ActiveRecord::Base
  attr_accessible :title, :parent_id, :entry_type, :description

  has_many :recipients
  has_and_belongs_to_many :entries, :uniq => true

  validates_presence_of :title

  before_save :set_weight, :if => :need_set_weight?
  before_save :set_title_path

  after_update :set_subtree_weights, :if => :weight_changed?, :unless => :ancestry_callbacks_disabled?

  scope :without_entries,   -> { where('entry_type IS NULL') }
  scope :ordered_by_weight, -> { order(:weight) }
  scope :for_entry,         ->(entry) { joins(:entry).where('entry.id' => entry) }

  def self.roots_for(user, options={})
    roles = options[:role] || Permission.available_roles
    if user.permissions.for_context(nil).for_role(roles).any?
      roots
    else
      user.root_channels.where(:permissions => {:role => roles})
    end
  end

  def self.subtrees_of(channels)
    channel_table = Channel.arel_table
    Channel.where(
      channel_table[:id].in(channels.map(&:id))
        .or(channel_table[:ancestry].in(channels.map(&:child_ancestry)))
        .or(channel_table[:ancestry].matches_any(channels.map{|c| "#{c.child_ancestry}/%"}))
    )
  end

  def self.subtree_for(user, options={})
    subtrees_of(roots_for(user, options)).ordered_by_weight
  end

  def self.arrange_as_array(options={}, hash=nil)
    hash ||= arrange(options)

    arr = []
    hash.each do |node, children|
      arr << node
      arr += arrange_as_array(options, children) unless children.empty?
    end
    arr
  end

  has_enums

  acts_as_tree

  audited

  def as_json(options)
    super(:only => [:id, :title, :entry_type, :description], :methods => [:depth, :archive_dates])
  end

  def archive_dates
    {
      :min_date => entries.minimum(:since),
      :max_date => entries.maximum(:since)
    }
  end

  alias_attribute :to_s, :title

  protected

    def set_weight
      if parent
        self.weight = parent.weight + '/' + next_position_for((parent.children.ordered_by_weight - [self]).last)
      else
        self.weight = next_position_for(Channel.roots.ordered_by_weight.last)
      end
    end

  private

    def next_position_for(channel_or_nil)
      channel_or_nil.try(:next_position) || '00'
    end

    def need_set_weight?
      ancestry_changed? || !weight?
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

    # Update descendants with new weight
    # Skip this if callbacks are disabled
    # If node is not a new record and weight was updated and the new ancestry is sane ...
    def set_subtree_weights
      # ... for each descendant ...
      reload.send(:unscoped_descendants).each do |descendant|
        # ... replace old weight with new weight
        descendant.without_ancestry_callbacks do
          descendant.set_weight
          descendant.save
        end
      end
    end
end
