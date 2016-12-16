/*
done:
split function:
- make Preset for each px
- make 1 gui globally [singleton]

- Presets, seeds etc are stored inside Ndef's Halo !
- GUI's state is stored in Window's Halo


*/
q=q?();
// (global func to get all playable Proxies ;)
q.getActivePxsKeys = { |q, space|
	var mySpace = space ?? { Ndef.dictFor(s); };
	mySpace.envir.select{ |px| px.rate == \audio }.keys.asArray.sort;
};
q.getActivePxsAsList = { |q, space|
	var mySpace = space ?? { Ndef.dictFor(s); };
	var sortedKeys = q.getActivePxsKeys(space).sort;
	sortedKeys.collect({|key|mySpace.envir.at(key)});
};

(
q.makeMeAPreset = {|q, px|
	var pp = NdefPreset(px);
	var path = q.topDir +/+ q.enginesDir +/+  px.key.asString ++ ".pxpreset.scd";
	if(File.exists(path)){"\n** going to load preset % from file %\n".postf(path, path)};
	pp.storePath_(path); // <<<< this solves it !!!!
	pp.loadSettings(path);
	if(pp.settings.notNil){ // load first real preset. at(0) is \curr
		pp.setCurr(pp.settings.wrapAt(1).key);
	}{ "sorry, no settings there yet".warn };
	px.addHalo(\nodeProxyPreset, pp);
}
);
/*
q.makeMeAPreset
q.makeMeAPreset( p[\p_varsawFB]);
q.makeMeAPresetByKey( \n2_frya, p);
p[\n2_frya].getHalo.nodeProxyPreset // OK

var px =  p[\p_varsawFB];
px.dump;
px.key;
p.envir[px.key.postcln]
*/
(
q.ndefPresetWin = {|q, height= 450|
	var pxs = q.getActivePxsAsList;
	var px = pxs.first;

	var pp, w, ppg, ng, hlv, vlv1, vlv2, butrow, randerButs;

	// this should sure be somewhere else..  /
	var maCoolAction = {arg b, char, modifiers, unicode, keycode, key;
		// [modifiers, char.isPrint, unicode, keycode, key].postcln;
		if(char.isPrint){
			var px = w.getHalo(\active1);
			var seed = char.toLower.ascii;
			var much = 1 - (modifiers / 144179); // 0.1 upon shift
			if(char == $1){ seed = q.incrementSeed(px, -1) };
			if(char == $2){ seed = q.incrementSeed(px, 1) };
			px.addHalo(\seed, seed);
			postf("seeding % to Seed % by %\n", px.key, seed, much.round(0.1));
			q.centerToNewRandSeed(q.trinflux, px, seed, much);
		};
	};

	w = Window("Preset for all", Rect(0, -4, 387+100, height)).front;
	hlv = HLayoutView(w, w.bounds.moveTo(0,0));
	vlv1 = VLayoutView(hlv, Rect.new(0,0, 100, hlv.bounds.height)).background_(Color.green.alpha_(0.2));
	vlv2 = VLayoutView(hlv, Rect.new(0,0, 410, hlv.bounds.height));

	butrow = pxs.collect({|px| var name = px.key;
		Button(vlv1, Rect(0,0,100, 30))
		.states_([
			[name], 										// state 0: grey;	stopped unconnected
			[name, Color.black, Color.new255(132, 247, 132)],// state 1: lightgr	playing unconnected
			[name, Color.black, Color.new255(238, 118, 0)], // state 2: orange	st. connected
			[name, Color.black, Color.green(0.62)], 		// state 3: green 	pl. connected
		])
	});
	butrow.do({|but, i|
		but.action_({|b|
			var px = pxs[i];
			q.switchPxINGui(px);
			w.addHalo(\active1, px);
			w.addHalo(\active1i, i);
		}).keyDownAction_(maCoolAction)

	});
	Button(vlv1, Rect(0,0, 48, 20))
	.states_([[' ', Color.clear, Color.clear]]);

	randerButs = 4.collect({|i|
		Button(vlv1, Rect(0,0, 48, 30))
		.states_([
			['rand ' ++ (#[10, 1, -1, -10].wrapAt(i))],
		])
	});

	// BUG: always executes for -all selected by Inphlux, and -first in List
	// should only execute  for -all selected by Inphlux
	// must be sort of a bounceback from Influx
	randerButs.do({|but, i|
		but.action_({|b|
			var px = w.getHalo(\active1);
			q.centerToNewRandSeed(
				q.trinflux,
				px,
				q.incrementSeed(px, #[10, 1, -1, -10].wrapAt(i) )
			);
		});
		but.keyDownAction_(maCoolAction)
	});
	Button(vlv1, Rect(0,0, 48, 30))
	.keyDownAction_(maCoolAction)
	.states_([['centerToCurr']])
	.action({
		q.centerToCurrent(q.trinflux, q.views.presetWin.getHalo(\active1))
	});

	pp = px.getHalo(\nodeProxyPreset); // assumes there is! ToDo: default to making it!
	// ppg = ProxyPresetGui(pp, 0, vlv2);
	ppg = NdefPresetGui(pp, 0, vlv2);
	ng = NdefGui(px, 19, vlv2);
	ng.skipjack.dt=0.1;

	// store state in Window's Halo
	q.views.presetWin = w;
	q.views.presetWin.addHalo(\proxyPresetGui, ppg);
	q.views.presetWin.addHalo(\ndefGui, ng);
	q.views.presetWin.addHalo(\active1i, 0);		// index
	q.views.presetWin.addHalo(\active1, pxs[0]);


	SkipJack({
		var active1i = w.getHalo(\active1i);
		var playStates = pxs.collect{|px|
			px.monitor.isPlaying and: {px.paused.not} and: {px.monitor.vol > 0}
		};
		butrow.do({|b, i|
			b.value_( playStates[i].binaryValue )
		});
		butrow[active1i].value_(playStates[active1i].binaryValue + 2)
	}, 0.2, w.isClosed, "checkplayin");
	w;
}
);

// unified switch Func: OK!
q.switchPxINGui = {|env, px|
	q.views.presetWin.getHalo(\ndefGui).object_(px);
	q.views.presetWin.getHalo(\proxyPresetGui).object_(px.getHalo(\nodeProxyPreset));
};


/*
q.ndefPresetWin;

q.views.presetWin.getHalo(\active1);
q.views.presetWin.addHalo(\active1, 1);

// MAKE - after Ndefs are loaded !

q.switchPxINGui(~n1_robTr);
q.switchPxINGui(p[\p_varsawFB]);
*/