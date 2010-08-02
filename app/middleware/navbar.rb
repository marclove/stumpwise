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
    head_content = <<-BLOCK
      #{navbar.stylesheet}
      #{navbar.javascript}
      <!--[if lt IE 9]>
        #{navbar.ie_stylesheet}
        #{navbar.ie_javascript}
      <![endif]-->
      <script type="text/javascript">
        $(document).ready(function(){Stumpwise.initCampaignSite('#{navbar.contribute_url}',#{navbar.domain})});
      </script>
    BLOCK
    
    body_content = <<-CONTRIBUTIONS_BLOCK
    		<!-- Stumpwise Navigation Bar -->
    			<div id="stumpwise-bar">
    				<a id="stumpwise-bar-logo" class="stumpwise-bar-button" href="http://stumpwise.com"></a>
    				<a id="stumpwise-bar-join" class="stumpwise-bar-button" href="/join"></a>
    CONTRIBUTIONS_BLOCK
    
    if navbar.accepts_contributions
    	body_content << <<-CONTRIBUTIONS_BLOCK
    	      <a id="stumpwise-bar-contribute" class="stumpwise-bar-button" href="#{navbar.contribute_url}"></a>
      CONTRIBUTIONS_BLOCK
  	end
  	
  	body_content << <<-CONTRIBUTIONS_BLOCK
    			</div>
    		<!-- END Stumpwise Navigation Bar -->
    CONTRIBUTIONS_BLOCK
    
    body.gsub!(/<\/head>/, head_content + "\n</head>")
    body.gsub!(/<\/body>/, body_content + "\n</body>")
    body
  end
end