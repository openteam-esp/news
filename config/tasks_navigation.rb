SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    %w[fresh processed_by_me initiated_by_me].each do | folder |
      primary.item "sidebar_tasks_#{folder}", t("sidebar.tasks.#{folder}"),
                   manage_news_tasks_path(folder), :counter => Task.folder(folder, current_user).count('DISTINCT tasks.id'),
                   :highlights_on => lambda { params[:folder] == folder && params[:controller] == 'manage/news/tasks' }
    end

  end
end

