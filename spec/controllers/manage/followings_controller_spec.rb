# encoding: utf-8

require 'spec_helper'

describe Manage::FollowingsController do
  before(:each) do
    sign_in corrector
    set_current_user corrector
  end
  it "POST create" do
    as corrector do
      post :create, :following => { :target_id => initiator.id }
    end
    assigns(:following).should be_persisted
    response.should redirect_to(tasks_path(:fresh))
  end

  it "DELETE destroy" do
    following = corrector.followings.create!(:target => initiator)
    following.follower = corrector
    as corrector do
      delete :destroy, :id => following.id
    end
    assigns(:following).should_not be_persisted
    response.should redirect_to(tasks_path(:fresh))
  end
end
