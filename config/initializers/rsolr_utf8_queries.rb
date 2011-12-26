class RSolr::Client
  alias :build_request_without_utf8 :build_request
  def build_request(path, opts)
    opts = build_request_without_utf8(path,opts)
    if opts[:headers].try(:[], 'Content-Type') == 'application/x-www-form-urlencoded'
      opts[:headers]['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
    end
    opts
  end
end
