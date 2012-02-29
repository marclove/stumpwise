<!--
Copyright (c) 2010-2011 ProgressBound, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-->

<!DOCTYPE html>
<head>
	<title>{{ site.name }}</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.0r4/build/reset/reset-min.css" />
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.0r4/build/fonts/fonts-min.css" />
	{{ 'grid,master' | stylesheet }}
	{{ 'jquery.1.4.2' | google_js }}
	<script type="text/javascript">
	<!--
		jQuery.fn.DefaultValue = function(text){
		    return this.each(function(){
				//Make sure we're dealing with text-based form fields
				if(this.type != 'text' && this.type != 'password' && this.type != 'textarea')
					return;

				//Store field reference
				var fld_current=this;

				//Set value initially if none are specified
		        if(this.value=='') {
					this.value=text;
				} else {
					//Other value exists - ignore
					return;
				}

				//Remove values on focus
				$(this).focus(function() {
					if(this.value==text || this.value=='')
						this.value='';
				});

				//Place values back on blur
				$(this).blur(function() {
					if(this.value==text || this.value=='')
						this.value=text;
				});

				//Capture parent form submission
				//Remove field values that are still default
				$(this).parents("form").each(function() {
					//Bind parent form submit
					$(this).submit(function() {
						if(fld_current.value==text) {
							fld_current.value='';
						}
					});
				});
		    });
		};
		
		$(document).ready(function() {
			//Assign default value to form field #1
			$("#email_address").DefaultValue("Email Address");
			$("#zip_code").DefaultValue("Zip Code");
		});
	-->
	</script>
</head>
<body>
	<div id="content" class="container_16">
		<div class="grid_4">
			<div id="sidebar">
				<div id="profile_image">{{ site.candidate_photo | image_tag }}</div>
				<a href="{{ site.contribute_url }}" class="contribute">Contribute</a>
				<div id="social_networks">
				</div>
				{% facebook_widget %}
				{% twitter_widget %}
			</div>
		</div>
		<div class="grid_12">
			<div id="main">
				<div id="header">
					<h1>{{ site.name }}</h1>
					<h2>{{ site.subhead }}</h2>
					<div id="join_form">
						<form method="post" action="/supporters">
							Stay Informed &nbsp;|&nbsp; Join the Campaign!<br/>
							<input id="email_address" type="text" name="supporter[email]" value="" />
							<input id="zip_code" type="text" name="supporter[postal_code]" value="" />
							<input id="submit" type="submit" value="JOIN" />
						</form>
					</div>
				</div>
				<div id="navigation">
					<ul>
					{% for item in site.navigation %}
						<li>{% link_to item %}</li>
					{% endfor %}
					</ul>
				</div>
				<div id="body">
					{{ content_for_layout }}
				</div>
			</div>
		</div>
	</div>
	<div id="footer">
		<p style="text-align:center">
			P.O. Box 4958, Campbell, CA 95111<br/>
			Phone 408 394 9585 | Fax 408 394 9586<br/>
			{{ site.copyright }}
		</p>
		<p id="disclaimer"><span>{{ site.disclaimer }}</span></p>
	</div>
</body>
</html>