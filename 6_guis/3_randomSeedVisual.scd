// RandomSeed Visualisation
// Relies on the cosmicro_solo setup with Ndef's Preset in Halo

// start with one ndef
/*
visualize the following dimensions
- x,
- y
- size
- rotation
- proportion or triangle edge
- coloring - RGB, Grey, stripe pattern
*/
// n.getHalo.keys;
// Ndef(\n3_bleepo).getHalo.nodeProxyPreset;
// Ndef(\n3_bleepo).getHalo.seed;

var baseLength = 50;
var visFork, n, w, v;

q=q?();
q.views = q.views ? ();

// n = Ndef(\n3_bleepo);
n = q.currFerrPx;

try{q.views.visul.close};
w = Window("Proxy State Visualisation", Rect(350, 605, 400,400)).front;
w.background_(Color.white);
q.views.visul = w;
v=UserView(w, w.view.bounds.moveTo(0,0));
v.animate = true; //animate this view

Spec.add(\xSc, [0, v.bounds.width]);
Spec.add(\ySc, [ v.bounds.height, 0]);
Spec.add(\xSc, [baseLength*2, v.bounds.width] - baseLength);
Spec.add(\ySc, [ v.bounds.height - baseLength, baseLength]);
Spec.add(\zSc, [5, 20, \exp]);
Spec.add(\zSc, [50, 400, \exp]);
Spec.add(\rot, [0, 2pi]);
Spec.add(\angl, [0.05pi, 0.9pi]);
Spec.add(\grey, [0.9, 0]);
Spec.add(\red, [0.9, 0]);
Spec.add(\green, [0.9, 0]);
Spec.add(\blue, [0.9, 0]);

/*
(
// ver 1
var baseLength = 50;
Spec.add(\zSc, [2, 5, \exp]);
v.drawFunc={|uview|
var ndef = n;
var gfxParams = [\xSc, \ySc, \zSc, \rot, \angl, \red, \green, \blue];
//	var gfxParams = [\xSc, \ySc, \zSc, \rot, \angl, \grey];
var myKeysVals = ndef.getKeysValues.wrapExtend(gfxParams.size);
// do them all at once !?!
var remapParams = {
var dict = ();
myKeysVals.collect{|pair, i|
var key = pair[0], val = pair[1];
var inSpec = n.getSpec(key);
var outSpecKey = gfxParams[i];
var outSpec = outSpecKey.asSpec;
var unmapd = inSpec.unmap(val);
var reMapd = outSpec.map(unmapd);
dict.put(outSpecKey, reMapd);
};
dict;
};
var paramDict = remapParams.value;
// Color.grey(paramDict.grey).set;
Color(paramDict.red, paramDict.green, paramDict.blue).set;
//	Color.hsv(paramDict.red, paramDict.green, paramDict.blue).set;
Pen.translate(paramDict.xSc, paramDict.ySc);
Pen.rotate(paramDict.rot);
Pen.scale(paramDict.zSc, paramDict.zSc);
Pen.addWedge(0@0, baseLength, 0, paramDict.angl);
Pen.fill;
};
);
(
// ver 2, with an arbitrary shape with more points.
var baseLength = 50;
v.drawFunc={|uview|
var ndef = n;
var myKeysVals = ndef.getKeysValues; // .wrapExtend(gfxParams.size);
var gfxParams = [\xSc, \ySc, \zSc, \rot, \grey]; // 5 standards
//	[\6, \7, \8, \9, \10, \11, \12];  // these pair wise
var cornerpoints = (myKeysVals.size - gfxParams.size).roundUp(2) / 2;

var remapParams = {
var pointsList, dict = ();
var numCornerPoints = (myKeysVals.size - gfxParams.size).roundUp(2);

gfxParams.collect{|outSpecKey, i|
var key = myKeysVals[i][0], val = myKeysVals[i][1];
var inSpec = ndef.getSpec(key);
var outSpec = outSpecKey.asSpec;
var unmapd = inSpec.unmap(val);
var reMapd = outSpec.map(unmapd);
dict.put(outSpecKey, reMapd)
};
// now build array:
pointsList = myKeysVals.drop(gfxParams.size).wrapExtend(numCornerPoints)
.collect{|pair, i|
var key = pair[0], val = pair[1];
var inSpec = ndef.getSpec(key);
var outSpecKey = gfxParams[i];
var outSpec = outSpecKey.asSpec;
var unmapd = inSpec.unmap(val);
unmapd
};
dict.put(\pointsList, pointsList.clump(2));

dict;
};
var paramDict = remapParams.value;

Pen.capStyle_(1).joinStyle_(1);
Pen.fillColor = Color.grey(paramDict.grey);
Pen.strokeColor = Color.red;
Pen.translate(paramDict.xSc, paramDict.ySc);
Pen.rotate(paramDict.rot);
Pen.scale(paramDict.zSc, paramDict.zSc);
Pen.width = (0.05);
paramDict.pointsList.do{|pair, i|
Pen.lineTo( pair[0]  @ pair[1]  );
};
// Pen.fillStroke;
// Pen.fillStroke;
Pen.draw(4); // fill and then stroke
// Pen.fill;
};
);
*/
(
// ver 3, like ver 2 with modified draw func
// var baseLength = 50;
v.drawFunc = {|uview|
	var ndef = q.currCybPx;
	var myKeysVals = ndef.getKeysValues; // .wrapExtend(gfxParams.size);
	// var gfxParams = [\xSc, \ySc, \zSc, \rot, \grey]; // 5 standards
	var gfxParams = [\xSc, \ySc, \rot, \zSc, \red, \green, \blue]; // 5 standards
	//	[\6, \7, \8, \9, \10, \11, \12];  // these pair wise
	var dropSoMany;
	var remapParams = {
		var pointsList, dict = ();
		var numCornerPoints = (myKeysVals.size - gfxParams.size).max(1).roundUp(2);

		gfxParams.collect{|outSpecKey, i|
			var key = myKeysVals.wrapAt(i)[0], val = myKeysVals.wrapAt(i)[1];
			var inSpec = ndef.getSpec(key);
			var outSpec = outSpecKey.asSpec;
			var unmapd = inSpec.unmap(val);
			var reMapd = outSpec.map(unmapd);
			dict.put(outSpecKey, reMapd)
		};
		// now build array:
		dropSoMany = gfxParams.size;
		if(myKeysVals.size < gfxParams.size){dropSoMany = 0};
		pointsList = myKeysVals.drop(dropSoMany).wrapExtend(numCornerPoints)
		.collect{|pair, i|
			var key = pair[0], val = pair[1];
			var inSpec = ndef.getSpec(key);
			var outSpecKey = gfxParams[i];
			var outSpec = outSpecKey.asSpec;
			var unmapd = inSpec.unmap(val);
			unmapd
		};
		dict.put(\pointsList, pointsList.clump(2));

		dict;
	};
	var paramDict = remapParams.value;
	Color.grey.set;
	Pen.font = Font("Monaco", 20, true);
	ndef.key.asString.drawAtPoint(250 @ 350);

	//	Pen.fillColor = Color.grey(paramDict.grey);
	Pen.fillColor = Color.hsv(paramDict.red, paramDict.green, paramDict.blue);
	Pen.strokeColor = Color.red;
	Pen.translate(paramDict.xSc, paramDict.ySc);
	Pen.rotate(paramDict.rot);
	Pen.scale(paramDict.zSc, paramDict.zSc);
	Pen.width = (0.05);
	paramDict.pointsList.do{|pair, i|
		Pen.rotate(pair.product);
		Pen.lineTo( pair[0]    @ pair[1]  );
	};
	// Pen.fillStroke;
	// Pen.fillStroke;
	Pen.draw(4); // fill and then stroke
	// Pen.fill;
};
);


