Channel.destroy_all

Channel.create! :title => "tomsk.gov.ru/news"
Channel.create! :title => "tomsk.gov.ru/announces"

Folder.find_or_create_by :title => 'inbox'
Folder.find_or_create_by :title => 'published'
Folder.find_or_create_by :title => 'correcting'
Folder.find_or_create_by :title => 'draft'
Folder.find_or_create_by :title => 'trash'
