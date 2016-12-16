// add all global filter functions to use - these are then available by name.
q=q?();
q.mfx = q.mfx ? ();
q.views = q.views ? ();
q.numChans = q.numChans ? 2;
(
// add your own fx stuff here!
q.mfx.fxLib = IdentityDictionary
[
	/*		'00_busX' -> { arg in, inchan=2;
	( SoundIn.ar(inchan))
	}
	,
	*/
	'00_in' -> {	 arg in, level=1, llag=0.2, noisefloor=0.01;
		LeakDC.ar( in * level.lag(llag) )
		+ BrownNoise.ar(0.0001).madd(noisefloor ! q.numChans);
	}
	,
	'0OnePolBal' -> { arg in, coeff= 0.8, balnZ = 0.5;
		var split, lo;
		lo = OnePole.ar(in, coeff);
		split = [lo, in-lo] * [ balnZ.reciprocal, balnZ ];
		split.sum;
	}
	,
	'0_par_EQ' -> { arg in, pFreq=90, pRq=0.9, pDb=5;
		MidEQ.ar(in, pFreq, pRq, pDb.dbamp)
	},
	'0_DBComp' -> {	 arg in, xFreq=400, thresh=0.5, loGain=2, hiGain=0.5, compRatio=2;
		DualBandComp.ar(
			in,
			xFreq, loGain,  hiGain, thresh, compRatio
		)
	}
	,
	'0_comp' -> { arg in, thresh=0.5, slopLo=0.9, slopHi=0.5;
		Compander.ar(
			in, in,
			thresh, slopLo, slopHi,
			0.03, 0.05
		)
	}
	,
	'0_gate' -> {|in, threshG = 0.03, attG=0.01, decG=1|
		Compander.ar(
			in, in,
			threshG, 10, 1,
			attG, decG
		)
	}
	,
	'0freqBal' -> { arg in, bFreq=200, pan=0;
		var split, lo;
		pan = LinExp.kr(pan, -1,1, 1/20,20);
		lo = LPF.ar(in, bFreq);
		split = [lo, in-lo] * [ pan.reciprocal, pan ];
		split.sum;
	}
	,
	'0fft_Mess' -> { arg signal, fftGain=0.1;
		signal = signal.asArray.collect({|chan, i|
			var signal = FFT(LocalBuf(2**10), chan);
			signal = PV_MagSquared(signal);
			signal = PV_LocalMax(signal, 31);
			signal = IFFT(signal);
		});
		signal * (fftGain);
	}
	,
	'1shift' -> { arg in;
		FreqShift.ar(
			in,
			MouseY.kr(9000, 0.1, \exponential),
			Blip.kr(
				MouseX.kr.range(-3,3).cubed,
				12
			).madd(2pi)
		)
	}
	,
	'1ring' -> { arg in, widefreq=20, modulation=0;
		SinOsc.ar(
			widefreq.lag(0.3)
			* LFDNoise3.kr(
				modulation.squared
				* 30
				* ~amp.kr ! 2,
				(15 * modulation).midiratio
			),
			0,
			in
		)
	}
	,
	'1fyrFilt' -> { |in, sens=1|
		var timer, changeTrig, rq, ffreq1, ffreq2;
		var pitch = Pitch.kr(in, median: 5);
		pitch = pitch.flop.postln[0].fold(80, 10000).lag(1/20);
		changeTrig = (HPZ1.kr(pitch.cpsmidi.round(1/sens)).abs
			> (5/sens));
		changeTrig = Trig.kr(changeTrig, SinOsc.kr(0.12).range(0.1, 2));
		timer = Timer.kr(changeTrig);
		rq = timer.expexp(0.1, 10, 1, 0.05).clip(0.01, 2).lag(1/130);
		ffreq1 = Fold.kr(pitch * 1.5, 20, 18000);
		ffreq2 = Fold.kr(pitch * timer.sqrt, 20, 18000).lag2(2);

		//	Ringz.ar(K2A.ar(changeTrig), 400, 0.1, 7) +
		RLPF.ar(in, ffreq1, rq.lag(0.5)) -
		RLPF.ar(in, ffreq2, rq + pi % 1.5 + 0.01)
	},
	'1sluu' -> {arg in, slewU = 400, slewD = 9000, miX=0;
		var sl = Slew.ar(in, slewU, slewD);
		XFade2.ar(sl, in-sl, miX)
	}
	,

	'19MURF' -> { | in, rq= 0.2, drive = 2, gain=1, patt =0|
		var bands = [200, 300, 450, 675, 1000, 1500, 2200, 3400];
		var numBands = bands.size;
		var insm = in * Line.kr(0,1,0.01);
		var filts = insm.collect({ |chan,i|
			var pipe = BPF.ar(chan, bands, rq);
			pipe = pipe.madd(drive).distort;
			MoogFF.ar(pipe * Line.kr(0,1,0.01), bands, gain) * 6;
		}).flop;
		var metro16 = A2K.kr( Trig.ar( ~metroIn.ar(1, 0), ControlDur.ir));
		var metro025 =  ~metroIn.ar(1, 4);
		// 			var vary = A2K.kr( Decay.ar( metro025 / 18, 2)).round(0.2);
		var vary = A2K.kr( TIRand.ar(0, 3, metro025)).madd(pi);
		var steps = Stepper.kr( PulseDivider.kr(metro16, 2) );
		var restep = (
			Hasher.kr(steps + vary + patt.madd(0.1) ) % 1 * numBands
		).trunc;
		var steppd = Select.ar(restep, filts);
		steppd;
	},

	'0turboDLY' -> { arg in, mainDT = 3, glide=7, feedbT = 0.03, dry=1;
		var out;
		var n = (q.numChans*2).max(10); // so many taps
		var inMono = in.asArray.sum;
		var mixIn = Limiter.ar((LocalIn.ar(1) * feedbT) + inMono);
		var modz = { SinOsc.kr(
			LFNoise1.kr(1/30).exprange(0.2, 3),
			Rand(0,2pi),
			0.75,
			0.25
		)
		} ! n;
		var trigz = modz + 0.05 + Impulse.kr(0) > 0;
		var dts = (mainDT ).lag2(glide) * (TRand.kr(0.1, 1, trigz ) + 0.1);
		// no Filtering, for OEROL..
		//			var ffreqs = TExpRand.ar(50, 9000, trigz).trunc + 70;
		//			var dly = DelayL.ar(mixIn * modz.clip(0, 1), 6, dts);    // nice lil clicky..
		var dly = DelayL.ar(mixIn, 6, dts, modz.clip(0, 1));
		var fltSnd = dly; //BPF.ar(dly, ffreqs, 1.8);
		var summ = LeakDC.ar(fltSnd.sum);
		LocalOut.ar(summ);
		out = SplayAz.ar(q.numChans, fltSnd);
		OnePole.ar(out, 0.8)
		+ inMono.asArray.wrapExtend(q.numChans).madd(dry);
	}
	,

	'5HPF'	-> { arg in, freqH = 400, modH =0.5, rqH =0.75;
		var fr, seq, tempo;
		tempo = ~bpm.kr / 60;   // quarter tempo..
		fr = SinOsc.kr((modH * tempo), [0, 0.4]).exprange(0.5, 3).madd(freqH).fold(20, 19000);
		RHPF.ar(in, fr, rqH)
	}
	,

	'5LPF'	-> { arg in, freqL = 4000, modL = 0.6, rqL = 0.5; var fr;

		fr = (freqL
			+ LFDNoise3.kr(
				Amplitude.kr(in).sqrt
				* modL.cubed
				* 20
				! q.numChans
			).exprange(1/3, 3)
			.madd(freqL * modL)
		).cpsmidi.round(2).fold(15, 133).midicps;

		RLPF.ar(in, fr, rqL )
	},

	'3funFilt' -> { arg in, gain=1, att=0.01, dcy=0.75, ffFrq= 5000, octSpan= -5, rq=0.7;
		var amp;
		in = in * gain;
		amp = Amplitude.ar(in, att, dcy); // was: AmplitudeMod
		RHPF.ar(in,
			(ffFrq * (amp * octSpan * 12).midiratio).fold(20, 19000),
			rq
		)
	}
	,
	'3ParF' -> { arg in, spreadX=2, gainX=1, pitpit=0;
		var pix, l, r, freqs, amp, verso;
		in = in * gainX;
		//		amp = ~amp.kr(1);
		//		pix = ~pitch.kr(2);
		amp = Amplitude.kr(in, 0.01, 0.2);
		pix = Pitch.kr(in).lag(0.01, 0.5);
		verso = pitpit.clip(0,1).madd(2, -1) * (pix[1] - 0.5) * [1, -1] + 0.5;
		freqs = (
			(pix[0] * verso[0])
			+ (amp.linexp(0, 1, 5000, 80).madd(verso[1]))
			* [spreadX.reciprocal, spreadX]
		).fold(20, 19000);


		l = LPF.ar(in[0], freqs).madd([1, -1]).sum;
		r = LPF.ar(in[1], freqs).madd([1, -1]).sum;
		[l,r]
	}
	,
	'3thrasher' -> { arg in, bit = 7, downsample= 6000, downsmod=0.75;
		var zin, zout;
		zin = in;
		zout = zin.round(2.pow(bit).reciprocal);
		zout = downsample<22050 *
		Latch.ar(
			zout,
			Impulse.ar(
				downsample
				* LFDNoise1.kr(
					downsmod.cubed * 75 ! 2,
					0.25, 0.75
				).abs
			)
		)
		+ (downsample >= 22050 * zout)
	},
	'1ixiDist' -> { |in, pregain=2, dFreq= 4000, postgain=1, loSlop=0.6 |
		var sig, sigtocomp, fx, y, z;
		sig = in;
		sigtocomp = LPF.ar((sig * pregain).distort, dFreq, postgain).distort;
		fx = Compander.ar(sigtocomp, sigtocomp, 1, loSlop, 1 );
		LeakDC.ar(fx, mul: 0.5 );
	},
	'3AdCVerb' -> {| in, predelay=0.048, revTime=3, combScale=1, apScale=1, mod=0.05 |
		var sig, y, z;
		AdCVerb.ar( in, revTime, LFNoise1.kr(0.2!2,0.1*mod, 0.11),  2, predelay,
			8, 4, 0.6, combScale = 1, apScale = 1);

	},
	'5Hreveb' -> { arg in, revTime=0.2, revDecay=4, modulatie=0.5;
		var zin, zout, env, lag = 0.5;

		revTime = revTime.lag(lag)*0.5;
		revDecay = revDecay.lag(lag);
		modulatie = modulatie.lag(lag).squared * 3;
		zin = HPF.ar(in, 100);
		zout = zin;
		12.do({
			zout = AllpassL.ar(
				Rotate2.ar(zout[0], zout[1], {Rand(-0.3, 0.9)}).neg,
				0.3,
				{Rand(0.001,0.3)}.dup(q.numChans)
				* LFDNoise1.kr(modulatie,revTime,revTime),
				revDecay
			)
		});
		LeakDC.ar( zout, 0.9 ) + in;
	},

	'6noone' -> { arg in, revDecay=3, revTime=0.5, modulaNon=0.01, ampC=0.5, op=0.7, lpfreq= 2000;
		var zin, zout, env, lag = 0.5, seq, fr, mousex, n=4;

		revTime = revTime * 0.5;
		revDecay = revDecay.lag(lag);
		op=op;
		mousex = MouseStrum.kr((1 .. (n)) / (n+1), \x, 0).sum;
		seq = Drand( [Dseq([0, -7, 0, 12, 0, -12, -4, -7, -24, 0, 2], 1), Drand({Rand(-0.0, -12)}, 3)], inf);
		fr = Demand.ar( K2A.ar((mousex.sum)), 0,
			(seq.midiratio)
		);

		modulaNon = modulaNon.squared + Line.kr(1, 0, 0.01);
		zin = in.dup(q.numChans) * ampC * (1 - LFNoise1.kr(0.1 ! q.numChans).squared);
		zout = zin;
		3.do({|i|
			zout = CombL.ar(
				OnePole.ar(HPF.ar(zout.rotate(-1), ExpRand(80, 120.0)), op),
				0.2,
				({Rand(0.01,0.2)}.dup(q.numChans)
					* LFDNoise1.kr(modulaNon, revTime, revTime+0.001)
					*  [fr,fr.madd(0.8) ,fr.madd(1.33)].rotate(i)) ,
				revDecay
			)
		});
		zout = LPF.ar(zout, lpfreq);
		Limiter.ar(zout); //.clump(q.numChans).sum;
	},

	'6roto' -> { arg in, speed = 0.02;
		var sins, n = q.numChans;
		sins = LFSaw.ar(speed, 0, 1, (1..n)-1*2/n * 0.67 );
		(({ arg i; PanAz.ar(n, in[i], sins[i], 1, 1.9) } ! n)).sum;
	},

	'7Delay'	-> { arg in, delayTime1 = 1, delayTime2 = 0.76, mod=0.66, feedback=3;
		var dtKr, comb, tempo;
		tempo = 1;        // 15 / ~bpm.kr;   // quarter tempo..
		dtKr = [delayTime1, delayTime2 ].lag(1.0);
		comb = CombL.ar(
			HPF.ar(in, 100),
			6,
			dtKr * ( 1 - LFDNoise3.kr(mod.sqrt!2 * 4, 0.8 * mod).cubed ),
			dtKr * feedback,
			0.8
		);
		Rotate2.ar(comb[0], comb[1], SinOsc.kr(0.025)) + in;
	},

	'8ixiVerb' -> {| in, predelay=0.048, combdecay=5, apDecay=1, ixivAmp=0.1 |
		var sig, y, z;
		sig = in.madd(ixivAmp).rotate(-1);
		z = DelayN.ar(sig, 1, predelay);
		y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.05, Rand(0.03, 0.05), combdecay) }).scramble);
		6.do({ y = AllpassN.ar(y.rotate(1), 0.050, Rand(0.03, 0.05), apDecay) });
		y+in;
	},

	'8waber'-> { | in, amp=1, lagW=0.2, widthW=0.0, speedW=0.01|
		var maxdt = 0.4;
		widthW = widthW * maxdt;
		DelayL.ar(
			in * amp.lag(lagW),
			maxdt,
			//			LFDNoise3.kr(speedW ! q.numChans).abs.pow(widthW.cubed.lag3(lagW)).madd(maxdt).poll
			LFDNoise3.kr(speedW ! q.numChans).abs.madd(widthW)
		);
	},

	'8wheel'-> { | in, ampWh = 1, rotWh = 0.051, dimension=16, ampExp = 0.75, lagWheel=12.5|

		var wheelXY, xys, dists, dt, dAmp , rad=1;
		var poly= q.numChans, listeners= q.numChans;

		// wheelin
		var radiuScale=0.9;
		var wheelRotAngle;
		dimension = dimension.lag3(lagWheel);
		wheelRotAngle = LFSaw.kr(rotWh.neg.lag3(lagWheel), 0.5, pi);
		wheelXY = (dimension * radiuScale) * [wheelRotAngle.cos, wheelRotAngle.sin ];
		//[dimension.lag3(lagWheel)];

		xys = (((0,1..poly-1)*2*pi/poly).collect({ arg ang; [ang.sin, ang.cos]}) * rad).round(0.01).scramble;

		dists = xys.collect({ arg pair;
			(pair/xys.flat.sort.last * dimension
				- wheelXY).squared.sum + 1
		});

		dt = dists.sqrt / 330;	// ha amp compensated;
		dAmp = (dists ** (ampExp.neg*(
			//			~z_wheelDrive.kr(1, 2)**0.45
			dimension**0.45
		)).reciprocal.lag3(1));
		in = Limiter.ar(in.sum  * dAmp * ampWh.lag(0.1) , 0.97, 0.1);
		DelayC.ar(in, 0.5, dt);
	},


	'9scrambl'-> { | in|
		in.scramble;
	},
	'9monofy' -> { arg in;
		in.mean;
	},
	'9stereofy' -> { arg in;
		Splay.ar(in);
	},
	'9endFilt' -> { arg in, higCut=15000, lowCut=40; var l, h;
		l = LPF.ar( in, lowCut);
		h = LPF.ar( in, higCut);
		h-l;
	},

	'ampLimFin' -> { |in, limDrive=1, ampLimit=0.9, postAmp=1 |
		var st = Limiter.ar(in * limDrive, ampLimit) * postAmp;
		LeakDC.ar(st)
	}

];
);

