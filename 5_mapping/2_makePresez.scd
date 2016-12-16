(
// n ProxyPresets, 1 fo' each.
q.getActivePxsAsList.do({|px, i|
	q.makeMeAPreset( px );
});
);


// 1 window
q.ndefPresetWin;

q.switchPxINGui( q.getActivePxsAsList.first );

/*
q.getActivePxsAsList( Ndef.dictFor(s) )
q.centerToNewRandSeed(q.trinflux, Ndef(\n7_RJKchaos), 12.rand.postln);
*/
