class Manage::Channels::ChannelsController < Manage::Channels::ApplicationController
  actions :new, :create, :edit, :update, :destroy, :index
  has_scope :page, :default => 1, :only => :index

  protected
    def collection
      (get_collection_ivar || set_collection_ivar(paginate_collection))
    end

    def paginate_collection
      begin_of_association_chain.page(params[:page])
    end
end
