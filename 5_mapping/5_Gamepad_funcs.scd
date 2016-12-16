/*
not really finished nor used!
some useful generic funcs like play/stop/pause are sketched here; alsoroomAndWing Selection

Done:
- select all exist. pxs in p
- add pause/play/vol to them

// better do it w' the generic Influx interface that can select multiple sources? ! yes
// and better send Gamepad Data via OO, SAME like in FaceOSC !
*/
q=q?();

q.gpFuncs = q.gpFuncs ? ();

// map these to GamePad !!
q.gpFuncs.startFunc = {|env, px| px.resume.play; "start playing".postln; };
q.gpFuncs.stopFunc =  {|env, px| px.stop; "stop playing".postln; };
q.gpFuncs.startStopToggle = {|env, px| if(px.monitor.isPlaying){q.gpFuncs.stopFunc(px)}{q.gpFuncs.startFunc(px)} };

q.gpFuncs.volFunc = {|env, px, val=0|
	if(val < 0.01){
		if(val < 0.002)  // 1/0.001
		{px.pause}
		{
			if(px.monitor.isPlaying.not){px.play};
			if(px.paused){px.resume};
		}
	};
	px.vol_(val);
};


// attach to NuGui as well!


// the dirty but visual way: via the GUI !/-0-93-204924@$!$%

// remote ctl the Buttons
q.gpFuncs.remoteToggleButton = { |env|
	var buttons = q.trinfluxKtlGui.leftButtonV.children.keep(-5);
	var but = buttons.select({|b| b.states[0].unbubble == q.currPxKey }).unbubble; // assume there is one!
§
//	if(but.value == 1){ q.currPx.stop;};
	but.valueAction_( 1 - but.value, 3 );
};

q.gpFuncs.incPreset = {|env, px, influx, inc=1, shift=false|
		if(shift){inc=inc*10};
		q.centerToNewPreset(
			influx,
			px,
			q.incrementPreset(px, inc)
		);
};
q.gpFuncs.incSeed = {|env, px, influx, inc=1, shift=false, much=0.9, xFade=false|
		if(shift){inc=inc*10};
	['1stFunc', px, influx, inc].postcln;
		q.centerToNewRandSeed(
			influx,
			px,
			q.incrementSeed(px, inc),
			much,
			xFade
		);
};


/*
q.trinflux.detach( \n1_robTr );
q.trinflux.detach( p[\n1_robTr] );
q.trinflux.action
p[\n1_robTr].key

q.gpFuncs.remoteToggleButton;
524288.	isAlt
123.	isAlt
10000.rand.isAlt
{ ^this.bitAnd(524288) == 524288 }
*/