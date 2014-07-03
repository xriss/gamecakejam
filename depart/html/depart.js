

$( document ).ready(function() {

var url="http://"+window.location.host+":1111/depart"; // use base domain but change port?

var cssrotate=function(it,d)
{
	$(it).css({
		'-moz-transform':'rotate('+d+'deg) translateZ(0)',
		'-webkit-transform':'rotate('+d+'deg) translateZ(0)',
		'-o-transform':'rotate('+d+'deg) translateZ(0)',
		'-ms-transform':'rotate('+d+'deg) translateZ(0)',
		'transform': 'rotate('+d+'deg) translateZ(0)'
	});
};

// hit the game server as a test

	var cb=function(dat)
	{
		console.log(dat);
	};
	var data={test:"testing123"};
	$.ajax({
		dataType:"jsonp",
		url: url,
		data: data,
		success: cb
	});

// aggressively grab all touch/mouse events

var pressed=false;
var dotouch=function(e,t)
{
	switch(t)
	{
		case "mousedown":
		case "touchstart":
			pressed=true;
		break;
		case "mouseup":
		case "touchend":
			pressed=false;
		break;
	}
	if(pressed)
	{

		var px = undefined;
		var py = undefined;

		if(e.touches && e.touches[0])
		{
			px=e.touches[0].pageX;
			py=e.touches[0].pageY;
		}
		else
		if(e.pageX && e.pageY)
		{
			px=e.pageX;
			py=e.pageY;
		}

		if(px&&py)
		{
			var t = $(".circle");
			var o = t.offset();
			var cx = o.left + (t.width()/2);
			var cy = o.top + (t.height()/2);

			var x=px-cx;
			var y=py-cy;
			var a=180*Math.atan2(y,x)/Math.PI;
			
			cssrotate(".arrow",a);

//			console.log(a,x,y)
		}

//		console.log(e);
	}
	e.preventDefault();
};

document.addEventListener('mousedown' , function(e){ dotouch(e,"mousedown")  }, true);
document.addEventListener('mousemove' , function(e){ dotouch(e,"mousemove")  }, true);
document.addEventListener('mouseup'   , function(e){ dotouch(e,"mouseup")    }, true);
document.addEventListener('touchstart', function(e){ dotouch(e,"touchstart") }, true);
document.addEventListener('touchmove' , function(e){ dotouch(e,"touchmove")  }, true);
document.addEventListener('touchend'  , function(e){ dotouch(e,"touchend")  }, true);

});
