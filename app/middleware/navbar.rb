class Navbar
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, response = @app.call(env)
    if env[:navbar]
      new_body = insert_navbar(build_response_body(response), env[:navbar])
      new_headers = recalculate_body_length(headers, new_body)
      [status, new_headers, new_body]
    else
      [status, headers, response]
    end
  end
  
  def build_response_body(response)
    response_body = ""
    response.each { |part| response_body += part }
    response_body
  end
  
  def recalculate_body_length(headers, body)
    new_headers = headers
    new_headers["Content-Length"] = body.length.to_s
    new_headers
  end
  
  def insert_navbar(body, navbar)
    body.gsub!(/<\/head>/, navbar.header_markup + "\n</head>")
    body.gsub!(/<\/body>/, navbar.body_markup + "\n</body>")
    body
  end
end