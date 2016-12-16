/*
loads samples hierarchically into a dict in
q.samples.traverseAt(relPath.split.collect(_.asSymbol))

relies on

+ utils
+ file_operations

relPath     -- path relative to resources/samples
forceReload -- if content is already present in q.samples at given location (relPath):
	true --  replaces everything at samples dictionary,
	false -- does not touch content.
*/

q.utils.sampleFormats = [".wav", ".aiff"].collect(_.toLower);


q.utils.loadSamples = {|env, relPath, forceReload = false|
	var absolutePath;
	var samplePaths;
	var baseKeyArray = relPath.notNil.if({
		relPath.split($/).collect(_.asSymbol)
	},{
		[]
	});

	var loadSamples = {
		absolutePath =
			q.topDir +/+ q.samplesDir +/+ (relPath ? "");

		// get all paths to sound files
		samplePaths = q.utils.getFilteredPaths(
			absolutePath,
			env.sampleFormats
		);

		samplePaths.do{|path|
			var sampleKeys, buffer;

			sampleKeys = baseKeyArray ++ path.splitext.first
			.split($/)
			.collect(_.asSymbol);

			buffer = Buffer.read(
				q.server,
				absolutePath +/+ path,
				action: {|b|
					"% loaded".format(sampleKeys).inform;
				}
			);
			q.samples.traversePut(sampleKeys, buffer);

		};
	};

	// test if samples are already loaded
	q.samples.traverseAt(baseKeyArray).isNil.if({
		loadSamples.value;
	}, {
		forceReload.if({
			try{
				// free Buffers of samples originally stored there.
				q.samples.traverseAt(baseKeyArray).traverseDo{|b| b.postln; b.free};
				q.samples.traversePut(baseKeyArray, nil);
			};
			// load samples
			loadSamples.value;
		},{
			"loadSamples: samples (%) already loaded. use forceReload to reload".format(relPath).inform;
		})
	})

};

/*
// test

q.utils.loadSamples("tack", true)
q.samples[\tack].choose.play

q.utils.loadSamples("ice")
*/



