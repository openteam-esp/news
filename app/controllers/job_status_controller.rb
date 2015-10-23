class JobStatusController < ApplicationController
  def status
    percent = Sidekiq::Status::pct_complete("#{params[:job_id]}").to_i
    render :json => { :percent => percent }
  end
end
