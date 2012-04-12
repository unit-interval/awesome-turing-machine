var tmDefinition = '0';
var tmDefaultInput = '';
var tmShortUrl = '';
var transfunct = [];
var tmState = '0';
var tmplaystatus = 0;
var animating = false;
var timeout;
var tmTape;

$(function(){
	$('.modal').modal({
		backdrop: 'static',
		show: false
	}).modal('hide');
	$("[rel=tooltip]").tooltip();
	tmTape = $('#tm-tape');
	tmTape.masonry({
		itemSelector: 'div.wrap',
		columWidth: 36,
		isAnimated: true
	});
	if ($('#tm-definition').length > 0) {
		tmDefinition = $('#tm-definition').val();
		tmDefaultInput = $('#tm-default-input').val();
		tmShortUrl = $('#tm-short-url').val();
		tmInitialize();
	}
	var tmOptionsMore = $('#tm-options-more');
	var tmOptionsLess = $('#tm-options-less');
	var tmOptions = $('#tm-options');
	tmOptionsMore.click(function(){
		tmOptions.slideDown('fast');
		tmOptionsMore.addClass('hide');
		tmOptionsLess.removeClass('hide');
	})
	tmOptionsLess.click(function(){
		tmOptions.slideUp('fast');
		tmOptionsLess.addClass('hide');
		tmOptionsMore.removeClass('hide');
	})
	var tmRuleTbody = $('#tm-rule-table tbody');
	tmRuleTbody.find('tr').on('click', 'code', trAction).on('click', '.close', trRemove);
	var tmForm = $('form.form-turing');
	var tmInput = $('#turing_machine_name');
	var tmInitial = tmRuleTbody.find('tr:first-child > td:first-child > ul:first-child > li:first-child');
	tmFormSave(tmForm, tmInput, tmInitial);
	$(tmInput).keyup(function(){
		tmFormSave(tmForm, tmInput, tmInitial, false);
	});
	tmInitial.on('click', 'code', function(){
		tmFormSave(tmForm, tmInput, tmInitial, true);
	})
	tmForm.submit(function(){
		var s = '';
		tmRuleTbody.find('ul.btn-group').each(function(){
			var li = $(this).find('li');
			if ($(this).find('li.chosen').length == li.length) {
				if (li.length == 1) {
					s = String.fromCharCode(stringToAscii(li.find('a').html()));
				}
				if (li.length == 5) {
					li.each(function(index){
						var c = $(this).find('a').html();
						if (index < 4) s += String.fromCharCode(stringToAscii(c));
						else s += String.fromCharCode(shiftToAscii(c));
					})
				}
			}
		});
		$('#turing_machine_definition').val(s);
	});
	$('#tm-control').on('click', 'button', function(){
		var b = $(this);
		if (b.next().length > 0) b.addClass('active').siblings().removeClass('active');
	});
	$('#tm-control-pause').click(function(){
		tmplaystatus = 0;
		clearInterval(timeout);
	});
	$('#tm-control-play').click(function(){
		tmplaystatus = 1;
		clearInterval(timeout);
		timeout = setInterval("tmPlay()", 1000);
	});
	$('#tm-control-fast').click(function(){
		tmplaystatus = 2;
		clearInterval(timeout);
		timeout = setInterval("tmPlay()", 500);
	});
	$('#tm-control-reset').click(function(){
		tmInitialize();
	});
	$('#tm-control-set').click(function(){
		tmSetInput($('#tm-input-set').val());
		tmSetState(tmDefinition);
	});
	$.ajaxSetup({
		cache: false,
		dataType: 'json'
	});
	ajaxifyDelete();
	ajaxifyPlay();
	ajaxifyFavorite();
})

function tmInitialize() {
	tmplaystatus = 0;
	clearInterval(timeout);
	animating = false;
	tmSetState(tmDefinition);
	tmSetTransfunct(tmDefinition);
	tmSetShort(tmShortUrl);
	tmSetInput(tmDefaultInput);
}

function tmSetShort(s) {
	var code = $('#tm-show-table').find('code');
	if (s == '') code.closest('tr').hide().prev().hide();
	else code.html('http://awesometuringmachine.com/s/'+s).closest('tr').show().prev().show();
}

