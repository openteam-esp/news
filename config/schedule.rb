require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)

every(1.days, 'trash.clean', :at => "00:00")  { Entry.trash.where("created_at < ?", Time.now - 30.days).destroy_all }