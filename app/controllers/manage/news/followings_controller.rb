class Manage::News::FollowingsController < Manage::ApplicationController
  actions :create, :destroy

  def create
    create! { manage_news_tasks_path(:fresh) }
  end

  def destroy
    destroy! { manage_news_tasks_path(:fresh) }
  end

  protected

    def begin_of_association_chain
      current_user
    end



end
