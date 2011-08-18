class RecipientsController < AuthorizedApplicationController

  load_and_authorize_resource

  belongs_to :channel

  actions :all, :except => :show

  has_scope :page, :default => 1

end
