SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    %w[fresh processed_by_me initiated_by_me].each do | folder |
      primary.item "sidebar_tasks_#{folder}", t("sidebar.tasks.#{folder}"),
                   manage_tasks_path(folder), :counter => folder == 'initiated_by_me' ? 0 : Task.folder(folder, current_user).count,
                   :highlights_on => lambda { params[:folder] == folder && params[:controller] == 'manage/tasks' }
    end

  end
end

