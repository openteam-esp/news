# encoding: utf-8

Fabricator('legacy/entry', :class_name => Legacy::Entry) do
  title         'Соглашение между администрацией Томской области и ОАО «ТВЭЛ»   подписано'
  annotation    <<-END
                  В конце минувшей недели подписано соглашение о сотрудничестве между администрацией
                  Томской области и ОАО «ТВЭЛ». Документ подписан губернатором Томской области Виктором
                  Крессом и президентом компании Юрием Олениным.
                END
  body          <<-'END'.squish.gsub(/\\r/, "\r").gsub(/\\n/, "\n")
                  В рамках соглашения будет организовано взаимодействие между предприятиями Топливной компании
                  и организациями научно-образовательного комплекса Томской области.
                  Главной целью ставится объединение усилий сторон для реализации научно-образовательного
                  потенциала Томского региона по выполнению научно-исследовательских конструкторских работ
                  и подготовки квалифицированных кадров для предприятий ОАО «ТВЭЛ». \r\n\r\n

                  Ежегодно планируется проводить встречи руководителей и специалистов университетов и академических
                  институтов с представителями Топливной компании для обсуждения имеющихся технологических проблем,
                  организовывать стажировки научных сотрудников на предприятиях Топливной компании, расширять
                  взаимный информационный обмен в сфере научных исследований и разработок.
                  Главным результатом должно стать внедрение передовых достижений науки и техники на
                  действующих предприятиях одной из ведущих компаний ГК «Росатом».\r\n\r\n

                  Напомним, что соглашение между администрацией региона и ОАО «ТВЭЛ» было подписано по итогам
                  встречи губернатора Томской области Виктора Кресса с президентом «ТВЭЛа» Юрием Олениным
                  в феврале 2011 года, а также визита в Томск делегации Топливной компании в апреле текущего года.\r\n\r\n

                  Представители ТВЭЛа познакомились с научными разработками ТГУ, ТПУ и Северского технологического
                  института, а также Института физики прочности и материаловедения, ТУСУРа и Института сильноточной
                  электроники. По итогам работы в Томске намечен ряд серьезных направлений сотрудничества, в
                  частности, в области разработки новых материалов для тепловыделяющих элементов для АЭС, в области
                  спецобработки заготовок и готовых изделий, в направлении фторидных технологий, производства
                  нанокерамических покрытий и многих других.
                END
  created_at    "2011-07-20 17:21:01"
  updated_at    "2011-07-20 17:21:20"
  date_time     "2011-07-20 17:17:00"
  end_date_time "2011-07-21 06:00:00"
  status        "blank"
end

