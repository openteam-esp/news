class FollowingsController < AuthorizedApplicationController
  actions :create, :destroy

  def create
    create! { tasks_path(:fresh) }
  end

  def destroy
    destroy! { tasks_path(:fresh) }
  end

  protected
    def build_resource
      @following = User.current.followings.build(params[:following])
      @following.follower = User.current
      @following
    end



end
