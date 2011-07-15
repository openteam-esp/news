class EntryMailer < ActionMailer::Base
  default :from => Settings[:smtp_settings][:default_from]

  def entry_mailing(entry, channels)
    @entry = entry

    if channels.empty?
      mail(
            :to => Settings[:smtp_settings][:default_to],
             :subject => @entry.title
          )
    else
      channels.each do |channel|
        channel.recipients.each do |recipient|
          mail(
            :to => recipient.email,
            :subject => @entry.title
          )
        end if channel.recipients.any?
      end
    end
  end
end
