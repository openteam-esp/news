class EntryMailer < ActionMailer::Base
  default :from => "no-reply@openteam.ru"

  def entry_mailing(entry)
    @entry = entry
    mail(:to => '*', :subject => @entry.title)
  end
end
