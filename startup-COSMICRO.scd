   /*
jetzt in GIT

	MKtl.find;
    Server.killAll;
*/
"\n\n\n---- cosmicroscoperetta live in Brno and later ------  startup for +FaceOSC+  on 3.7 IDE\n\n\n".post;


q = q ? ();
q.numChans = 2;

s.options
// .device_("PreSonus FIREBOX (0567)")
.hardwareBufferSize_(128)			/// OK for Presonus: 64 OK

.numInputBusChannels_(8)
.numOutputBusChannels_(8)
.memSize_( 2.pow(19).asInteger )		// ==~ 10 MB Samplespeicher
.maxNodes_(1024 * 16)			// lots of synth nodes
.numWireBufs_(64*8)				// fat synthdefs need lots of interconnects
;

1000.do{|i| var sy = ("wet"++i).asSymbol; Spec.add(sy, \unipolar) };
1000.do{|i| var sy = ("mix"++i).asSymbol; Spec.add(sy, \unipolar) };

Task({
	var mainpath =
	"/Users/laVulega/scwork/haX/news_from_08/_cosmicro_solo/"
	.pathMatch.first;
	var foldersToLoad = [
		"0_utils",
		"1_configs",
		"3_efx",
		"3_engines",
		"5_mapping",
		"6_guis",
		"7_settings",
	];

	var filesToLoad = foldersToLoad.collect{|fo| (mainpath +/+ fo +/+ "*.scd").pathMatch.sort}
	.flatten.select({|f|f.basename.first.isDecDigit });
	"Going to load: ".postln;
	filesToLoad.collect(_.basename).printAll;
	/*
	[
	"/Applications/FireBox Control.app/",
	"/Applications/FireBox Mixer.app/"
	].do(_.openOS);
	*/
	//	unixCmd( "open /Users/laVulega/Documents/_hannes-TXT/WWW/wegoHannes14/testsJS/canvasFun/aynig_js/aynigjs.html");
	// MKtl.find;
	4.0.wait;
	s.boot;
	s.doWhenBooted({
		s.recChannels = 2;
		s.recSampleFormat = "float";
		" \n\n\n\n\n\n\n\n\n\n\n\n\n juhu! bootedtd !!\n\n! \n\n".postln;
		2.wait;

		filesToLoad.do({|pa, i|
			"\n\n--loading % --\n\n".postf(pa.basename);
			0.5.wait;
			pa.loadPaths;
		});
		"\n\n\n---- LOADED: cosmicroscoperetta live in Brno and later ---- --  startup for + FaceOSC, on 3.7 IDE\n\n\n".post;
	});
}).play(AppClock);

/*
// some metactl for the whole...
Ndef.all[\localhost].do( _.resume );
Ndef.all[\localhost].do{|f|f.play(vol: 0.0).resume };
Ndef.all[\localhost].do(_.end(70))
*/