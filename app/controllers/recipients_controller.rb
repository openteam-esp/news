class RecipientsController < InheritedResources::Base
  belongs_to :channel

  actions :all, :except => :show

#  def index
#    index! {
#      @recipients = @channel.recipients.unscoped
#    }
#  end
end
