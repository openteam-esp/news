SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :inbox, "#{t('inbox')} (#{@current_user.messages.count})", messages_path

    primary.item :awaiting_correction, t('awaiting_correction'), folder_entries_path(Folder.where(:title => 'awaiting_correction').first),
                 :highlights_on => lambda { @folder.awaiting_correction? if @folder.present? } if @current_user.corrector?

    primary.item :awaiting_publication, t('awaiting_publication'), folder_entries_path(Folder.where(:title => 'awaiting_publication').first),
                 :highlights_on => lambda { @folder.awaiting_publication? if @folder.present? } if @current_user.publisher?

    primary.item :published, t('published'), folder_entries_path(Folder.where(:title => 'published').first),
                 :highlights_on => lambda { @folder.published? if @folder.present? }

    primary.item :correcting, t('correcting'), folder_entries_path(Folder.where(:title => 'correcting').first),
                 :highlights_on => lambda { @folder.correcting? if @folder.present? }

    primary.item :draft, t('draft'), folder_entries_path(Folder.where(:title => 'draft').first),
                 :highlights_on => lambda { @folder.draft? if @folder.present? }

    primary.item :trash, t('trash'), folder_entries_path(Folder.where(:title => 'trash').first),
                 :highlights_on => lambda { @folder.trash? if @folder.present? }
  end
end