// add them to da Chain
q.mfx.fxLib.keysValuesDo({ |key,val| // key.postcln;
	ProxyChain.add(key.asSymbol, \filterIn -> val)
});

// and specs for them fof gui control.
Spec.add( \level, [0, 20, 5]);
Spec.add( \llag, [0, 600, 8]);

Spec.add( \coeff, [0, 0.99999, -7.5, 0.00001]);
Spec.add( \balnZ, [1/12, 12, \exp, 0, 0]);
Spec.add( \inGain, [0, 25, 6]);
Spec.add( \thresh, [0.000001, 1, \exp]);
Spec.add( \mmGain, [0, 10, \lin]);
Spec.add( \ampFIN, [0, 10, \amp, 0, 1]);
Spec.add( \gain, [1/100, 5, \amp, 0, 1]);

Spec.add(\noisefloor, \amp);
Spec.add(\limDrive, \ampx4);
Spec.add(\ampLimit, \amp);
Spec.add(\postAmp, \ampx4);

Spec.add( \inAmp, \gain.asSpec);
Spec.add( \thresh, \amp.asSpec);
Spec.add( \threshG, \amp.asSpec);
Spec.add( \slopLo, [1/10, 10, \exp, 0.0]);
Spec.add( \slopHi, [1/10, 10, \exp, 0.0]);
Spec.add( \loCut, \freq.asSpec);
Spec.add( \lowCut, \freq.asSpec);
Spec.add( \higCut, \freq.asSpec);

