SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    %w[fresh my other].each do | scope |
      primary.item "sidebar_tasks_#{scope}", t("sidebar.tasks.#{scope}"), tasks_path(scope), :counter => Task.send(:kind, scope).count,
                   :highlights_on => lambda { params[:kind] == scope && params[:controller] == 'tasks' }
    end

  end
end

