(
q = q ? ();

// modulating formant frequency
Ndef(\n5_moogSing).ar(q.numChans);
Ndef(\n5_moogSing).source = { arg moogRoot=24, lpRatio=36, lfSpeed=0.35, lfDepth=24, rq=0.2;
	var in;
	in = LFSaw.ar(
		(moogRoot.lag(0.5).round(1.5).lag(0.05)
			+ LFDNoise3.kr(lfSpeed, [0, 0.1, 0.2.neg, ])
		).midicps,
		0, 0.3).sum;

	Limiter.ar(
		RLPF.ar(
			in,
			(moogRoot.midicps *
				(	lpRatio.lag(0.5)
					+ LFNoise2.kr(
						lfSpeed,
						[0.1, -0.1, 1, 0.9 ] * lfDepth.lag(0.2)
					)
			).midiratio).clip(20, 17000),
			rq
		).clump(min(4, q.numChans)).sum,
		1
	);
};
Ndef(\n5_moogSing).play(vol: 0);

Ndef(\n5_moogSing).addSpec(\moogRoot, ControlSpec(10, 40, \lin, 0.5));
Ndef(\n5_moogSing).addSpec(\lpRatio, ControlSpec(12, 60, \lin));
Ndef(\n5_moogSing).addSpec(\lfSpeed, ControlSpec(0, 8, 5));
Ndef(\n5_moogSing).addSpec(\lfDepth, ControlSpec(0, 48, \lin));


)
/*
Ndef(\n5_moogSing).gui;
Ndef(\n5_moogSing).vol_(10);
Ndef(\n5_moogSing).set(\rq, 0.1);
*/