function tmSetTransfunct(tmDef) {
	if (tmDef.length > 0) {
		tmDef = tmDef.slice(1);
		while (tmDef.length >= 5) {
			var s = tmDef.slice(0,5)
			transfunct.push(s);
			tmDef = tmDef.slice(5);
			var c = $('#tm-show-table').find('tr.hide');
			c.clone().insertBefore(c).removeClass('hide').find('a').each(function(index){
				if (index < 4) $(this).html(metaToString(s[index]));
				else $(this).html(metaToShift(s[index]));
			});
		}
	}
	else transfunct = [];
}

function tmSetState(tmDef) {
	if (tmDef.length > 0) tmState = tmDef[0];
	else tmState = '0';
	$('#tm-state').html(tmState);
	$('#tm-show-table').find('tr.hide').prev().find('a').html(tmState);
}

function tmSetInput(a) {
	tmplaystatus = 0;
	clearInterval(timeout);
	$('#tm-control').find('button').removeClass('active');
	if (a == '') a = String.fromCharCode(127);
	var la = a.length;
	var b = tmTape.find('div.wrap');
	var lb = b.length - 2;
	var first = b.first();
	for ( var i = 0; i < la - lb; i++ ) {
		first.clone().insertAfter(first);
	}
	b.slice(la+1, lb+1).remove();
	b = tmTape.find('div.wrap');
	for ( var i = 1; i < la+1; i++ ) {
		b.slice(i,i+1).find('div').html(metaToSymbol(a[i-1]));
	}
	b.slice(1,2).addClass('active').siblings().removeClass('active');
	tmTape.masonry('reload');
}

function tmPlay() {
	if (tmplaystatus == 0 || animating) return false;
	animating = true;
	var time = 1000 / tmplaystatus;
	var cwrap = tmTape.find('div.wrap.active')
	var cdiv = cwrap.find('div');
	var cs = cdiv.html();
	if (cs == '' || cs == ' ') cs = 'blank';
	cs = String.fromCharCode(stringToAscii(cs));
	var success = false;
	var t = '';
	for ( var i = 0, len = transfunct.length; i < len; i++ ){
		t = transfunct[i];
		if (t.length == 5 && t[0] == tmState && t[1] == cs) {
			success = true;
			break;
		}
	}
	if (success) {
		tmState = t[2];
		$('#tm-state').html(tmState);
		cdiv.html(metaToSymbol(t[3]));
		switch(t[4]) {
			case 'L':
				var nwrap = cwrap.prev();
				if (nwrap.prev().length == 0) {
					nwrap = cwrap.clone().insertBefore(cwrap);
					nwrap.find('div').html('');
				}
				cwrap.removeClass('active');
				nwrap.addClass('active');
				tmTape.masonry('reload');
				animating = false;
				break;
			case 'R':
				var nwrap = cwrap.next();
				if (nwrap.next().length == 0) {
					nwrap = cwrap.clone().insertAfter(cwrap);
					nwrap.find('div').html('');
				}
				cwrap.removeClass('active');
				nwrap.addClass('active');
				tmTape.masonry('reload');
				animating = false;
				break;
			default: 
				animating = false;
		}
	}
	else {
		$('#tm-control').find('button').removeClass('active');
		animating = false;
	}
}

function metaToSymbol(s) {
	switch(s.charCodeAt(0)) {
		case 32: return '␣';
		case 127: return ' ';
		default: return s;
	}
}

function metaToString(s) {
	switch(s.charCodeAt(0)) {
		case 32: return '␣';
		case 127: return 'blank';
		default: return s;
	}
}

function metaToShift(s) {
	switch(s) {
		case 'L': return 'shift left';
		case 'R': return 'shift right';
		default: return 'stand still';
	}
}

function stringToAscii(s) {
	switch(s) {
		case '␣': return 32;
		case 'blank': return 127;
		default: return s.charCodeAt(0);
	}
}

function shiftToAscii(s) {
	switch(s) {
		case 'shift left': return 'L'.charCodeAt(0);
		case 'shift right': return 'R'.charCodeAt(0);
		default: return 'N'.charCodeAt(0);
	}
}

