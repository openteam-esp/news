class Manage::FollowingsController < Manage::ApplicationController
  actions :create, :destroy

  def create
    create! { manage_tasks_path(:fresh) }
  end

  def destroy
    destroy! { manage_tasks_path(:fresh) }
  end

  protected
    def build_resource
      @following = User.current.followings.build(params[:following])
      @following.follower = User.current
      @following
    end



end
