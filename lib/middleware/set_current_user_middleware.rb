class SetCurrentUserMiddleware
  def initialize(app, options={})
    @app = app
  end

  def call(env)
    User.current = env['warden'].user
    @app.call(env)
  end
end
