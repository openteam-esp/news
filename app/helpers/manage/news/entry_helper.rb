module Manage::News::EntryHelper

  def will_be_destroed_in(entry)
    if (distance = entry.will_be_destroyed_at - DateTime.now) > 0
      %w[day hour minute].each do |measure|
        interval = 1.send(measure)
        return I18n.t("destroy_entry_in_days", :count => (distance/interval).ceil) if distance >= interval
      end
      return I18n.t("destroy_entry_less_minute")
    end
  end
end
