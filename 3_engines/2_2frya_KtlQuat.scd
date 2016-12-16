Ndef(\n2_frya).ar(q.numChans);

// Halo stuff!
Ndef(\n2_frya).addHalo(\scene, 1);
Ndef(\n2_frya).addHalo(\myRandSeed, 0);


(
Ndef(\n2_frya).addSpec(\intv, [0, 36, \lin]);
Ndef(\n2_frya).addSpec(\timescale, [0.001, 10, \exp]);
Ndef(\n2_frya).addSpec(\baseFreq, [0.1, 10000, \exp]);
Ndef(\n2_frya).addSpec(\lOfreq, [0.0001, 50, \exp]);
Ndef(\n2_frya).addSpec(\driftA, [0.0001, 50, \exp]);
Ndef(\n2_frya).addSpec(\driftT, [0.0001, 50, \exp]);
Ndef(\n2_frya).addSpec(\timeScale, [10/50, 0.001/50, \exp]);
Ndef(\n2_frya).addSpec(\loopNode, [0,11,  \lin, 1]);
Ndef(\n2_frya).addSpec(\ring, [0.01, 1, 5]);
Ndef(\n2_frya).addSpec(\curve, [-20, 100, \cos]);
Ndef(\n2_frya).addSpec(\fLag, [1, 5000, \exp]);
Ndef(\n2_frya).addSpec(\stereo, [1,0,8]);
Ndef(\n2_frya).addSpec(\oPole, [0.99999, -0.5, 5]);
Ndef(\n2_frya).addSpec(\silent, [0,1]);
Ndef(\n2_frya).addSpec(\dry, [0,1]);
Ndef(\n2_frya).addSpec(\wEt, [0,1]);
Ndef(\n2_frya).addSpec(\ampRing, [0.01,1, \exp]);
Ndef(\n2_frya).addSpec(\wrap, [0,2]);
Ndef(\n2_frya).addSpec( \minfreq, [20, 19000, \exp, 1]);
Ndef(\n2_frya).addSpec( \maxfreq, [20, 19000, \exp, 1]);
);

(
	Ndef(\n2_frya).source = { |
		baseFreq=100,
		loopNode=0,
		curve=0,
		silent=0.5,
		driftA=0.1,
		driftT=0.1,
		wrap=0,
		wEt=0.5,
		ring=0.03,
		ampRing=0.1,
		fLag=2000,
		oPole=0.9,
		stereo=1,
		minfreq=100,
		maxfreq=5000
		 |


		var ffreq, ffreq2;
		var n = 22, snd, ffreQ1, ffreQ2;
		var lvlcurvs = (LFDNoise1.kr(driftA * ({Rand(0.6, 1.1)}!n) ).abs - silent).max(0)
			/ ( 1.002 - silent );
		var timecurvs = LFDNoise1.kr(driftT * ({Rand(0.6, 1.1)}!(n-1)), 0.5, 0.5).normalizeSum;
		var env = (EnvGen.ar(
			Env(
				lvlcurvs,
				timecurvs, curve,
				releaseNode: n-2, loopNode: loopNode
			),
			timeScale: baseFreq.reciprocal
		) );


		wEt = wEt.lag(1.5); wrap=wrap.lag(1.5); stereo=stereo.lag(0.5); baseFreq=baseFreq.lag(0.2);
		env = ( env + wrap).fold(0, 1);
		ffreq = DelayL.ar(env, 0.1, 0.1*[1, stereo.lag(0.01)])
				.linexp(0, 1, minfreq, maxfreq);
		ffreq2 = DelayL.ar((env.neg+0.5).abs, 0.23, 0.23 * [stereo, 1])
				.linexp(0, 0.5, minfreq+30, maxfreq*0.97);
		fLag = fLag.reciprocal;
		ffreQ1 = min(ffreq, ffreq2); // take lower freq louder !
		ffreQ2 = max(ffreq, ffreq2);
		ffreQ1 = Ramp.ar(ffreQ1, fLag);
		ffreQ2 = Ramp.ar(ffreQ2, fLag);
		ffreQ1 = OnePole.ar(ffreQ1, oPole);
		ffreQ2 = OnePole.ar(ffreQ2, oPole*0.95);

		env = env - 0.5;
		snd = Formlet.ar(env, [ffreQ1, ffreQ2], ring/10, ring, 0.025 * [1, 0.3]);
		LeakDC.ar(
			(Limiter.ar(snd.sum * ampRing) * (wEt.sqrt))
			+ ((1-wEt).sqrt * env)
		);
	};
);

fork {
	0.5.wait;
	Ndef(\n2_frya).supplementNodeMap;
};

//////////////////////////////////////////////////////////////////////
/////////////// bad habit to blow up /////////////////////////////////

Ndef(\n2_frya).addHalo(\reloadFunc, {
	fork{
		 var cacheFunc;
		cacheFunc = Ndef(\n2_frya).source;
			0.02.wait;
		Ndef(\n2_frya).clear;
			0.1.wait;
		Ndef(\n2_frya).source = cacheFunc;
			0.05.wait;
		Ndef(\n2_frya).supplementNodeMap;
			0.1.wait;
		Ndef(\n2_frya).play(vol: 0);

	}
});
