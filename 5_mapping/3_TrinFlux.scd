// just the Influx in OO style

// > works only with NETWORK ON !!!!
q = q ? ();

"abcdefghijklmnopqrstuvwxyz".do { |ch| Spec.add(ch.asSymbol, \bipolar.asSpec) };

q.trinflux = Influx(
	9,
	q.getActivePxsAsList.collect({|k| k.controlKeys.size}).maxItem
);
q.views.influx = InfluxKtlGui(q.trinflux, q.getActivePxsAsList.size-1, options: [\loop]).moveTo(0, 620);
q.views.influx.skipjack.dt = 0.05;

(
// ATTACH TO GUI - do this after all Ndefs have been loaded
q.getActivePxsAsList.keep( q.views.influx.numItems ? 6)
	.do({|px, i|
		q.views.influx.attachToButton(i, px);
	});
);

// Quarks.install("OpenObject");
OpenObject.put(\trinflux, q.trinflux);
try{
	OpenObject.start;
}{"OpenObject could not Start !!! LangPort problem!".warn; };
/*
// this is really needed just when playing the sliderGui in a network \\
(
q.views.influx.xySlider.action = { |sl|
	var gui, object, xyMapDict;
	gui = q.views.influx;
	object = gui.object;
	if (object.notNil) {
		xyMapDict = gui.xyMapDict;
		try{
			q.net.broad.sendMsg("/oo", \trinflux, \set,
				xyMapDict[\x], sl.x.unibi,
				xyMapDict[\y], sl.y.unibi
			);
		};
	};
};
);
*/

/*
OpenObject.keyFor(q.trinflux)
q.trinflux.attachMapped(Ndef(\n4_revFB))
b.attachToButton(0, Ndef(\a));
q.trinflux.dump
*/
