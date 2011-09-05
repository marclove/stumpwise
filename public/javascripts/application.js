$.ajaxSettings.accepts._default = "text/javascript, text/html, application/xml, text/xml, */*";

$(document).ready(function() {

	// TinyMCE Textareas
	$('textarea.tinymce').tinymce({
		// Location of TinyMCE script
		script_url : '/javascripts/tiny_mce/tiny_mce.js',
		mode: "exact",
		entity_encoding: "named",
		convert_newlines_to_brs: false,
		theme: "advanced",
		skin: "stumpwise",
		remove_trailing_nbsp: true,
		theme_advanced_layout_manager: "SimpleLayout",
		theme_advanced_buttons2: "",
		theme_advanced_buttons3: "",
		theme_advanced_toolbar_location: "top",
		content_css: "/stylesheets/custom_tinymce.css",
		plugins: "spellchecker,safari,pagebreak,paste",
		paste_auto_cleanup_on_paste: true,
		paste_strip_class_attributes: "mso",
		cleanup_callback: function(type, value) {
			var value = value + '';
			return value.replace(/<!--.*?-->/g,''); // due to MS Word's BS
		},
		convert_urls: false,
		process_html: true,
		inline_styles: false,
		gecko_spellcheck: true,
		
		valid_elements: "@[id|class|style|lang|dir|title]," +
		// Sections
		"-h1,-h2,-h3,-h4,-h5,-h6,-hgroup,-header,-footer,-address," +
		// Grouping content
		"#p,hr,-pre,-blockquote[cite],-ol[reversed|start],-ul,-li[value]," +
		"-dl,-dt,-dd,-figure,-figcaption,-div," +
		// Text-level semantics
		"-em/i,-strong/b,-small,-cite,-q[cite],-dfn,-abbr,-time[datetime|pubdate]," +
		"-code,-var,-samp,-kbd,-sub,-sup,-mark,-ruby,-rt,-rp,-bdo,span,br,wbr," +
		"+a[name|target|href|rel]," + // Not HTML5: name (use id instead)
		// Edits
		"-ins[cite|datetime],-del[cite|datetime]," +
		// Embedded content
		"img[alt|src|usemap|ismap|width|height]," +
		"iframe[src|srcdoc|name|sandbox|seamless|width|height|frameborder]," + // Not HTML5: frameborder
		"embed[src|type|width|height|allowscriptaccess|allowfullscreen]," + // Not HTML5: allowscriptaccess, allowfullscreen
		"object[classid|codebase|data|type|name|usemap|form|width|height]," + // Not HTML5: classid, codebase
		"param[name|value]," + 
		"video[src|poster|preload|autoplay|loop|controls|width|height]," +
		"audio[src|preload|autoplay|loop|controls]," +
		"source[src|type|media]," +
		"canvas[width|height]," +
		"area[alt|coords|shape|href|target|rel|media|hreflang|type]," +
		"map[name]," +
		// Tabular data
		"table[cellpadding=0|cellspacing=0|summary],caption,colgroup[span],col[span]," + // Not HTML5: cellpadding, cellspacing
		"tbody,thead,tfoot,tr,td[colspan|rowspan|headers],th[colspan|rowspan|headers|scope]",
			
		theme_advanced_buttons1: "bold,italic,underline,strikethrough,separator,blockquote,formatselect,separator,bullist,numlist,separator,outdent,indent,separator,image,link,unlink,pasteword,separator,code",
		theme_advanced_blockformats : "h1,h2,h3,p",
		width: '100%',
		setup: function (ed) {
			ed.onPaste.add(function (ed) {
				if (ed.getContent().length < 30) {
					setTimeout(function () {
						ed.serializer.setRules(
							// Grouping content
							"-p,hr,-pre,-blockquote[cite],-ol[reversed|start],-ul,-li[value]," +
							"-dl,-dt,-dd,-figure,-figcaption," +
							// Text-level semantics
							"-em/i,-strong/b,-small,-cite,-q[cite],-dfn,-abbr,-time[datetime|pubdate]," +
							"-code,-var,-samp,-kbd,-sub,-sup,-mark,-ruby,-rt,-rp,-bdo,span,br,wbr," +
							"+a[title|href]," +
							// Edits
							"-ins[cite|datetime],-del[cite|datetime]," +
							// Sections
							"-p/h1,-p/h2,-p/h3,-p/h4,-p/h5,-p/h6" +
							// Embedded content
							"img[alt|src|width|height]," +
							"iframe[src|srcdoc|name|sandbox|seamless|width|height|frameborder]," + // Not HTML5: frameborder
							"embed[src|type|width|height|allowscriptaccess|allowfullscreen]," + // Not HTML5: allowscriptaccess, allowfullscreen
							"object[classid|codebase|data|type|name|usemap|form|width|height]," + // Not HTML5: classid, codebase
							"param[name|value]," + 
							"video[src|poster|preload|autoplay|loop|controls|width|height]," +
							"audio[src|preload|autoplay|loop|controls]," +
							"source[src|type|media]," +
							"canvas[width|height]," +
							"area[alt|coords|shape|href|target|rel|media|hreflang|type]," +
							"map[name]," + 
							// Tabular data
							"table[cellpadding=0|cellspacing=0|summary],caption,colgroup[span],col[span]," + // Not HTML5: cellpadding, cellspacing
							"tbody,thead,tfoot,tr,td[colspan|rowspan|headers],th[colspan|rowspan|headers|scope]"
						);
						ed.setContent(ed.getContent());
						var content = ed.getContent().replace(/\<p\>\&nbsp\;<\/p>/g, '');
						ed.setContent(content);
						ed.selection.moveToBookmark(ed.selection.getBookmark());
						ed.serializer.setRules(ed.settings.valid_elements)
					},
					10)
				}
			})
		}
	});
	
	// Sortable Data Table
	$("#supporters_table").tablesorter({
		headers:{
			6:{sorter:false},
			7:{sorter:false}
		},
		widgets: ['zebra'],
		widthFixed: true,
		sortList:[[8,1]]
	}).tablesorterPager({container:$("#pager"), size:20});

	// Sortable Data Table Clickable Rows
	$('#supporters_table tr').click(function() {
		var href = $(this).find("a").attr("href");
		if (href) { window.location = href;}
	});

	$('#contributions_table tr, #admin_contributions_table tr').each(function(){
		var href = $(this).attr('data-url');
		if(href){
			var link = $(this).find('a'),
					contents = link.text();
			link.replaceWith(contents);
			$(this).click(function(){
				window.location = href;
			});
		}
	});
	
	$('#notice.flash_message').delay(3000).slideToggle(600);
	
	// Theme Changing
	$("input[name='site[mongo_theme_id]']").bind("click",function(){
	  $.ajax("/admin/theme/set_theme?id=" + $(this).val(), {
	    type: 'POST',
	    dataType: 'text',
	    accepts: {text:"text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*"},
	    data: {'_method':'put'},
	    success: function(data){
	      $("#theme_customization_options").html(data);
	    }
	  });
	});	
	
	// SMS Campaign Send/Confirm
	$("#sending-message-button").hide();
	$("form#new_sms_campaign").submit(function(e) {
		var confirmed = confirm(
			'Sending this message will cost ' + $('#cost').html() + 
			'. Click OK to send the message and authorize the charging of your account.'
		);
		if(confirmed){
			$("#send-sms").attr('disabled', true);
			$("#send-message-button").hide();
			$("#sending-message-button").show();
		} else {
			e.preventDefault();
		}
	});
	
	$("time.timeago").timeago();
	
	
	
	// Progress Tracker Action Highlights
	if (window.location.search == '?highlight=true' && window.location.hash == '#campaign_info'){
	  $('#site_campaign_legal_name').css({'background-color':'#FFC', 'background-image':'none'});
	  $('#site_campaign_street').css({'background-color':'#FFC', 'background-image':'none'});
	  $('#site_campaign_city').css({'background-color':'#FFC', 'background-image':'none'});
	  $('#site_campaign_state').css({'background-color':'#FFC', 'background-image':'none'});
	  $('#site_campaign_zip').css({'background-color':'#FFC', 'background-image':'none'});
	  $('#site_campaign_email').css({'background-color':'#FFC', 'background-image':'none'});
	}
	if (window.location.search == '?highlight=true' && window.location.hash == '#site_candidate_photo'){
	  $('#site_candidate_photo').css({'background-color':'#FFC', 'background-image':'none'});
	}
	if (window.location.search == '?highlight=true' && window.location.hash == '#social_networks'){
	  $('#site_twitter_username').css({'background-color':'#FFC', 'background-image':'none'});
	  $('#site_facebook_page_id').css({'background-color':'#FFC', 'background-image':'none'});
	}
	if (window.location.search == '?highlight=true' && window.location.hash == '#site_subdomain'){
	  $('#site_custom_domain').css({'background-color':'#FFC', 'background-image':'none'});
	}	
	
});


