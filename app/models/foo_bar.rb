class FooBar < Rack::Proxy

  def rewrite_env(env)
    env["HTTP_HOST"] = "example.com"

    env
  end

  def rewrite_response(triplet)
    status, headers, body = triplet

    headers["X-Foo"] = "Bar"

    triplet
  end

end