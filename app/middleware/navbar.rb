# Copyright (c) 2010-2011 ProgressBound, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
    body.gsub!(/<\/head>/, navbar.header_markup + "\n</head>".html_safe)
    body.gsub!(/<\/body>/, navbar.body_markup + "\n</body>".html_safe)
    body
  end
end