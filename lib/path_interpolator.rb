include Rack::Utils

class PathInterpolator
  def self.path(request)
    return Entry.find(request.params[:entry_id]).vfs_path
  end

end
