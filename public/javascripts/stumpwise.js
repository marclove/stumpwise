// ==ClosureCompiler==
// @compilation_level SIMPLE_OPTIMIZATIONS
// @output_file_name stumpwise.min.js
// @code_url http://github.com/rpflorence/moo4q/raw/master/mootools-1.2.4-base.js
// @code_url http://github.com/rpflorence/moo4q/raw/master/Class.Mutators.jQuery.js
// @code_url http://github.com/jackmoore/colorbox/raw/master/colorbox/jquery.colorbox.js
// @code_url http://github.com/cowboy/jquery-postmessage/raw/master/jquery.ba-postmessage.js
// @code_url http://timeago.yarp.com/jquery.timeago.js
// @code_url http://ajax.microsoft.com/ajax/jquery.validate/1.7/jquery.validate.js
// ==/ClosureCompiler==

/* Stumpwise v0.1.1
 * Copyright 2010 ProgressBound Inc.
 * All Rights Reserved */

$.ajaxSettings.accepts._default = "text/javascript, text/html, application/xml, text/xml, */*";

if (!window.SW) {
	SW = {
		ssl: 					function(){ return window.location.protocol.match(/s\:$/) ? true : false; },
		protocol: 		function(){ return this.ssl() ? 'https://' : 'http://'; },
		env: 					function(){ return window.location.hostname.match(/stumpwise-local\.com$/) ? 'development' : 'production'; },
		host: 				function(){ return (this.env() == 'production') ? 'stumpwise.com' : 'stumpwise-local.com'; },
		www: 					function(){ return (this.ssl() ? 'https://secure.' : 'http://') + this.host(); },
		secure: 			function(){ return 'https://secure.' + this.host(); },
		customDomain: function(){ return window.location.hostname.match(/stumpwise(?:-local)?\.com$/) ? false : true; },
		customAnalytics: false,
		
		trackPageview: function(pathName){
	    var event = ['_trackPageview'];
	    if (pathName) {
	      event.push(pathName);
	    }
	    _gaq.push(event);

      if(SW.customAnalytics){
        var event = ['customerTracker._trackPageview'];
        if (pathName) {
          event.push(pathName);
        }
        _gaq.push(event);
      }
		},
		
		thanksForJoining: function(){
		  $.colorbox({iframe:true, width:"450px", height:"120px", href:"/thanks_join.html"});
			window.setTimeout("$.colorbox.close()", 4000);
		},
		
		thanksForContributing: function(){
			$.colorbox({iframe:true, width:"400px", height:"175px", href:"/thanks_contribute.html"});
			window.setTimeout("$.colorbox.close()", 5000);
		},
		
		
		/**
		 * PopUp Generator
		 * Turns any clickable element into a popup launcher
		 * Usage: $('#link').popup(options);
		 *
		 * options:
		 * Property    | Type    | Description               | Default
		 * ------------|---------|---------------------------|---------
		 * url         | String  | URL the popup should load | (required)
		 * target      | String  | _target of the popup      | '_blank'
		 * width       | Integer | pixel width of the popup  | 600
		 * height      | Integer | pixel height of the popup | 400
		 * scrollbars  | Boolean | show the scrollbars?      | false
		 * toolbar	   | Boolean | show the toolbar?         | false
		 * location    | Boolean | show the location bar?    | false
		 * menubar	   | Boolean | show the menubar?         | false
		 * status      | Boolean | show the status bar?      | true
		 */
		Popup: new Class({
			Implements: [Options, Events],
			
			options: {
				url: null,
				target: '_blank',
				width: 600,
				height: 400,
				scrollbars: false,
				toolbar: false,
				location: false,
				menubar: false,
				status: true
			},
			
			jQuery: 'popup',
			
			initialize: function(selector, options){
				this.setOptions(options);
				var that = this;
				$(selector).click(function(e){
					e.preventDefault();
					window.open(that.options.url, that.options.target, that.features());
				});
			},
			
			screenX: 			typeof window.screenX 			!= 'undefined'
				? window.screenX
				: window.screenLeft,
			
			screenY: 			typeof window.screenY 			!= 'undefined' 
				? window.screenY
				: window.screenTop,
			
			outerWidth: 	typeof window.outerWidth 		!= 'undefined'
				? window.outerWidth
				: document.documentElement.clientWidth,
			
			outerHeight: 	typeof window.outerHeight 	!= 'undefined'
				? window.outerHeight
				: (document.documentElement.clientHeight - 22), // 22= IE toolbar height
			
			left: function(){
				return parseInt(this.screenX + ((this.outerWidth - this.options.width) / 2), 10);
			},
			
			top: function(){
				return parseInt(this.screenY + ((this.outerHeight - this.options.height) / 2), 10);
			},
			
			features: function(){
				return	'width='		   + this.options.width +
								',height='	   + this.options.height +
								',left='		   + this.left() +
								',top='			   + this.top() +
								',scrollbars=' + (this.options.scrollbars ? 'yes' : 'no') +
								',toolbar='	   + (this.options.toolbar ? '1' : '0') +
								',location='   + (this.options.location ? '1' : '0') + 
								',menubar='    + (this.options.menubar ? '1' : '0') +
								',status='	   + (this.options.status ? '1' : '0')
			}
		}),
		
		
		/**
		 * Navbar's Join Button
		 */
		JoinButton: new Class({
			jQuery: 'joinButton',
			initialize: function(selector){
				$(selector).colorbox({iframe:true, width:"560px", height:"430px"});
			}
		}),
		
		
		/**
		 * Navbar's Contribute Button
		 * Usage: $('#stumpwise-bar-contribution').contributeButton(options);
		 * 
		 * options:
		 * Property | Type    | Description      | Default
		 * ---------|---------|------------------|-----------
		 * url      | String  | contribution url | (required)
		 */
		ContributeButton: new Class({
			Implements: [Options],
			options: {url:null},
			jQuery: 'contributeButton',
			initialize: function(selector, options){
				this.setOptions(options);
				var height = screen.availHeight - 100,
						width  = 700;
				$(selector).popup({url:this.options.url, target:'contribute', height:height, width:width, scrollbars:true});
			}
		}),
		
		
		/**
		 * Campaign Site Navbar
		 * Usage: $('#stumpwise-bar').navbar(options);
		 *
		 * options:
		 * Property            | Type    | Description                    | Default
		 * --------------------|---------|--------------------------------|---------
		 * subdomain           | String  | subdomain of the campaign site | (required)
		 */
		Navbar: new Class({
			Implements: [Options],
			options: {subdomain:null},
			jQuery: 'navbar',

			initialize: function(selector, options){
				this.setOptions(options);
				this.openXDChannel();
				var contributeURL = SW.secure() + '/' + this.options.subdomain + '/contribute?popup=true' + "#" + encodeURIComponent(document.location.href);
				$(selector).find('#stumpwise-bar-join').joinButton();
				$(selector).find('#stumpwise-bar-contribute').contributeButton({url:contributeURL});
			},
	
			openXDChannel: function(){
				$.receiveMessage(function(message){
					if(message.data == "thanksForContributing"){ this.SW.thanksForContributing(); }
				}, SW.secure());
			}
		}),
		
		
		/**
		 * Campaign Join Form
		 * Usage: $('#new_supporter').joinForm();
		 */
		JoinForm: new Class({
			jQuery: 'joinForm',
			
			initialize: function(selector){
				
				$("#cancel").click(function(e){
					e.preventDefault();
					window.parent.$.fn.colorbox.close();
				});
				
				$(selector).validate({
					submitHandler:function(form){
						$.ajax({
							type: 'POST', 
							data: $(form).serialize(), 
							url: $(form).attr("action"),
							success: function(m){
								window.parent.SW.thanksForJoining();
							},
							error: function(m){
								$("#errors").html(m.responseText).show();
								$('html, body').animate({scrollTop:0}, 'slow');
							}
						});
					}
				});
				
			} // end initialize
		}),
		
		
		/**
		 * Campaign Contribution Form
		 * Usage: $('#new_contribution).contributionForm();
		 *
		 * options:
		 * Property   | Type    | Description                 | Default
		 * -----------|---------|-----------------------------|---------
		 * max        | Integer | max contribution amount     | 250
		 * suggested  | Integer | campaign's suggested amount | (optional - defaults to 1/2 max)
		 */
		ContributionForm: new Class({
			Implements: [Options],
			
			options: {
				max: 250,
				suggested: null
			},
			
			jQuery: 'contributionForm',
			
			initialize: function(selector, options){
				this.setOptions(options);
				this.setupSlider();
				this.setupForm();
				this.setupCancelButton();
			},
			
			campaignSite: function(){
				return decodeURIComponent(document.location.hash.replace(/^#/, ''));
			},
			
			// ensure the start slider amount is never less than the minimum amount
			start: function(){
				if (this.options.suggested){
					return (this.options.suggested > this.maximum()) ? this.maximum() : this.options.suggested;
				} else {
					return this.maximum() / 2.0;
				}
			},
			
			// ensure the max slider amount is never less than the minimum amount
			maximum: function(){
				return (this.options.max < 5) ? 5 : this.options.max;
			},
			
			setupSlider: function(){
				var that = this;
				$("#amount").css({'border':0, 'padding':0});
				$("#max-amount-warning").hide();
				$("#contribution-min").html('$' + 5);
				$("#contribution-max").html('$' + that.maximum());
				$("#slider").slider({
					value: that.start(),
					min: 5,
					max: that.maximum(),
					step: 5,
					slide: function(event, ui){$("#amount").val('$' + ui.value);}
				});
				$("#amount").val('$' + $("#slider").slider("value"));
			},
			
			setupForm: function(){
				var that = this;
				
				// keep error messages from breaking float placement
				$(".container").append('<div style="clear:both"></div>');
				
				// form validations
				$("#contribution_form").validate({
					messages: {
						"contribution[compliance_confirmation]": "You must confirm that you are eligible to contribute by checking this box."
					},
					groups: {
						expirationDate: "credit_card[expiration_month] credit_card[expiration_year]"
					},
					errorPlacement: function(error, element){
						if(element.attr("name") == "credit_card[expiration_month]" || element.attr("name") == "credit_card[expiration_year]"){
							error.insertAfter("#credit_card_expiration_year");
						} else if(element.attr("name") == "contribution[compliance_confirmation]") {
							error.insertBefore("#compliance_confirmation");
						} else {
							error.insertAfter(element);
						}
					},
					submitHandler: function(form){
						$.ajax({
							type: 'POST',
							data: $(form).serialize(),
							beforeSend: function(r){
								$("#submit").attr('disabled', 'disabled').html('<img src="/images/loading.gif" /> Processing Your Contribution...');
							},
							error: function(m){
								$("#submit").removeAttr('disabled').html('Process Contribution');
								$("#errors").html(m.responseText).show();
								$('html, body').animate({scrollTop:0}, 'slow');
							},
							success:function(m){
								$("#submit").html('Thank you for your contribution!');
								$.postMessage('thanksForContributing', that.campaignSite(), window.opener);
								window.close();
							},
							url: $(form).attr("action")
						});
					}
				});
			},
			
			setupCancelButton: function(){
				$('#cancel').click(function(e){
					e.preventDefault();
					window.close();
				});
			}
		}),
		
		
		/**
		 * Campaign Site
		 * Usage: $(document).campaignSite(options)
		 *
		 * options:
		 * Property     | Type   | Description                            | Default
		 * -------------|--------|----------------------------------------|---------
		 * subdomain    | String | subdomain of the campaign site         | (required)
		 * customDomain | String | hostname segment of custom domain name | 
		 * analytics    | String | Google Analytics ID                    | 
		 */
		CampaignSite: new Class({
			jQuery: 'campaignSite',
			
			Implements: [Options],
			
			options: {
				subdomain: null,
				customDomain: null,
				analytics: null
			},
			
			initialize: function(selector, options){
				this.setOptions(options);
				
				// Initialize Navbar
				$('#stumpwise-bar').navbar({subdomain:this.options.subdomain});
				
				if (this.options.analytics && this.options.customDomain && SW.customDomain()){
          SW.customAnalytics = true;
          _gaq.push(['customerTracker._setAccount', this.options.analytics]);
          _gaq.push(['customerTracker._setDomainName', this.options.customDomain]);
				}
			}
		})
		
	} // end defining SW
} // endif