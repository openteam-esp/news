class Channel < ActiveRecord::Base
  attr_accessible :title, :parent_id

  has_many :recipients
  has_and_belongs_to_many :entries, :uniq => true

  validates_presence_of :title

  has_ancestry

  before_save :set_ancestry_path
  before_save :set_title_path
  after_update :set_subtree_weights, :if => :weight_changed?, :unless => :ancestry_callbacks_disabled?

  default_scope order(:weight)

  scope :without_entries, where('entry_type IS NULL')

  has_enums

  audited

  # TODO: rewrite with squeel sifter
  scope :subtree_for, ->(user) {
    channel_table = Channel.arel_table
    Channel.where(
      channel_table[:id].in(user.root_channels.map(&:id)).or(
        channel_table[:ancestry].matches_any(user.root_channels.map{|c| "#{c.child_ancestry}/%"})
      )
    )
  }

  def as_json(options)
    super(:only => [:id, :title, :entry_type, :description], :methods => :depth)
  end

  alias_attribute :to_s, :title

  protected

    def set_ancestry_path
      if parent
        self.weight = parent.weight + '/' + ((parent.children - [self]).last.try(:next_position) || '00')
      else
        if root = Channel.roots.last
          self.weight = sprintf "%02d", root.weight.to_i + 1
        else
          self.weight = '00'
        end
      end
    end

  private

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
          descendant.set_ancestry_path
          descendant.save
        end
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

