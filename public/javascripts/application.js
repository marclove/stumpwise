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
		paste_auto_cleanup_on_paste: false,
		convert_urls: false,
		process_html: true,
		inline_styles: false,
		gecko_spellcheck: true,
		valid_elements: "-p[class],-a[name|id|title|target|href],-blockquote[class],br,-code[class]," + "-dd[*],-dl[*],-dt[*],-del[*],-i/em[class],-ins[*],-li[*],-ol[*],-pre[class]," + "-q[*],-b/strong[class],-u[*],-ul[*],-s[*],img[*],hr[*],-sub[*]," + "-sup[*],-strike[*],-small[*],-big[*],-h1[id|class],-h2[id|class],-h3[id|class]," + "-h4[id|class],-h5[id|class],-h6[id|class],object[*],embed[*],param[*],iframe[*]," + "script[type|src|language|charset|defer],span[*]",
		theme_advanced_buttons1: "bold,italic,strikethrough,separator,blockquote,formatselect,separator,bullist,numlist,separator,outdent,indent,separator,image,link,unlink,pasteword,separator,code",
		theme_advanced_blockformats : "h1,h2,h3,p",
		width: '100%',
		setup: function (ed) {
			ed.onPaste.add(function (ed) {
				if (ed.getContent().length < 30) {
					setTimeout(function () {
						ed.serializer.setRules("-p,-a[title],-blockquote,br,-code,-dd,-dl,-dt," + "-del,-i/em,-ins,-li,-ol,-pre,-q,-b/strong,-u," + "-ul,-s,img[width|height|alt],hr,-sub,-sup,-strike," + "-small,-big,object[*],embed[*],param[*]," + "-p/h1,-p/h2,-p/h3,-p/h4,-p/h5,-p/h6");
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
			6:{sorter:false}
		},
		widgets: ['zebra'],
		widthFixed: true,
		sortList:[[7,1]]
	}).tablesorterPager({container:$("#pager"), size:20});

	// Sortable Data Table Clickable Rows
	$('#supporters_table tr').click(function() {
		var href = $(this).find("a").attr("href");
		if (href) { window.location = href;}
	});

	// Sortable Data Table Clickable Rows
	$('#contributions_table tr').click(function() {
		var href = $(this).find("a").attr("href");
		if (href) { window.location = href;}
	});
	
	$('#notice.flash_message').delay(3000).slideToggle(600);
	
	// Theme Changing
	$("input[name='site[mongo_theme_id]']").bind("click",function(){
		$.post("/admin/theme/set_theme?id=" + $(this).val(), {"_method":'put'},
			function(data){
				$("#theme_customization_options").html(data);
			}
		);
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
