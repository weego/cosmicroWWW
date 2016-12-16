/*
iCon - MODALITY page

per channel:
\sl 	> 	Volume
\sl 	> 	morph preset
\bt\u 	> 	new morph goal
\bt\d 	> 	seed jump
REW/FF	>	:increment direction for preset/&/seed


ToDo:
-	label last moved channel element so we can e.g. use an influx joystick on it.
- 	open in NdefMixer / select as q.currentMixerPx
- 	a discrete param mode ?? also needs to know current channel!
-	joystick:	2 influx axes, would be way cool!
*/


q=q?();
q.faderbox = q.faderbox ? ();
q.faderbox.seedInc = 1;

q.faderbox.midi = MKtl(\icm, "*icontrols-102");
// q.faderbox.hid = MKtl(\ich, "*icontrols-102-hid");


// q.faderbox.midi.trace.gui;
// q.faderbox.hid.trace.gui;


// q.faderbox.midi.postElements;

// REV PLAY FWD > move seed around
q.faderbox.midi.elAt(\tr, \fwd, \on).action = {|el| q.faderbox.seedInc = 1; "faderbox seedInc = %\n".postf(q.faderbox.seedInc)};
q.faderbox.midi.elAt(\tr, \play, \on).action = {|el| q.faderbox.seedInc = nil; "faderbox seedInc = %\n".postf(q.faderbox.seedInc)};
q.faderbox.midi.elAt(\tr, \rew, \on).action = {|el| q.faderbox.seedInc = -1; "faderbox seedInc = %\n".postf(q.faderbox.seedInc)};

(
q.getActivePxsAsList.do{|px, i|

	// SLIDER > VOL
	q.faderbox.midi.elAt(\sl)[i].action = {|el| q.gpFuncs.volFunc(px, (el.value).squared) };

	// KNOB > MORPH
	q.faderbox.midi.elAt(\kn)[i].action = {|el|
		var pres = px.getHalo(\nodeProxyPreset);
		pres.morph(el.value, pres.currSet.key, pres.targSet.key);
	};

	// BUT LOW > Seed Increment
	q.faderbox.midi.elAt(\bt, \1)[i+1].action = { |el|
		if(el.value > 0){
			q.gpFuncs.incSeed(
				px, q.trinflux, q.faderbox.seedInc.postln ? 0,
				false, 0.9, false
			);
			q.faderbox.guiAct(px);
		}
	};
	// BUT UP > morph target!
	q.faderbox.midi.elAt(\bt, \2)[i+1].action = { |el|
		if(el.value > 0){
			var pres = px.getHalo(\nodeProxyPreset);
			'nu morph target: '.post;
			pres.setTarg( // ugly hack to get name.
				// Preset shd have method .setTargByIndex
				pres.getSetNames.at(
					(pres.targIndex ? 0 + q.faderbox.seedInc)
					.wrap(1, pres.getSetNames.size-1).post
				).postc
			).postcln;
			pres.prepMorph;
			q.faderbox.guiAct(px);
		}
	}


}
);

q.faderbox.midi.elAt(\sl).last.action = {|el|
	q.mfx.fx.pxChain.proxy.setUni(\postAmp, el.value);
};
q.faderbox.midi.elAt(\kn).last.action = {|el|
	q.mfx.fx.pxChain.proxy.set(\wet180, el.value);
};



q.faderbox.guiAct = {|env,px| defer{q.views.ndm.editGui.object_(px); }};

/*
q.views.ndm.arGuis
pxgui.edBut
q.views.ndm.edBut
q.views.ndm.editGui.object_(Ndef('n4_revFB'));

*/