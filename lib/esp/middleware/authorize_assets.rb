module Esp
  module Middleware
    class AuthorizeAssets
      def initialize(app, options={})
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] =~ /^\/assets\/(\d+)(?:\/\d+-\d+)\/(.*)/
          throw(:warden) unless Ability.new.can? :read, Asset.where(:file_name => $2).find($1)
        end
        @app.call(env)
      end

    end
  end
end
