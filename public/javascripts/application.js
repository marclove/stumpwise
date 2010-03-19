// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//$(function(){
	//$("#docs h5 a").click(function(){var a=$(this).attr("href");$(a).slideToggle();return false});
	//$(".parameter").hide();
	//$("select, input[type='checkbox'], input[type='radio'], input[type='file']").uniform();
	//$('body').toggleClass('aristo');
	//$("a.btn[rel='disable']").live("click",function(){$("select, input[type='checkbox'], input[type='radio'], input[type='file']").attr("disabled",true);
	//$.uniform.update();
	//$(this).attr("rel","enable").text("Enable All");return false});
	//$("a.btn[rel='enable']").live("click",function(){$("select, input[type='checkbox'], input[type='radio'], input[type='file']").removeAttr("disabled");
	//$.uniform.update();
	//$(this).attr("rel","disable").text("Disable All");return false});
	//$("a.btn[rel='reset']").click(function(){$("form").get(0).reset();$.uniform.update();return false});
	//$("a.btn[rel='theme']").click(function(){$("#example").toggleClass("aristo");return false})
	//});

$(document).ready(function() {

	// TinyMCE Textareas
	$('textarea.tinymce').tinymce({
		// Location of TinyMCE script
		script_url : '/javascripts/tiny_mce/tiny_mce.js',
		mode: "exact",
		entities: "",
		convert_newlines_to_brs: false,
		theme: "advanced",
		remove_trailing_nbsp: true,
		theme_advanced_layout_manager: "SimpleLayout",
		theme_advanced_buttons2: "",
		theme_advanced_buttons3: "",
		theme_advanced_toolbar_location: "top",
		content_css: "/stylesheets/custom_tinymce.css",
		plugins: "spellchecker,safari,pagebreak",
		convert_urls: false,
		process_html: true,
		inline_styles: false,
		gecko_spellcheck: true,
		valid_elements: "-p[class],-a[name|id|title|target|href],-blockquote[class],br,-code[class]," + "-dd[*],-dl[*],-dt[*],-del[*],-i/em[class],-ins[*],-li[*],-ol[*],-pre[class]," + "-q[*],-b/strong[class],-u[*],-ul[*],-s[*],img[*],hr[*],-sub[*]," + "-sup[*],-strike[*],-small[*],-big[*],-h1[id|class],-h2[id|class],-h3[id|class]," + "-h4[id|class],-h5[id|class],-h6[id|class],object[*],embed[*],param[*]," + "script[type|src|language|charset|defer],span[*]",
		theme_advanced_buttons1: "bold,italic,strikethrough,separator,bullist,numlist,separator,outdent,indent,separator,image,link,unlink,separator,code",
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
			3:{sorter:false},
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

});


/*
function render_editor(id, type, interface, immediate) {
	if (interface === 'robust') {
		var robust = true;
		var light = false
	} else if (interface) {
		var robust = false;
		var light = true
	} else {
		var robust = false;
		var light = false
	}
	if ((!type || type == 'rich') && tinyMCE) {
		function initEditor() {
			tinyMCE.init({
				mode: "exact",
				//language: language_for_tinymce,
				elements: id,
				entities: "",
				convert_newlines_to_brs: false,
				theme: "advanced",
				remove_trailing_nbsp: true,
				theme_advanced_layout_manager: "SimpleLayout",
				theme_advanced_buttons2: "",
				theme_advanced_buttons3: "",
				theme_advanced_toolbar_location: "top",
				content_css: "/stylesheets/custom_tinymce.css",
				plugins: "spellchecker,safari,pagebreak",
				convert_urls: false,
				process_html: true,
				inline_styles: false,
				gecko_spellcheck: true,
				valid_elements: "-p[class],-a[name|id|title|target|href],-blockquote[class],br,-code[class]," + "-dd[*],-dl[*],-dt[*],-del[*],-i/em[class],-ins[*],-li[*],-ol[*],-pre[class]," + "-q[*],-b/strong[class],-u[*],-ul[*],-s[*],img[*],hr[*],-sub[*]," + "-sup[*],-strike[*],-small[*],-big[*],-h1[id|class],-h2[id|class],-h3[id|class]," + "-h4[id|class],-h5[id|class],-h6[id|class],object[*],embed[*],param[*]," + "script[type|src|language|charset|defer],span[*]",
				theme_advanced_buttons1: (light ? "bold,italic,separator," + "bullist,numlist,separator," + "link,unlink,separator,code": "bold,italic,strikethrough,separator," + "bullist,numlist,separator,outdent,indent,separator," + "image,link,unlink,separator," + "spellchecker," + (robust ? "separator,pagebreak,": "") + "separator,code"),
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
			})
		}
		if (immediate) {
			initEditor()
		} else {
			$(window).load(initEditor);
			//Event.observe(window, 'load', initEditor)
		}
		// if (document.getElementById(id + '_is_rich_text')) {
		// 	document.getElementById(id + '_is_rich_text').value = 1
		// }
	// } else {
	// 	var toolbar = document.createElement('div');
	// 	toolbar.innerHTML = '<div class="editor_controls"><div class="editor_note">' + (type == 'markdown' ? '<a href="http://daringfireball.net/projects/markdown/syntax" target="_blank" style="color:#888;">' + localized_str_markdown + '</a>': localized_str_html_enabled) + '</div><a href="#" class="editor_button" onclick="' + (type == 'markdown' ? 'insertTag(\'' + id + '\', \'**\', \'**\');': 'insertTag(\'' + id + '\', \'<b>\', \'</b>\');') + ' return false;"><img title="' + localized_str_bold + '" alt="' + localized_str_bold + '" src="/images/editor_bold.gif"/></a><a href="#" class="editor_button" onclick="' + (type == 'markdown' ? 'insertTag(\'' + id + '\', \'_\', \'_\');': 'insertTag(\'' + id + '\', \'<i>\', \'</i>\');') + ' return false;"><img title="' + localized_str_italic + '" alt="' + localized_str_italic + '" src="/images/editor_italic.gif"/></a>' + ((type == 'markdown') ? '': '<a href="#" class="editor_button" onclick="insertTag(\'' + id + '\', \'<strike>\', \'</strike>\'); return false;"><img title="' + localized_str_strikethrough + '" alt="' + localized_str_strikethrough + '" src="/images/editor_strikethrough.gif"/></a>') + '<a href="#" class="editor_button" onclick="' + (type == 'markdown' ? 'insertTag(\'' + id + '\', \'[\', \'](\' + prompt(\'' + localized_str_enter_the_url + '\', \'http://\') + \')\');': 'insertTag(\'' + id + '\', \'<a href=&quot;\' + prompt(\'' + localized_str_enter_the_url + '\', \'http://\') + \'&quot;>\', \'</a>\');') + ' return false;"><img title="' + localized_str_insert_link + '" alt="' + localized_str_insert_link + '" src="/images/editor_link.gif"/></a></div>';
	// 	document.getElementById(id).parentNode.insertBefore(toolbar, document.getElementById(id));
	// 	document.getElementById(id).style.height = (parseInt(document.getElementById(id).style.height) - 30) + 'px'
	}
}
function insertTag(field_id, start, end) {
	field = document.getElementById(field_id);
	if (!end) end = '';
	if (document.selection) {
		field.focus();
		sel = document.selection.createRange();
		sel.text = start + sel.text + end;
		field.focus()
	} else if (field.selectionStart || field.selectionStart == '0') {
		var startPos = field.selectionStart;
		var endPos = field.selectionEnd;
		var cursorPos = endPos;
		var scrollTop = field.scrollTop;
		field.value = field.value.substring(0, startPos) + start + field.value.substring(startPos, endPos) + end + field.value.substring(endPos, field.value.length);
		cursorPos += start.length + end.length;
		field.focus();
		field.selectionStart = cursorPos;
		field.selectionEnd = cursorPos;
		field.scrollTop = scrollTop
	} else {
		field.value += start;
		field.value += end;
		field.focus()
	}
}
*/