Spec.add( \gainL, [0.1, 10, \exp]);
Spec.add( \gainR, [0.1, 10, \exp]);
Spec.add( \hifreq, [600, 19000, \exp]);
Spec.add( \lowfreq, [10, 500, \exp]);
Spec.add( \freqSpan, [10, 7000, \exp]);
Spec.add( \octSpan, [-8, 8, \lin]);
Spec.add( \ffFrq, [10, 19000, \exp]);

Spec.add( \wetRev, [0, 1, \lin]);
Spec.add( \feedback, [1, 100, \exp, 0.1]);
Spec.add( \delayTime1, [0.005, 6, \exp]);
Spec.add( \delayTime2, [0.005, 6, \exp]);
Spec.add( \mod, [0, 1, \lin]);

Spec.add( \revTime, [0.05, 1, \exp]);
Spec.add( \revDecay, [0.001, 10, \exp]);
Spec.add( \modulation, [0, 1, \lin]);
Spec.add( \modulatie, [0, 1, \lin]);
Spec.add( \modulaNon, [0, 1, \lin]);

Spec.add( \bit, [16, 2, \lin, 1]);
Spec.add( \downsmod, [0, 1, \lin]);
Spec.add( \downsample, [s.sampleRate/2, 100, \lin]);

Spec.add( \dAmp, \amp.asSpec);
Spec.add( \dFreq, \freq.asSpec);
Spec.add( \pregain, [0.01, 20, \linear]);
Spec.add( \postgain, [0.01, 20, \linear]);

