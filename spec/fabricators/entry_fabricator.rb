# encoding: utf-8

Fabricator(:entry) do
  title       'Заголовок новости'
  annotation  'Аннотация новости'
  body        'Текст новости'
  channels!(:count => 1)
end
