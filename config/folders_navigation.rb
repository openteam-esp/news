SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :inbox, "#{t('inbox')}", messages_path, :counter => @current_user.messages.count

    %w[draft awaiting_correction correcting awaiting_publication published trash].each do | state |
      primary.item state, t(state), "/#{state}#{entries_path}",
                   :highlights_on => lambda { params[:state] == state || (params[:controller] == 'entries' && @entry.try(:state) == state) } #  if @current_user.corrector?
    end

    primary.item :recipients, t('channels'), channels_path,
                 :highlights_on => /^recipients/ if can? :manage, Recipient
  end
end