Spec.add( \combScale, \amp.asSpec);
Spec.add( \apScale, \amp.asSpec);
Spec.add( \predelay, [0.0001, 1, \linear]);

Spec.add( \revDcy, [0.01, 12, \linear, 0, 1]);
Spec.add( \apDecay, [0.01, 12, \linear, 0, 1]);
Spec.add( \combdecay, [0.1, 15, \linear, 0, 15]);
Spec.add( \ixivAmp, \amp.asSpec);
Spec.add( \bFreq, \freq.asSpec);

Spec.add( \pFreq, \freq.asSpec);
Spec.add( \pDb, [-60, 32, \linear, 0, 1]);
Spec.add( \pRq, \rq.asSpec);

Spec.add( \loSlop, [1, 0.0, \linear, 0, 1]);
Spec.add( \rqL, \rq.asSpec);
Spec.add( \rqH, \rq.asSpec);
Spec.add( \modL, \unipolar.asSpec);
Spec.add( \modH, [0, 32, 5, 1/1000]);
Spec.add( \freqL, \freq.asSpec);
Spec.add( \freqH, \freq.asSpec);

Spec.add( \ampC, \gain.asSpec);
Spec.add( \op, [0.95, 0.5, 1].asSpec);
Spec.add( \lpfreq, \freq.asSpec);

