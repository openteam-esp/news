class EntriesController < ApplicationController
  inherit_resources
  before_filter :authenticate_user!
  has_scope :by_state
end
