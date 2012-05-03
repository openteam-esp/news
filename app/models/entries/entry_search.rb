class EntrySearch < Search
  column :keywords,       :text
  column :since_lt,       :date
  column :since_gt,       :date
  column :channel_ids,    :string
  column :order_by,       :string
  column :per_page,       :integer
  column :state,          :string
  column :deleted,        :boolean
  column :updated_at_gt,  :date

  column :interval_year,  :integer
  column :interval_month, :integer

  column :entry_type,     :string
  column :events_type,    :string

  has_enum :order_by

  attr_protected :state

  default_value_for :state, 'published'
  default_value_for :order_by, 'since desc'
  default_value_for :channel_ids do Channel.scoped.pluck(:id) - Channel.without_entries.pluck('id') end

  def channel_ids
    self[:channel_ids].map(&:to_i) if self[:channel_ids]
  end

  def min_since_event_datetime
    self.order_by = 'event_entry_properties_since asc'
    self.per_page = 1

    if entry = results.try(:first)
      entry.event_entry_properties.try(:first).try(:since) if entry.is_a?(EventEntry)
    else
      DateTime.now
    end
  end

  def max_until_event_datetime
    self.order_by = 'event_entry_properties_until desc'
    self.per_page = 1

    if entry = results.try(:first)
      entry.event_entry_properties.try(:first).try(:until) if entry.is_a?(EventEntry)
    else
      DateTime.now
    end
  end

  protected

    def is_archive?
      interval_year && interval_month
    end

    def additional_search(search)
      search.with(:actuality_expired_at).less_than(DateTime.now) if entry_type == 'announcements' && !is_archive?

      case events_type
      when 'current'
        self.order_by = 'event_entry_properties_since asc'
        search.with(:event_entry_properties_since).less_than(DateTime.now)
        search.with(:event_entry_properties_until).greater_than(DateTime.now)
      when 'gone'
        self.order_by = 'event_entry_properties_until desc'
        search.with(:event_entry_properties_until).less_than(DateTime.now)
      when 'coming'
        self.order_by = 'event_entry_properties_since asc'
        search.with(:event_entry_properties_since).greater_than(DateTime.now)
      when 'current_coming'
        self.order_by = 'event_entry_properties_since asc'
        search.any_of do
          with(:event_entry_properties_since).greater_than(DateTime.now)
          with(:event_entry_properties_until).greater_than(DateTime.now)
        end
      end if entry_type == 'events'

      archive_interval(search) if is_archive?
    end


    def archive_interval(search)
      case entry_type
      when 'news', 'announcements'
        search.all_of do
          with(:since).greater_than(interval_start)
          with(:since).less_than(interval_end)
        end

      when 'events'
        search.any_of do
          all_of do
            with(:event_entry_properties_since).greater_than(interval_start)
            with(:event_entry_properties_since).less_than(interval_end)
          end

          all_of do
            with(:event_entry_properties_until).greater_than(interval_start)
            with(:event_entry_properties_until).less_than(interval_end)
          end
        end
      end
    end

    def interval_start
      Time.local(interval_year, interval_month, 1)
    end

    def interval_end
      interval_start.end_of_month
    end

    def search_columns
      @entry_search_columns ||= super.reject{ |c| c.match /^(interval_|entry_|events_)/ }
    end
end

# == Schema Information
#
# Table name: searches
#
#  keywords       :text
#  since_lt       :date
#  since_gt       :date
#  channel_ids    :string
#  order_by       :string
#  per_page       :integer
#  state          :string
#  deleted        :boolean
#  updated_at_gt  :date
#  interval_year  :integer
#  interval_month :integer
#  interval_type  :string
#  keywords       :text
#  since_lt       :date
#  since_gt       :date
#  channel_ids    :string
#  order_by       :string
#  per_page       :integer
#  state          :string
#  deleted        :boolean
#  updated_at_gt  :date
#  interval_year  :integer
#  interval_month :integer
#  interval_type  :string
#

