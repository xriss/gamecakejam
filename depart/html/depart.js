

$( document ).ready(function() {

var url="http://"+window.location.host+":1111/depart"; // use base domain but change port?


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
