Channel.find_or_create_by_title('tomsk.gov.ru/ru/announces')
Channel.find_or_create_by_title('tomsk.gov.ru/ru/news')
c = Channel.find_or_create_by_title('mailing_lists/common')
c.recipients.find_or_create_by_email('gmyzind@gmail.com')
Channel.find_or_create_by_title('mailing_lists/innovation')

corrector = User.find_or_create_by_email('corrector@demo.de')
corrector.update_attributes(
  :password => '123123',
  :password_confirmation => '123123',
  :name => 'corrector',
  :roles => [:corrector]
)


publisher = User.find_or_create_by_email('publisher@demo.de')
publisher.update_attributes(
  :password => '123123',
  :password_confirmation => '123123',
  :name => 'publisher',
  :roles => [:publisher]
)

user = User.find_or_create_by_email('user@demo.de')
user.update_attributes(
  :password => '123123',
  :password_confirmation => '123123',
  :name => 'user'
)

corrector_and_publisher = User.find_or_create_by_email('cp@demo.de')
corrector_and_publisher.update_attributes(
  :password => '123123',
  :password_confirmation => '123123',
  :name => 'corrector_and_publisher',
  :roles => [:corrector, :publisher],
)
