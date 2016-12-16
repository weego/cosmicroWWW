/*
"\n**********  loading serverConfig:  **********".postln;

Server.default = s = Server.local;
q.server = s;

	// tweak for fast response and rare complaints:
	// default is 0.2 secs, which feels slow;
	// less than 0.03 may introduce many late messages from server.
	// latency nil means do things immediately, but will compromise timing:
	// it quantizes to the hardwareBufferSize border.
s.latency = q.serverLatency;

// // hardware setup first
// s.options
// .device_("Fireface 400 (297)")	// device name
// .numInputBusChannels_(8)		//
// .numOutputBusChannels_(8)		//
// .blockSize_(64)					//  .kr bus rate, default is 64 samples
// .hardwareBufferSize_(128)		// take fastest power of two hardware allows
// ;

"Setting server options: ".postln;
if (s.serverRunning) {
	q.utils.warnWin(
		"Server options were set when s was running already!"
		" Settings will not take effect until server is rebooted:"
		"\ns.reboot;",
		"Server options!"
	);
};

	// other general server setup:
s.options
	.numAudioBusChannels_(1024)		// for proxy usage: lots of ar bus space
	.memSize_(8192 * 64)			// 512 MB memory for buffers, soundfiles!
;

	// recording options:
s
	.recChannels_(min(q.numChans, 4))	// record
	.recSampleFormat_("float"); 		// in float to recover from clipping

\;
*/