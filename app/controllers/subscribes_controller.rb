class SubscribesController < AuthorizedApplicationController

  load_and_authorize_resource

  actions :create, :destroy

  def create
    entry = Entry.find(params[:entry_id])
    subscribe = Subscribe.new(:subscriber_id => @current_user.id, :initiator_id => entry.initiator.id)

    if subscribe.save
      redirect_to(:back, :notice => ::I18n.t('Subscribe was successfully created.'))
    else
      redirect_to(:back, :alert => ::I18n.t('Subscribe wasn\'t  created.'))
    end
  end

  def destroy
    entry = Entry.find(params[:entry_id])
    subscribe = Subscribe.where(:subscriber_id => @current_user.id, :initiator_id => entry.initiator.id).first

    if subscribe.destroy
      redirect_to(:back, :notice => ::I18n.t('Subscribe was successfully delete.'))
    else
      redirect_to(:back, :alert => ::I18n.t('Subscribe wasn\'t delete.'))
    end
  end
end
