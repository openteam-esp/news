# encoding: utf-8

Fabricator(:news_entry) do
  title       'Заголовок новости'
  annotation  'Аннотация новости'
  body        'Текст новости'
  initiator
  current_user {|e| e.initiator}
end
