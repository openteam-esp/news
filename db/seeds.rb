Channel.find_or_create_by_title('tomsk.gov.ru/ru/announces')
Channel.find_or_create_by_title('tomsk.gov.ru/ru/news')
c = Channel.find_or_create_by_title('mailing_lists/common')
c.recipients.find_or_create_by_email('gmyzind@gmail.com')
Channel.find_or_create_by_title('mailing_lists/innovation')

Folder.find_or_create_by_title('awaiting_correction')
Folder.find_or_create_by_title('awaiting_publication')
Folder.find_or_create_by_title('published')
Folder.find_or_create_by_title('correcting')
Folder.find_or_create_by_title('draft')
Folder.find_or_create_by_title('trash')

corrector_role = Role.find_or_create_by_kind('corrector')
publisher_role = Role.find_or_create_by_kind('publisher')

corrector = User.find_or_create_by_email('corrector@demo.de')
corrector.update_attributes(
  :password => '123123',
  :password_confirmation => '123123',
  :name => 'corrector'
)
corrector.roles.destroy_all
corrector.roles << corrector_role

publisher = User.find_or_create_by_email('publisher@demo.de')
publisher.update_attributes(
  :password => '123123',
  :password_confirmation => '123123',
  :name => 'publisher'
)
publisher.roles.destroy_all
publisher.roles << publisher_role

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
  :name => 'corrector_and_publisher'
)
corrector_and_publisher.roles.destroy_all
corrector_and_publisher.roles << corrector_role
corrector_and_publisher.roles << publisher_role
