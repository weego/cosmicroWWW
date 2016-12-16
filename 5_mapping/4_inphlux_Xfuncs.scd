// NEW INFLUX METACTL : :
// with lots of functions for switching Ndef presets and setting Influx's offsetsFromPreset.

// init the currently selectedProxy !
q.currFerrPx = q.getActivePxsAsList.first;
// q.trinflux.attachMapped( Ndef(q.currFerrPx) );

q.resetInphl = {
	q.trinflux.inValDict.keys.do({|k| q.trinflux.set(k, 0) });
};
/*
q.trinflux.inValDict.keysValuesDo({|a, b| [a,b].postln;});
q.trinflux.outValDict.printAll;
q.trinflux.outValDict.keys;
q.trinflux.inValDict;
q.trinflux.set(\x, 0)
q.trinflux.weights.shape;
q.trinflux.outOffsets;
q.trinflux.outOffsets.size;
*/

// fi a Start ... set influx weights to the year's random value
q.seedRandInfl = {|q, infl, seed|
	var cachData;
	seed = seed ?? { Date.getDate.year };
	cachData = thisThread.randData;
	thisThread.randSeed_(seed);
	infl.rand;
	thisThread.randData_(cachData);
};
q.seedRandInfl(q.trinflux);

/// FIX THESE!!


// ASSUME preset is stored in Ndef.getHalo(\nodeProxyPreset)
// STORE current presNr in px.addHalo(\curPresNr)
// STORE current seed in px.addHalo(\curRandSeed)
// choose a random preset. xset here fails!
(
q.centerToCurrent = {|q, infl, px|
	infl.offsetsFromProxy(px);
	q.resetInphl;
};

// return new preset name; this shd be a method of the Preset Class.
q.incrementPreset = {|q, px, inc=1|
	var index, nuSet;
	var preset = px.getHalo(\nodeProxyPreset);
	if(preset.notNil){
		index = preset.currIndex + inc;
		nuSet = preset.settings.wrapAt(index).key;
		postf("nu set: %\n", nuSet);
		nuSet;
	}{ "sorry, no preset present".warn }
};

q.centerToNewPreset = { |q, infl, px, setName, xFade=false|
	var preset = px.getHalo(\nodeProxyPreset);
	infl.offsetsFromPreset(preset, setName);
	q.resetInphl;
	if(xFade){
		preset.xsetCurr(setName);

	}{
		preset.setCurr(setName);
	};
	setName; // return idem
};
/*
preset.xsetCurr(setName); // shd work, too!

test:
q.centerToNewPreset(q.trinflux, q.currFerrPx, q.incrementPreset(q.currFerrPx, 1));
*/

// xset shd work ?!? but it is not at all safe!
q.incrementSeed = {|q, px, inc=1|
	var preset = px.getHalo(\nodeProxyPreset);
	var seed = px.getHalo(\seed) ? 0;
	if(preset.notNil){
		seed = seed + inc;
		postf("nu seed: %\n", seed);
		px.addHalo(\seed, seed);
		seed;
	}{"sorry, no preset present".warn}
};

q.centerToNewRandSeed = {|q, infl, px, seed=2011, much=1, xFade=false|
	var preset = px.getHalo(\nodeProxyPreset);
	if(xFade){
		preset.xsetRand(much, seed: seed)
	}{
		preset.setRand(much, seed: seed);
	};
	infl.offsetsFromProxy(px); 	// 0ne of these 2 causes bounceback ..  |this one rand's just once
	q.resetInphl; 				// or this
	seed
};
);
/*
preset.xsetRand(much, seed: seed); // shd work, too

test:
q.centerToNewRandSeed(q.trinflux, q.currFerrPx, q.incrementSeed(q.currFerrPx, 1));
q[\centerToNewRandSeed].asCode


q.centerToNewRandSeed(q.trinflux, Ndef(\n1_robTr), 22.rand.postln)
*/

q.trinflux.inScaler = 2/3;