Channel.find_or_create_by :title => "tomsk.gov.ru/news"
Channel.find_or_create_by :title => "tomsk.gov.ru/announces"

Folder.find_or_create_by :title => 'inbox'
Folder.find_or_create_by :title => 'published'
Folder.find_or_create_by :title => 'correcting'
Folder.find_or_create_by :title => 'draft'
Folder.find_or_create_by :title => 'trash'

corrector = User.find_or_create_by :email => 'corrector@demo.de'
corrector.update_attributes(
  :password => '123123',
  :password_confirmation => '123123',
  :name => 'corrector',
  :roles => ['corrector']
)

publisher = User.find_or_create_by :email => 'publisher@demo.de'
publisher.update_attributes(
  :password => '123123',
  :password_confirmation => '123123',
  :name => 'publisher',
  :roles => ['publisher']
)

user = User.find_or_create_by :email => 'user@demo.de'
user.update_attributes(
  :password => '123123',
  :password_confirmation => '123123',
  :name => 'user'
)
