function updateOs (request_url, range, from, to, seg) {
	$.ajax({
		url: '/ajax/fetch_sc_data_os',
		data: {
			url : request_url,
			time_period : range,
			start : from,
			end : to,
			type : 'os',
			segment : seg
		},
		dataType: "json",
		type: 'POST',
		success: function(result) {
			var items = [];
			$.each(result.row, function(key,val) {
				items.push('<tr><td><a href="/url?url=' + request_url + '&seg=custom_operatingSystem_' + val.operatingSystem + '&from='+from+'&to='+to+'">' + val.operatingSystem + '</a></td><td align="right">' + nCommas(val.visits) + '</td></tr>');
			});
			$('#os .loadingrow').remove();
			$('#os').append(items);
		}
	});
}

function updateReferrers (request_url, range, from, to, seg) {
	$.ajax({
		url: '/ajax/fetch_sc_referrers',
		data: {
			url : request_url,
			time_period : range,
			start : from,
			end : to,
			type : 'referrers',
			segment : seg
		},
		dataType: "json",
		type: 'POST',
		success: function(result) {
			var items = [];
			$.each(result.row, function(key,val) {
				items.push('<tr><td><a href="/url?url=' + request_url + '&seg=custom_referrer_' + val.referrer + '&from='+from+'&to='+to+'">' + val.referrer + '</a></td><td align="right">' + nCommas(val.visits) + '</td></tr>');
			});
			$('#referrers .loadingrow').remove();
			$('#referrers').append(items);
		}
	});
}

function updateDomains (request_url, range, from, to, seg) {
	$.ajax({
		url: '/ajax/fetch_sc_data_referDomain',
		data: {
			url : request_url,
			time_period : range,
			start : from,
			end : to,
			type : 'referDomain',
			segment : seg
		},
		dataType: "json",
		type: 'POST',
		success: function(result) {
			var items = [];
			$.each(result.row, function(key,val) {
				items.push('<tr><td><a href="/url?url=' + request_url + '&seg=custom_referringDomain_' + val.domain + '&from='+from+'&to='+to+'">' + val.domain + '</a></td><td align="right">' + nCommas(val.visits) + '</td></tr>');
			});
			$('#domains .loadingrow').remove();
			$('#domains').append(items);
		}
	});
}

function updateSocial (request_url) {
	$.ajax({
		url: '/ajax/fetch_social',
		data: {
			url : request_url,
		},
		dataType: "json",
		type: 'POST',
		success: function(result) {
			var items = [];
			
			$.each(result, function(arr_index, hash) {
				$.each(hash, function(key, val) {
					items.push('<tr><td>' + key + '</td><td align="right">' + nCommas(val) + '</td></tr>');
				});
			});
			$('#social .loadingrow').remove();
			$('#social').append(items);
		}
	});
}

function loadSourcesPie(request_url, range, from, to, seg) {
	var items = [];
	$.ajax({
		url: '/ajax/fetch_sc_data_sources',
		data: {
			url : request_url,
			time_period : range,
			start : from,
			end : to,
			type : 'sources',
			segment : seg
		},
		dataType: "json",
		type: 'POST',
		success: function(result) {
			var tally = 0;
			$.each(result.row, function(key, val) {
				items.push({ name : val.source, y : Number(val.visitors), url : '/url?url=' + request_url + '&seg=custom_referrerType_' + val.source + '&from='+from+'&to='+to });
				tally = tally + Number(val.visitors);
			});
			var others = Number(result.total_visitors);
			items.push(['Others', others - tally]);

			sourcesPie.hideLoading();
			sourcesPie.addSeries({point: {
					events: {
						click: function(e) {
							//this.slice();
							//console.log(e);
							location.href = e.point.url;
							e.preventDefault();
						}
					}
				},name : 'Traffic share', data : items});
		}
	});
}

function loadIntExtPie(internal, external) {
	intExtPie.hideLoading();
	intExtPie.addSeries({name : 'Source', data : [['Internal', internal], ['External', external]]});
}

function loadTrafficArea(request_url, range, from, to, seg) {
	$.ajax({
		url: '/ajax/fetch_overtime_chart',
		data: {
			url : request_url,
			time_period : range,
			start : from,
			end : to,
			% if (param 'refresh') {
			refresh : 1,
			% }
			segment : seg
		},
		dataType: "json",
		type: 'POST',
		success: function(result) {
			var Visitors = [];
			var PageViews = [];
			var Entrances = [];

			$.each(result.visitors.row, function(arr_index, hash) {
				$.each(hash, function(key,val) {
					if (key == 'visitors') {
						Visitors.push( Number(val) );
					} else if (key == 'pageviews') {
						PageViews.push( Number(val) );
					} else if (key == 'entrances') {
						Entrances.push( Number(val) );
					}
				});
			});
			var year = result.visitors.row[0].date[0];
			var month = result.visitors.row[0].date[1];
			var day = result.visitors.row[0].date[2];
			var hour = result.visitors.row[0].hour;

			trafficArea.hideLoading();
			trafficArea.addSeries({
				name : 'Visitors', 
				data : Visitors,
				pointStart : Date.UTC(year, month - 1, day, hour), 
				pointInterval : <%= $point_interval %>
			});
			trafficArea.addSeries({
				name : 'Pageviews', 
				data : PageViews,
				pointStart : Date.UTC(year, month - 1, day, hour), 
				pointInterval : <%= $point_interval %>
			});
			trafficArea.addSeries({
				name : 'Entrances', 
				data : Entrances,
				pointStart : Date.UTC(year, month - 1, day, hour), 
				pointInterval : <%= $point_interval %>
			});

			var internal = Number(result.visitors.total_pageviews - result.visitors.total_entrances);
			var external = Number(result.visitors.total_entrances);
			$('#total_pageviews').html(nCommas(result.visitors.total_pageviews));
			$('#total_visitors').html(nCommas(result.visitors.total_visitors));

			intExtPie.hideLoading();
			intExtPie.addSeries({name : 'Source', data : [['Internal', internal], ['External', external]]});
		}
	});
}

function updateCountries (request_url, range, from, to, seg) {
	$.ajax({
		url: '/ajax/fetch_sc_data_country',
		data: {
			url : request_url,
			time_period : range,
			start : from,
			end : to,
			type : 'country',
			segment : seg
		},
		dataType: "json",
		type: 'POST',
		success: function(result) {
			var items = [];
			$.each(result.row, function(key,val) {
				items.push('<tr><td><a href="/url?url=' + request_url + '&seg=custom_geoCountry_' + val.country + '&from='+from+'&to='+to+'">' + val.country + '</a></td><td align="right">' + nCommas(val.visits) + '</td></tr>');
			});
			$('#country .loadingrow').remove();
			$('#country').append(items);
		}
	});
}