# encoding: utf-8

require 'spec_helper'

describe Manage::News::FollowingsController do
  before { sign_in corrector }

  it "POST create" do
    post :create, :following => { :target_id => initiator.id }
    assigns(:following).should be_persisted
    response.should redirect_to(manage_news_tasks_path(:fresh))
  end

  it "DELETE destroy" do
    following = corrector.followings.create!(:target => initiator)
    following.follower = corrector
    delete :destroy, :id => following.id
    assigns(:following).should_not be_persisted
    response.should redirect_to(manage_news_tasks_path(:fresh))
  end
end
