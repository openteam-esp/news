Channel.destroy_all

Channel.create! :title => "tomsk.gov.ru/news"
Channel.create! :title => "tomsk.gov.ru/announces"

Folder.create! :title => 'inbox'
Folder.create! :title => 'published'
Folder.create! :title => 'correcting'
Folder.create! :title => 'draft'
Folder.create! :title => 'trash'
