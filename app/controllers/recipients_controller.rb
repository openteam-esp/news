class RecipientsController < InheritedResources::Base
  load_and_authorize_resource
  belongs_to :channel

  actions :all, :except => :show
  
  has_scope :page, :default => 1

#  def index
#    index! {
#      @recipients = @channel.recipients.unscoped
#    }
#  end
end