/*
 * 	Character Count Plugin - jQuery plugin
 * 	Dynamic character count for text areas and input fields
 *	written by Alen Grakalic	
 *	http://cssglobe.com/post/7161/jquery-plugin-simplest-twitterlike-dynamic-character-count-for-textareas
 *
 *	Copyright (c) 2009 Alen Grakalic (http://cssglobe.com)
 *	Dual licensed under the MIT (MIT-LICENSE.txt)
 *	and GPL (GPL-LICENSE.txt) licenses.
 *
 *	Built for jQuery library
 *	http://jquery.com
 *
 */
 
(function($) {

	$.fn.charCount = function(options){
	  
		// default configuration properties
		var defaults = {	
			allowed: 140,		
			warning: 25,
			css: 'counter',
			counterElement: 'span',
			cssWarning: 'warning',
			cssExceeded: 'exceeded',
			counterText: ''
		}; 
			
		var options = $.extend(defaults, options); 
		
		function calculate(obj){
			var count = $(obj).val().length;
			var available = options.allowed - count;
			if(available <= options.warning && available >= 0){
				$(obj).next().addClass(options.cssWarning);
			} else {
				$(obj).next().removeClass(options.cssWarning);
			}
			if(available < 0){
				$(obj).next().addClass(options.cssExceeded);
			} else {
				$(obj).next().removeClass(options.cssExceeded);
			}
			$(obj).next().html(available + options.counterText);
		};
				
		this.each(function() {  			
			$(this).after('<'+ options.counterElement +' class="' + options.css + '">'+ options.counterText +'</'+ options.counterElement +'>');
			calculate(this);
			$(this).keyup(function(){calculate(this)});
			$(this).change(function(){calculate(this)});
		});
	  
	};



})(jQuery);
