# encoding: utf-8

class Entry < ActiveRecord::Base
  belongs_to :initiator, :class_name => 'User'
  belongs_to :locked_by, :class_name => 'User'

  has_and_belongs_to_many :channels, :conditions => {:deleted_at => nil}

  has_many :events, :validate => false
  has_many :assets, :conditions => {:deleted_at => nil}
  has_many :attachments, :conditions => {:deleted_at => nil}
  has_many :audios, :conditions => {:deleted_at => nil}
  has_many :images, :conditions => {:deleted_at => nil}
  has_many :videos, :conditions => {:deleted_at => nil}
  has_many :tasks, :dependent => :destroy

  has_one :prepare
  has_one :review
  has_one :publish

  attr_accessor :locking

  after_validation :unlock, :if => :need_unlock?

  state_machine :initial => :draft do
    state :draft
    state :correcting
    state :publishing
    state :published do
      validates_presence_of :title, :body, :channels
    end

    event :up do
      transition :draft => :correcting, :correcting => :publishing, :publishing => :published
    end

    event :down do
      transition :published => :publishing, :publishing => :correcting, :correcting => :draft
    end
  end

  scope :ordered, order('id desc')

  default_scope not_deleted.ordered


  scope :self_initiated, lambda { where(:initiator_id => User.current_id) }

  scope :by_state, lambda { |state|
    if state.to_s == 'processing'
      where(:state => processing_states)
    else
      where(:state => state)
    end
  }

  scope :state, lambda { |state|
    if User.current.roles.empty? || state.to_s == 'draft'
      by_state(state).self_initiated
    else
      by_state(state)
    end
  }

  after_create :create_tasks

  accepts_nested_attributes_for :assets, :reject_if => :all_blank, :allow_destroy => true

  default_value_for :initiator do User.current end

  searchable do
    text   :title,      :boost => 3.0
    text   :annotation, :boost => 2.0
    text   :body,       :boost => 1.0
    date   :since
    date   :until
    string :state
    integer :channel_ids, :multiple => true
  end

  def current_user
    User.current
  end

  def self.all_states
    state_machine.states.map(&:name)
  end

  def self.shared_states
    all_states - owned_states
  end

  def self.owned_states
    ['draft']
  end

  def self.processing_states
    %w[correcting publishing]
  end

  delegate :publisher?, :corrector?, :to => :current_user, :prefix => true

  def current_user_initiator?
    initiator == current_user
  end

  def current_user_participant?
    current_user_initiator? || events.where(:user_id => current_user).any?
  end

  def current_user_is_a?(*args)
    args.map{|role| self.send("current_user_#{role}?")}.uniq.compact == [true]
  end

  def restore(*args)
    super
    self.assets.destroy_all
    if entry = events.offset(1).first.try(:versioned_entry)
      self.update_attributes entry.attributes.merge(:channel_ids => entry.channel_ids)
      self.assets.unscoped.where(:id => entry.image_ids + entry.video_ids + entry.audio_ids + entry.attachment_ids).update_all(:deleted_at => nil)
    else
      self.update_attributes Entry.new.attributes.merge(:channel_ids => [])
    end
  end

  def lock
    self.locking = true
    update_attributes! :locked_at => DateTime.now, :locked_by => User.current
  end

  def locked?
    self.locked_at?
  end

  def need_unlock?
    !self.locking && self.locked?
  end

  def unlock
    self.locked_at = nil
    self.locked_by = nil
  end

  private
    def create_tasks
      create_prepare :initiator => initiator, :entry => self, :executor => initiator
      create_review :initiator => initiator, :entry => self
      create_publish :initiator => initiator, :entry => self
    end
end




# == Schema Information
#
# Table name: entries
#
#  id           :integer         not null, primary key
#  title        :text
#  annotation   :text
#  body         :text
#  since        :datetime
#  until        :datetime
#  state        :string(255)
#  author       :string(255)
#  initiator_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  legacy_id    :integer
#  locked_at    :datetime
#  locked_by_id :integer
#  deleted_at   :datetime
#

