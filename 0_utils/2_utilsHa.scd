
// // legacy  methods to get to processes:
// // limit to sounding ndefs
q.utils.getNdefs = { Ndef.dictFor(s).envir.select({ |ndef| ndef.rate == \audio }).asArray.sort { |px1, px2| px1.key < px2.key } };
q.utils.getTdefs = { Tdef.all.values.asArray.sort { |px1, px2| px1.key < px2.key } };
q.utils.getPdefs = { Pdef.all.values.asArray.sort { |px1, px2| px1.key < px2.key } };
//
// q.utils.getInfluxDestins = {
// 	// automagically attach all existing proxies to GUI Buttons. (max. 5 for now..)
// 	q.utils.getNdefs ++ q.utils.getTdefs ++ q.utils.getPdefs
// };


///// Ha privates
// (global func to get all playable Proxies ;)
q.getActivePxsAsList = { |q, space|
	var names = space.envir.select { |px| px.rate == \audio }.keys.asArray.sort;
	// names.collect({|n| p[n]});
	names
};

(
q.makeMeAPreset = {|q, px|
	var pp, w, ppg, ng, shrink = -60;
	var xpos = px.getHalo(\scene) ? 0;
	pp = NodeProxyPreset(p.envir[px.key]);
	// must be in folder of preset file or fails... or link to preset file loc.!
	pp.loadSettings;
	if(pp.settings.notNil){ // load first real preset ...
		pp.setCurr(pp.settings.wrapAt(1).key);
	}{ "sorry, no settings there yet".warn };
	px.addHalo(\nodeProxyPreset, pp);
}
);(
q.makeMeAPresetByKey = {|q, key, space|
	var pp, w, ppg, ng, shrink = -60;
	var px = if(space.notNil){space[key]}{Ndef(key)}; // huhu!!
	var xpos = px.getHalo(\scene) ? 0;
	pp = NodeProxyPreset(px);
	// must be in folder of preset file or fails... or link to preset file loc.!
	pp.loadSettings;
	if(pp.settings.notNil){ // load first real preset ...
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