v.refresh;
(
// da foak
visFork = {
	{ 	var keysValsCache;
		var ndef = q.currCybPx; // n;
		while { w.isClosed.not } {
			if((ndef.controlKeysValues.hash != keysValsCache))
			{ v.refresh };/*{'idle.'.postc}*/
			keysValsCache = ndef.controlKeysValues.hash;
			40.reciprocal.wait;
		}
	}.fork(AppClock);
}
);
visFork.value;
CmdPeriod.add({visFork.value});

// { while { w.isClosed.not } { v.refresh; 40.reciprocal.wait; } }.fork(AppClock);

/*
n.nodeMap.array
.dump
getKeysValues
n.controlKeysValues
*/












/*
// tests ///
/////////////////////////////////////////////
/////////////////////////////////////////////
var gfxParams = [\xSc, \ySc, \zSc, \rot, \angl, \grey];
n.getKeysValues.size;
n.getKeysValues.wrapExtend(gfxParams.size).collect{|pair, i|
var key = pair[0], val = pair[1];
var inSpec = n.getSpec(key);
var outSpecKey = gfxParams[i];
var outSpec = outSpecKey.asSpec;
var unmapd = inSpec.unmap(val);
var reMapd = outSpec.map(unmapd);
[outSpecKey -> reMapd]
};

f = {
var gfxParams = [\xSc, \ySc, \zSc, \rot, \angl, \grey];
var dict = ();
n.getKeysValues.wrapExtend(gfxParams.size)
.collect{|pair, i|
var key = pair[0], val = pair[1];
var inSpec = n.getSpec(key);
var outSpecKey = gfxParams[i];
var outSpec = outSpecKey.asSpec;
var unmapd = inSpec.unmap(val);
var reMapd = outSpec.map(unmapd);
dict.put(outSpecKey, reMapd)
};
dict;
};
f.()

// ver 2 gets this: //
-> ( 'angl': 2, 'zSc': 0.2, 'rot': 2.9, 'ySc': 63,
'xSc': 22, 'grey': 0.2, 'points': [[4,5], [6,7], [8,9]] )
(
f = {
var ndef = n;
var myKeysVals = ndef.getKeysValues;
var gfxParams = [\xSc, \ySc, \zSc, \rot, \grey]; // 5 standards
//	[\6, \7, \8, \9, \10, \11, \12];  // these pair wise
var pointsList, dict = ();
var numCornerPoints = (myKeysVals.size - gfxParams.size).roundUp(2);

gfxParams.collect{|outSpecKey, i|
var key = myKeysVals[i][0], val = myKeysVals[i][1];
var inSpec = ndef.getSpec(key);
var outSpec = outSpecKey.asSpec;
var unmapd = inSpec.unmap(val);
var reMapd = outSpec.map(unmapd);
dict.put(outSpecKey, reMapd)
};
// now build array:
pointsList = myKeysVals.drop(gfxParams.size).wrapExtend(numCornerPoints)
.collect{|pair, i|
var key = pair[0], val = pair[1];
var inSpec = ndef.getSpec(key);
var outSpecKey = gfxParams[i];
var outSpec = outSpecKey.asSpec;
var unmapd = inSpec.unmap(val);
unmapd
};
dict.put(\pointsList, pointsList.clump(2));

dict;
};
)
f.().postln;\;
q.trinflux.inScaler = 1
*/