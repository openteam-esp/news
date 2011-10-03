require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)

every(1.minutes, 'trash.clean')  { Entry.stale.delete_all }
