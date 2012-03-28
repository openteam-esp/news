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
  column :interval_type,  :string

  has_enum :order_by

  attr_protected :state

  default_value_for :state, 'published'
  default_value_for :order_by, 'since desc'
  default_value_for :channel_ids do Channel.scoped.pluck(:id) - Channel.without_entries.pluck('id') end

  def channel_ids
    self[:channel_ids].map(&:to_i) if self[:channel_ids]
  end

  protected
    def additional_search(search)
      return unless interval_type

      events_in_interval(search)

      case interval_type
        when 'gone'
          search.with(:event_entry_properties_until).less_than(DateTime.now)
        when 'current'
          search.with(:event_entry_properties_since).less_than(DateTime.now)
          search.with(:event_entry_properties_until).greater_than(DateTime.now)
        when 'coming'
          search.with(:event_entry_properties_since).greater_than(DateTime.now)
      end
    end

    def events_in_interval(search)
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

    def interval_start
      Time.local(interval_year, interval_month, 1)
    end

    def interval_end
      interval_start.end_of_month
    end

    def search_columns
      @entry_search_columns ||= super.reject{|c| c.starts_with?('interval_')}
    end
end

# == Schema Information
#
# Table name: searches
#
#  keywords                        :text
#  since_lt                        :date
#  since_gt                        :date
#  channel_ids                     :string
#  order_by                        :string
#  per_page                        :integer
#  state                           :string
#  deleted                         :boolean
#  updated_at_gt                   :date
#  event_entry_properties_since_lt :datetime
#  event_entry_properties_since_gt :datetime
#  event_entry_properties_until_lt :datetime
#  event_entry_properties_until_gt :datetime
#  keywords                        :text
#  since_lt                        :date
#  since_gt                        :date
#  channel_ids                     :string
#  order_by                        :string
#  per_page                        :integer
#  state                           :string
#  deleted                         :boolean
#  updated_at_gt                   :date
#  event_entry_properties_since_lt :datetime
#  event_entry_properties_since_gt :datetime
#  event_entry_properties_until_lt :datetime
#  event_entry_properties_until_gt :datetime
#

