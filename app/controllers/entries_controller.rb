class EntriesController < ApplicationController
  inherit_resources
  before_filter :authenticate_user!
end
