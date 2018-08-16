"use strict";
$('#header').html('max bet = <span id="maxbet">0.00000000</span> - profit = <span id="profit">0.00000000</span> - winstreak = <span id="winstreak">0</span> - max winstreak = <span id="maxwinstreak">0</span> - lose streak = <span id="losestreak">0</span> - max losestreak = <span id="maxlosestreak">0</span>');
$('#header').css('color', '#fff');
$('#header').css('font-size', '20px');
$('#header').css('text-align', 'center');
$('#gameContainer').html('<div id="chart"></div>');
$('#gameContainer').css('width', '1000px');
$('#gameContainer').css('margin', 'auto');
var bba = prompt('input base bet', '0.00000000');
var tgbl = prompt('input target balance', '0.00000000');
var ba = bba;
var nb = ba;
var mba = 0;
var p = 98;
var d = 'under';
var cs = $("#clientSeed").val();
var ssh = $("#serverSeedHash").html();
var b = 0;
var w = 0;
var ws = 0;
var mws = 0;
var l = 0;
var ls = 0;
var mls = 0;
var bl = 0;
var bl2 = 0;
var pf = 0;
var lc = 0;
var dps = [];
var chart;
var preb = 0;
var cl = '';
$.getScript('https://canvasjs.com/assets/script/canvasjs.min.js').done(function(script, textStatus) {
    dps = [{
        x: 0,
        y: 0
    }];
    chart = new CanvasJS.Chart('chart', {
        theme: 'light2',
        zoomEnabled: true,
        axisX: {
            title: 'Bet',
            includeZero: false,
        },
        axisY: {
            title: 'Profit',
            includeZero: false,
        },
        title: {
            text: 'Dev by Mai Hoang Quoc Bao',
            fontSize: 20,
            padding: 20
        },
        data: [{
            type: 'stepLine',
            dataPoints: dps
        }]
    });
    chart.render();
});

function draw() {
    dps.push({
        x: b,
        y: pf,
        color: cl
    });
    if (dps[dps.length - 2]) {
        dps[dps.length - 2].lineColor = cl;
    }
    if (dps.length > 1000) {
        dps.shift();
    }
    chart.render();
}

function log(rsg, rsn, rsp) {
    $('#maxbet').html(parseFloat(mba).toFixed(8));
    $('#profit').html(parseFloat(pf).toFixed(8));
    $('#winstreak').html(ws);
    $('#maxwinstreak').html(mws);
    $('#losestreak').html(ls);
    $('#maxlosestreak').html(mls);
    console.log(parseFloat(ba).toFixed(8) + ' ' + d + ' ' + p + ' roll ' + rsn + ' ' + rsg + ' ' + parseFloat(rsp).toFixed(8));
}
setTimeout(function dobet() {
    jQuery.ajax({
        url: 'https://play.' + user.domain + '/ajx/',
        type: 'POST',
        dataType: 'html',
        timeout: 6e4,
        data: {
            game: 'dice',
            session: getCookie('SESSION'),
            coin: $('#coin').val(),
            betAmount: ba,
            prediction: p,
            direction: d,
            clientSeed: cs,
            serverSeedHash: ssh,
            action: 'playBet',
            hash: user.hash
        },
        success: function(r) {
            var res = JSON.parse(r);
            if (res.result === true) {
                $("#balance").val(res.balance);
                b++;
                bl = parseFloat(res.balance);
                pf += parseFloat(res.profit);
                ssh = res.serverSeedHash;
                if (res.gameResult === 'win') {
                    w++;
                    ws++;
                    ls = 0;
                    cl = 'green';
                } else {
                    l++;
                    ls++;
                    ws = 0;
                    cl = 'red';
                }
                ba >= mba ? mba = ba : mba = mba;
                ws >= mws ? mws = ws : mws = mws;
                ls >= mls ? mls = ls : mls = mls;
                draw();
                log(res.gameResult, res.resultNumber, res.profit);
                if (res.gameResult === 'win') {	
					p = Math.floor((Math.random() * 15) + 65);
                    ba = bba;
					if (bl > bl2) {
						nb = bba * 5;
						bl2 = bl;
					} else {
						nb = (bl2 - bl)
						if (nb < bba * 5) {
							nb = bba * 5;
						}
					}
                } else {
					if (ls >= 1){
						p = 47;
						ba = preb;
					}
					
					if (ls >= 2) {
						if (nb < (bl2 - bl)) {
							p = 60;
							ba = (bl2 - bl) * 2;
						} else {
							ba = nb;
						}
					}
					
					if (ls >= 3) {
						p = 50;
						ba = preb * 1.56;
					}
					
					if (ls >= 4) {
						ba = bba;
					}
                }
				preb = ba;
                if (tgbl != 0 && bl >= tgbl) {
                    alert("target done");
                    return;
                } else {
                    dobet();
                }
            } else {
                setInterval(dobet(), 5e2);
            }
        }
    });
}, 2e3);
