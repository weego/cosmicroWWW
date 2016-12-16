// unix file operations

q.utils.slash = Platform.pathSeparator;

q.utils.listCmd = "ls -1AbpP"; // print all files in a row, dirs have a trailing slash
q.utils.traversePathMatch = {|env, path, parentDirs /*, filters*/|
	var paths = "% %".format(env.listCmd, path +/+ parentDirs)
		.unixCmdGetStdOutLines.collect(_.escapeChar($ ));

	// apply filter (to search e.g. for specific endings)
	// filters.notNil.if({
	// 	paths = paths.select{|path|
	// 		filters.inject(false, {|lastRes, filter|
	// 			lastRes || path.contains(filter)
	// 		})
	// 		||
	// 		(path.last == env.slash)
	// 	}
	// });


	paths.notEmpty.if({
		paths.inject([parentDirs.drop(1).drop(-1)], {|last, elem|
			elem = parentDirs +/+ elem;
			last ++
				(elem.last == env.slash).if({
					[env.traversePathMatch(path, elem/*, filters*/)];
				}, {
					[elem.drop(1)]
				})
		})
	}, {
		parentDirs.drop(1).drop(-1); // get rid of trailing slash
	})
};

q.utils.getFilteredPaths = {|env, absolutePath, formats|
	env.traversePathMatch(absolutePath, "")
	.flatNoString.select{|path|
		(path != "") &&
		{path.contains(".DS_Store").not}
		&& {
			formats.inject(false, {|last, format|
				last || path.toLower.endsWith(format)
			})
		}
	};
}