function tmFormSave(form, input, initial, b) {
	save = form.find('input[type=submit]');
	if (input.val() != '' && (initial.hasClass('chosen') || b)) save.removeAttr('disabled');
	else save.attr('disabled', 'disabled');
}

function trRemove(event) {
	$(this).closest('tr').hide('normal', function(){ $(this).remove(); });
}

function trAction(event) {
	c = $(this);
	var a = c.parent('div').prev('a');
	a.html(c.html());
	var li = a.parent('li');
	li.addClass('chosen');
	var ul = li.parent('ul');
	var tr = ul.parent('td').parent('tr');
	var trHide = tr.next('tr')
	if (trHide.hasClass('hide') && ul.find('li').length == ul.find('li.chosen').length) {
		trHide.clone().insertAfter(tr).removeClass('hide').hide().show('normal').on('click', 'code', trAction).on('click', '.close', trRemove);
	}
}

function ajaxifyDelete(){
	var modalDelete = $('#modal-delete');
	$('div.content-tm').on('click', 'a[data-method="delete"]', function(event){
		var a = $(this);
		event.preventDefault();
		modalDelete.modal('show');
		$('#modal-delete-btn').data('href', a.attr('href'));
		return false;		
	});
	$('#modal-delete-btn').click(function(){
		var b = $(this);
		var href = b.data('href')
		$.ajax({
			url: href,
			type: 'delete',
			beforeSend: function() {
				if (href.length == 0) return false;
			},
			success: function() {
				modalDelete.modal('hide').on('hidden', function(){ window.location.reload() });
			}
		});
		return false;
	});
}

function ajaxifyPlay(){
	$('div.content-tm').on('click', 'a[data-method="play"]', function(event){
		var a = $(this);
		var b = a.closest('ul').next();
		var name = b.html();
		var c = b.next();
		var desc = c.html();
		var small = c.next().find('small').html().slice(2);
		event.preventDefault();
		var modalplay = $('#modal-play');
		modalplay.modal('show');
		$.ajax({
			cache: true,
			url: a.attr('href'),
			beforeSend: function() {
				$('div.progress').parent('div.modal-inner').removeClass('hide').next().addClass('hide').next().addClass('hide');
			},
			success: function(data){
				tmDefinition = data.definition;
				tmShortUrl = data.short_url;
				tmDefaultInput = data.default_input;
				modalplay.find('div.modal-header > h3').html(name);
				modalplay.find('blockquote').find('p').html(desc).end().find('small').html(small);
				$('span.badge.pull-right').html('Favorited by '+data.users_count+(data.users_cout == 1 ? ' person' : ' people'));
				var f = $('#tm-favorite');
				switch (data.favorited) {
					case true:
						f.removeClass('btn-success').addClass('btn-warning').attr('href', data.href).html('Favorited');
						break;
					case false:
						f.removeClass('btn-warning').addClass('btn-success').attr('href', data.href).html('Favorite');
						break;
				}
				setTimeout( function() { 
					$('div.progress').parent('div.modal-inner').addClass('hide').next().removeClass('hide').next().removeClass('hide');
					tmInitialize();
				}, 750);
			}
		});
		return false;
	});
}

function ajaxifyFavorite(){
	$('#tm-favorite').click(function(){
		var a = $(this);
		if (a.attr('disabled') == 'disabled') return false;
		$.ajax({
			url: a.attr('href'),
			beforeSend: function() {
				a.attr('disabled', 'disabled');
				if (a.html() == 'Favorite') a.html('Favoriting');
				else a.html('Unfavoriting');
			},
			success: function(data) {
				setTimeout( function() {
					a.removeAttr('disabled');
					if (data.favorited) a.removeClass('btn-success').addClass('btn-warning').attr('href', data.href).html('Favorited');
					else a.removeClass('btn-warning').addClass('btn-success').attr('href', data.href).html('Favorite');
					$('span.badge.pull-right').html('Favorited by '+data.users_count+(data.users_cout == 1 ? ' person' : ' people'));					
				}, 500)
			}
		})
		return false;
	})
}
