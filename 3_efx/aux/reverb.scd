ProxySubmix(\zReverbAux).ar(2);

Ndef(\zReverbR).addSpec(\t60, [0.1, 60, \exp]);
Ndef(\zReverbR).addSpec(\damp, [0, 1]);
Ndef(\zReverbR).addSpec(\size, [0.5, 3]);
Ndef(\zReverbR).addSpec(\earlydiff, [0, 1]);
Ndef(\zReverbR).addSpec(\mdepth, [0, 50]);
Ndef(\zReverbR).addSpec(\mfreq, [0, 10]);
Ndef(\zReverbR).addSpec(\lowx, [0, 1]);
Ndef(\zReverbR).addSpec(\midx, [0, 1]);
Ndef(\zReverbR).addSpec(\highx, [0, 1]);
Ndef(\zReverbR).addSpec(\lowband, [100, 6000, \exp]);
Ndef(\zReverbR).addSpec(\highband, [1000, 10000, \exp]);

/*
Ndef(\zReverbR).set('lowx', 0.52777777777778, 't60', 8.2004470369725, 'damp', 0.53333333333333, 'size', 0.54166666666667, 'highband', 7233.9416273667, 'mdepth', 16.944444444444, 'highx', 1.0, 'mfreq', 0.16666666666667, 'lowband', 681.56675509913, 'fadeTime', 1, 'earlydiff', 0.7, 'midx', 0.88888888888889);
*/
Ndef(\zReverbR).set('lowx', 1.0, 't60', 0.49492320038398, 'damp', 0.0, 'size', 1.5, 'highband', 7233.9416273667, 'in', ProxySubmix('reverbAux'), 'mdepth', 1.1111111111111, 'mfreq', 0.16666666666667, 'highx', 0.49444444444444, 'lowband', 304.82619485944, 'fadeTime', 1, 'earlydiff', 0.71111111111111, 'midx', 0.58333333333333);


Ndef(\zReverbR, {
	var in = ProxySubmix(\zReverbAux).ar; // \in.ar([0, 0]);
	JPverb.ar(
		in,
		\t60.kr(1,           0.05),
		\damp.kr(0,          0.05),
		\size.kr(1,          0.05),
		\earlydiff.kr(0.707, 0.05),
		\mdepth.kr(5,        0.05),
		\mfreq.kr(2,         0.05),
		\lowx.kr(1,          0.05),
		\midx.kr(1,          0.05),
		\highx.kr(1,         0.05),
		\lowband.kr(500,     0.05),
		\highband.kr(2000,   0.05)
	);
});


// Ndef(\zReverbR).map(\in, ProxySubmix(\zReverbAux));


// ha added. HTF ??
q.ndefs.reject{|px| px.key.asString.first == $z}.do{|px|
	ProxySubmix(\zReverbAux).addMix(px, 0.1, true);
};
Ndef(\zReverbR).play;