Spec.add( \lagW, [0.01, 30, \exp, 0.0]);
Spec.add( \speedW, [0.0001, 4, \exp, 0.0]);
Spec.add( \widthW, [0.0, 0.5, \lin, 0.0]);

Spec.add( \spreadX, [1.01, 5.0, \exp, 0.0]);
Spec.add(\gainX, \gain.asSpec);

Spec.add( \rotWh, [-10, 100, \lin, 0.0]);
Spec.add( \ampWh, [0.01, 100, \exp, 0.0]);
Spec.add( \ampExp, [0.1, 10, \exp, 0.0]);
Spec.add( \lagWheel, [0.01, 120, \exp, 0.0]);
Spec.add( \dimension, [0.01, 120, \exp, 0.0]);
Spec.add( \slewU, [0, 24000, 4]);
Spec.add( \slewD, [0, 24000, 4]);
Spec.add( \miX, \pan.asSpec);
Spec.add( \fftGain, \amp.asSpec);

Spec.specs.put(\xFreq, \freq.asSpec);
Spec.specs.put(\loGain, ControlSpec(0, 10, \amp, 0, 1));
Spec.specs.put(\hiGain, ControlSpec(0, 10, \amp, 0, 1));
Spec.specs.put(\compRatio, [1, 10, \exp, 0.1, 3].asSpec);


/////make MAster FX
(
q.mfx.fx = MasterFX.new(server: s,
	numChannels: q.numChans,
	slotNames: q.mfx.fxLib.keys.asArray.sort.removeAll(['0_par_EQ', '1sluu', '0_DBComp']), // not load all for now
	busIndex: 0);

// pre-set ons:

// q.mfx.fx.pxChain.add('00_in', 1);
q.mfx.fx.pxChain.add('0OnePolBal', 1);
q.mfx.fx.pxChain.add('1fyrFilt', 0.05);
q.mfx.fx.pxChain.add('0turboDLY', 0.2);
q.mfx.fx.pxChain.add('5Hreveb', 0.15);
q.mfx.fx.pxChain.add('ampLimFin', 1);


q.views.masterFX = q.mfx.fx.gui('ma master 3.7.', 40);
);

{q.views.masterFX.buttons.first.valueAction_(1) }.defer(0.2); // this instead to colorize!

// tweak
q.mfx.fx.pxChain.proxy.fadeTime = 3;
// add Panic Button?
/*
q.mfx.fx .pxChain . dump
q.mfx.fx .pxChain . proxy.dump

q.mfx.fx .clear

*/