class EntryMailer < ActionMailer::Base
  default :from => Settings[:smtp_settings][:default_from]

  def entry_mailing(entry)
    @entry = entry
    mail(:to => Settings[:smtp_settings][:default_to], :subject => @entry.title)
  end
end
