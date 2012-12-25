module Manage::News::EntryHelper

  def will_be_destroed_in(entry)
    distance = (entry.deleted_at + 1.month - Time.zone.now)
    return nil if distance < 0
    %w[day hour minute].each do |measure|
      interval = 1.send(measure)
      return I18n.t("destroy_entry_in_days", :count => (distance/interval).ceil) if distance >= interval
    end
    return I18n.t("destroy_entry_less_minute")
  end

end
