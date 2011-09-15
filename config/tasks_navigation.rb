SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    %w[fresh processed_by_me initiated_by_me].each do | scope |
      primary.item "sidebar_tasks_#{scope}", t("sidebar.tasks.#{scope}"),
                   tasks_path(scope), :counter => scope == 'initiated_by_me' ? 0 : Task.send(:kind, scope).count,
                   :highlights_on => lambda { params[:kind] == scope && params[:controller] == 'tasks' }
    end

  end
end

