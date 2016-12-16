Routine{
	(
		Ndef(\hole).addSpec(\damp, [0, 1]);
		Ndef(\hole).addSpec(\diff, [0, 1]);
		Ndef(\hole).addSpec(\highband, [1000, 10000, \exp]);
		Ndef(\hole).addSpec(\highx, [0, 1]);
		Ndef(\hole).addSpec(\lowband, [100, 6000, \exp]);
		Ndef(\hole).addSpec(\lowx, [0, 1]);
		Ndef(\hole).addSpec(\modDepth, [0, 50]);
		Ndef(\hole).addSpec(\modFreq, [0, 10]);
		Ndef(\hole).addSpec(\midx, [0, 1]);
		Ndef(\hole).addSpec(\size, [0.5, 3]);
		Ndef(\hole).addSpec(\t60, [0.1, 60, \exp]);
		Ndef(\hole).addSpec(\wet, [0, 1]);
		Ndef(\hole).addSpec(\shelfslope, [1, 10]);
		Ndef(\hole).addSpec(\shelfFreq, \freq);
		Ndef(\hole).addSpec(\fb, [0, 1]);
		Ndef(\hole).addSpec(\dtime, [0, 2]);

		Ndef(\hole, {
			var src, delay, amp;

			src = \in.ar([0, 0]);
			// var src = Impulse.ar(0.5);

			delay = Greyhole.ar(
				src,
				\dtime.kr(0.1),
				\damp.kr(0.1),
				\size.kr(1),
				\diff.kr(0.707),
				\fb.kr(0.1),
				\modDepth.kr(0.01),
				\modFreq.kr(2)
			);
			delay
		});
	);
	s.sync;
	ProxySubmix(\holeAux).ar(2);
	s.sync;
	Ndef(\hole).map(\in, ProxySubmix(\holeAux));
}.play;