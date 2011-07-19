class EntryMailer < ActionMailer::Base
  default :from => Settings['smtp_settings.default_from']

  def entry_mailing(entry, channels)
    @entry = entry

    channels.each do |channel|
      channel.recipients.each do |recipient|
        mail(:to => recipient.email, :subject => @entry.title)
      end
    end
  end
end
