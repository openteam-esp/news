class EntryMailer < ActionMailer::Base
  default :from => Settings['smtp_settings.default_from']

  def entry_mailing(entry, channels)
    @published_entry = entry

    channels.each do |channel|
      channel.recipients.active.each do |recipient|
        mail(
          :to => recipient.email,
          :subject => @published_entry.title
        )
      end
    end
  end
end
