%token
%[Tag, Value, FileName, SL, SC, EL, EC]

%error
%[Text, FileName, SL, SC, EL, EC]

valueToAtom([], '').
valueToAtom([Hd|Tl], ResAtom) :-
	valueToAtom(Tl, Atom),
	atomic_concat(Hd, Atom, ResAtom).

astWrite(Tree, Tabs) :-
	is_dict(Tree) ->
	(
		write('\n'),
		Tab is Tabs + 1,
		foreach(get_dict(Key, Tree, Val), (foreach(between(1, Tab, _), write('\t')), write(Key), write(': '), astWrite(Val, Tab)))
	);
	(
		write(Tree),
		write('\n')
	).

parse(TreeOut) -->
	parseImpl(ast{}, TreeOut).

parseImpl(TreeIn, TreeIn, [], []).
parseImpl(TreeIn, TreeOut) -->
	(
		parseImport(TreeIn, ResTree);
		parseLibDef(TreeIn, ResTree);
		parseMain(TreeIn, ResTree)
	),
	parseImpl(ResTree, TreeOut).

parseImport(TreeIn, ResTree) -->
	[[import, _, FileName, SL, SC|_]],
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{libName:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(imports/'END', Item)
	}.

parseMain(TreeIn, ResTree) -->
	[[fn, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(mains/'END', Item),
		Path = mains/'LAST'
	},
	[[colon, _, FileName|_]],
	parseTypeSpec(TreeOut, TreeOut1, Path/typeSpec),
	[[lbrace, _, FileName|_]],
	parseStmts(TreeOut1, ResTree, Path/stmts),
	[[rbrace, _, FileName, _, _, EL, EC]].

parseLibDef(TreeIn, ResTree) -->
	[[lib, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{libName:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(libDefs/'END', Item)
	},
	[[colon, _, FileName|_]],
	[[lparen, _, FileName|_]],
	parseExports(TreeOut, TreeOut1),
	[[rparen, _, FileName|_]],
	[[lbrace, _, FileName|_]],
	parseLibItems(TreeOut1, ResTree),
	[[rbrace, _, FileName, _, _, EL, EC]].
	
parseExports(TreeIn, ResTree) -->
	parseExport(TreeIn, TreeOut),
	(
		(
			parseExports(TreeOut, ResTree),
			!
		);
		{ResTree = TreeOut}
	).

parseExport(TreeIn, ResTree) -->
	(
		[[type, _, FileName, SL, SC|_]] -> {ItemType = type};
		[[var, _, FileName, SL, SC|_]] -> {ItemType = var};
		[[fn, _, FileName, SL, SC|_]] -> {ItemType = fn}
	),
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, itemType:ItemType, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(libDefs/'LAST'/exports/'END', Item)
	}.

parseLibItems(TreeIn, ResTree) -->
	parseLibItem(TreeIn, TreeOut),
	(
		(
			parseLibItems(TreeOut, ResTree),
			!
		);
		{ResTree = TreeOut}
	).

parseLibItem(TreeIn, ResTree) -->
	parseTypeDef(TreeIn, ResTree);
	parseFnDef(TreeIn, ResTree);
	parseVarDef(TreeIn, ResTree).

% with placehldrs
parseTypeDef(TreeIn, ResTree) -->
	[[type, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(libDefs/'LAST'/typeDefs/'END', Item),
		Path = libDefs/'LAST'/typeDefs/'LAST'
	},
	parsePlacehldrAnnot(TreeOut, TreeOut1, Path),
	[[colon, _, FileName|_]],
	parseTypeSpec(TreeOut1, TreeOut2, Path/typeSpec),
	{
		ResTree = TreeOut2
			.add(Path/endLine, TreeOut2.find(Path/typeSpec/endLine))
			.add(Path/endCol, TreeOut2.find(Path/typeSpec/endCol))
	}.

% without placehldrs
parseTypeDef(TreeIn, ResTree) -->
	[[type, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(libDefs/'LAST'/typeDefs/'END', Item),
		Path = libDefs/'LAST'/typeDefs/'LAST'
	},
	[[colon, _, FileName|_]],
	parseTypeSpec(TreeOut, TreeOut2, Path/typeSpec),
	{
		ResTree = TreeOut2
			.add(Path/endLine, TreeOut2.find(Path/typeSpec/endLine))
			.add(Path/endCol, TreeOut2.find(Path/typeSpec/endCol))
	}.

% with params
parseFnDef(TreeIn, ResTree) -->
	[[fn, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(libDefs/'LAST'/fnDefs/'END', Item),
		Path = libDefs/'LAST'/fnDefs/'LAST'
	},
	parseParamAnnot(TreeOut, TreeOut1, Path),
	[[colon, _, FileName|_]],
	parseTypeSpec(TreeOut1, TreeOut2, Path/typeSpec),
	[[lbrace, _, FileName|_]],
	parseStmts(TreeOut2, ResTree, Path/stmts),
	[[rbrace, _, FileName, _, _, EL, EC]].

% without params
parseFnDef(TreeIn, ResTree) -->
	[[fn, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(libDefs/'LAST'/fnDefs/'END', Item),
		Path = libDefs/'LAST'/fnDefs/'LAST'
	},
	[[colon, _, FileName|_]],
	parseTypeSpec(TreeOut, TreeOut1, Path/typeSpec),
	[[lbrace, _, FileName|_]],
	parseStmts(TreeOut1, ResTree, Path/stmts),
	[[rbrace, _, FileName, _, _, EL, EC]].

parseVarDef(TreeIn, ResTree) -->
	[[var, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(libDefs/'LAST'/varDefs/'END', Item),
		Path = libDefs/'LAST'/varDefs/'LAST'
	},
	[[colon, _, FileName|_]],
	parseTypeSpec(TreeOut, TreeOut1, Path/typeSpec),
	[[left_move, _, FileName|_]],
	parseExpr(TreeOut1, TreeOut2, Path/value),
	{
		ResTree = TreeOut2
			.add(Path/endLine, TreeOut2.find(Path/value/endLine))
			.add(Path/endCol, TreeOut2.find(Path/value/endCol))
	}.

parsePlacehldrAnnot(TreeIn, ResTree, Path) -->
	[[langle_bracket, _, FileName|_]],
	parsePlacehldrs(TreeIn, ResTree, Path),
	[[rangle_bracket, _, FileName|_]].

parsePlacehldrs(TreeIn, ResTree, Path) -->
	parsePlacehldr(TreeIn, TreeOut, Path),
	(
		(
			parsePlacehldrs(TreeOut, ResTree, Path),
			!
		);
		{ResTree = TreeOut}
	).

parsePlacehldr(TreeIn, ResTree, Path) -->
	[[id, Value, FileName, SL, SC, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path/placehldrs/'END', Item)
	}.

parseParamAnnot(TreeIn, ResTree, Path) -->
	[[langle_bracket, _, FileName|_]],
	parseParams(TreeIn, ResTree, Path),
	[[rangle_bracket, _, FileName|_]].

parseParams(TreeIn, ResTree, Path) --> 
	(
		(
			parseParam(TreeIn, TreeOut, Path),
			[[comma|_]],
			!
		);
		parseParam(TreeIn, TreeOut, Path)
	),
	(
		(
			parseParams(TreeOut, ResTree, Path),
			!
		);
		{ResTree = TreeOut}
	).

%param for type spec
parseParam(TreeIn, ResTree, Path) -->
	[[apostrophe, _, FileName, SL, SC|_]],
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path/params/'END', Item)
	},
	!.

%param for param
parseParam(TreeIn, ResTree, Path) -->
	[[apostrophe, _, FileName, SL, SC|_]],
	[[apostrophe, _, FileName|_]],
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path/paramsForParam/'END', Item)
	},
	!.
	
parseTypeSpec(TreeIn, ResTree, Path) -->
	(
		(
			[[grave_accent, _, FileName, SL, SC|_]],
			(
				parseBaseQual(TreeIn, TreeOut, Path);
				parseArrayQual(TreeIn, TreeOut, Path);
				parseVlaQual(TreeIn, TreeOut, Path);
				parsePtrQual(TreeIn, TreeOut, Path);
				parseAdrQual(TreeIn, TreeOut, Path);
				parseStructQual(TreeIn, TreeOut, Path);
				parseUnionQual(TreeIn, TreeOut, Path);
				parseTypeDefQual(TreeIn, TreeOut, Path);
				parsePlacehldrQual(TreeIn, TreeOut, Path);
				parseParamQual(TreeIn, TreeOut, Path);
				parseParamForParamQual(TreeIn, TreeOut, Path)
			),
			{
				TreeOut1 = TreeOut.add(Path/mut, false),
				TreeOut2 = TreeOut1.add(Path/fileName, FileName),
				TreeOut3 = TreeOut2.add(Path/startLine, SL),
				ResTree = TreeOut3.add(Path/startCol, SC)
			}
		);
		(
			parseFuncQual(TreeIn, ResTree, Path);
			parseImmutFuncQual(TreeIn, ResTree, Path);

			parseBaseQual(TreeIn, ResTree, Path);
			parseArrayQual(TreeIn, ResTree, Path);
			parseVlaQual(TreeIn, ResTree, Path);
			parsePtrQual(TreeIn, ResTree, Path);
			parseAdrQual(TreeIn, ResTree, Path);
			parseStructQual(TreeIn, ResTree, Path);
			parseUnionQual(TreeIn, ResTree, Path);
			parseTypeDefQual(TreeIn, ResTree, Path);
			parsePlacehldrQual(TreeIn, ResTree, Path);
			parseParamQual(TreeIn, ResTree, Path);
			parseParamForParamQual(TreeIn, ResTree, Path)
		)
	),
	!.

parseArrayQual(TreeIn, ResTree, Path) -->
	[[lbracket, _, FileName, SL, SC|_]],
	[[uint_const, Value, FileName|_]],
	[[rbracket, _, FileName|_]],
	{
		Item = ast{typeQual:array, mut:true, length:Value, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseTypeSpec(TreeOut, TreeOut1, Path/elemType),
	{
		TreeOut2 = TreeOut1.add(Path/endLine, TreeOut1.find(Path/elemType/endLine)),
		ResTree = TreeOut2.add(Path/endCol, TreeOut1.find(Path/elemType/endCol))
	}.

parseVlaQual(TreeIn, ResTree, Path) -->
	[[lbracket, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	[[rbracket, _, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{typeQual:vla, mut:true, lenParam:Name, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseTypeSpec(TreeOut, TreeOut1, Path/elemType),
	{
		TreeOut2 = TreeOut1.add(Path/endLine, TreeOut1.find(Path/elemType/endLine)),
		ResTree = TreeOut2.add(Path/endCol, TreeOut1.find(Path/elemType/endCol))
	}.

parseBaseQual(TreeIn, ResTree, Path) -->
	[[Type, _, FileName, SL, SC, EL, EC]],
	{
		(
			Type = char;
			Type = i8;
			Type = i16;
			Type = i32;
			Type = i64;
			Type = u8;
			Type = u16;
			Type = u32;
			Type = u64;
			Type = f32;
			Type = f64;
			Type = bool;
			Type = size;
			Type = unit
		), 
		Item = ast{typeQual:Type, mut: true, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parsePtrQual(TreeIn, ResTree, Path) -->
	[[dollar, _, FileName, SL, SC|_]],
	{
		Item = ast{typeQual:ptr, mut: true, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseTypeSpec(TreeOut, TreeOut1, Path/elemType),
	{
		TreeOut2 = TreeOut1.add(Path/endLine, TreeOut1.find(Path/elemType/endLine)),
		ResTree = TreeOut2.add(Path/endCol, TreeOut1.find(Path/elemType/endCol))
	}.

parseAdrQual(TreeIn, ResTree, Path) -->
	[[ampersand, _, FileName, SL, SC|_]],
	{
		Item = ast{typeQual:adr, mut: true, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseTypeSpec(TreeOut, TreeOut1, Path/elemType),
	{
		TreeOut2 = TreeOut1.add(Path/endLine, TreeOut1.find(Path/elemType/endLine)),
		ResTree = TreeOut2.add(Path/endCol, TreeOut1.find(Path/elemType/endCol))
	}.

parseStructQual(TreeIn, ResTree, Path) -->
	[[lparen, _, FileName, SL, SC|_]],
	{
		Item = ast{typeQual:struct, mut: true, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseFields(TreeOut, ResTree, Path/fields),
	[[rparen, _, FileName, _, _, EL, EC]].

parseUnionQual(TreeIn, ResTree, Path) -->
	[[lbrace, _, FileName, SL, SC|_]],
	{
		Item = ast{typeQual:union, mut: true, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseFields(TreeOut, ResTree, Path/fields),
	[[rbrace, _, FileName, _, _, EL, EC]].

parseFields(TreeIn, ResTree, Path) --> 
	(
		(
			parseField(TreeIn, TreeOut, Path),
			[[comma|_]],
			!
		);
		parseField(TreeIn, TreeOut, Path)
	),
	(
		(
			parseFields(TreeOut, ResTree, Path),
			!
		);
		{ResTree = TreeOut}
	).

parseField(TreeIn, ResTree, Path) --> 
	[[id, Value, FileName, SL, SC|_]],
	[[colon, _, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseTypeSpec(TreeOut, TreeOut1, Path/'LAST'/elemType),
	{
		TreeOut2 = TreeOut1.add(Path/'LAST'/endLine, TreeOut1.find(Path/'LAST'/elemType/endLine)),
		ResTree = TreeOut2.add(Path/'LAST'/endCol, TreeOut1.find(Path/'LAST'/elemType/endCol))
	},
	!.

parsePlacehldrQual(TreeIn, ResTree, Path) -->
	[[id, Value, FileName, SL, SC, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{typeQual:placehldr, mut:true, name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseParamQual(TreeIn, ResTree, Path) -->
	[[apostrophe, _, FileName, SL, SC|_]],
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{typeQual:param, mut:true, name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseParamForParamQual(TreeIn, ResTree, Path) -->
	[[apostrophe, _, FileName, SL, SC|_]],
	[[apostrophe, _, FileName|_]],
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{typeQual:paramForParam, mut:true, name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

% with annot
parseTypeDefQual(TreeIn, ResTree, Path) -->
	[[id, Value, FileName, SL, SC|_]],
	[[dash, _, FileName|_]],
	[[id, Value1, FileName|_]],
	{
		valueToAtom(Value, Name),
		valueToAtom(Value1, Name1),
		Item = ast{typeQual:typeDef, mut:true, libName:Name, typeName:Name1, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path, Item)
	},
	[[langle_bracket, _, FileName|_]],
	parseTypeSpecs(TreeOut, ResTree, Path/typeAnnot),
	[[rangle_bracket, _, FileName, _, _, EL, EC]].

% without annot
parseTypeDefQual(TreeIn, ResTree, Path) -->
	[[id, Value, FileName, SL, SC|_]],
	[[dash, _, FileName|_]],
	[[id, Value1, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		valueToAtom(Value1, Name1),
		Item = ast{typeQual:typeDef, mut:true, libName:Name, typeName:Name1, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseTypeSpecs(TreeIn, ResTree, Path) --> 
	(
		(
			parseTypeSpec(TreeIn, TreeOut, Path/'END'),
			[[comma|_]],
			!
		);
		parseTypeSpec(TreeIn, TreeOut, Path/'END')
	),
	(
		(
			parseTypeSpecs(TreeOut, ResTree, Path),
			!
		);
		{ResTree = TreeOut}
	).

parseFuncQual(TreeIn, ResTree, Path) -->
	(
		parseStructQual(TreeIn, TreeOut, Path/argType);
		(
			[[unit, _, FileName, SL, SC, EL, EC]],
			{TreeOut = TreeIn.add(Path/argType, ast{typeQual:unit, mut:true, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC})}
		)
	),
	[[right_move, _, FileName|_]],
	parseTypeSpec(TreeOut, TreeOut1, Path/retType),
	{
		ResTree = TreeOut1
			.add(Path/typeQual, func)
			.add(Path/mut, true)
			.add(Path/fileName, FileName)
			.add(Path/startLine, TreeOut1.find(Path/argType/startLine))
			.add(Path/startCol, TreeOut1.find(Path/argType/startCol))
			.add(Path/endLine, TreeOut1.find(Path/retType/endLine))
			.add(Path/endCol, TreeOut1.find(Path/retType/endCol))
	}.

parseImmutFuncQual(TreeIn, ResTree, Path) -->
	(
		parseStructQual(TreeIn, TreeOut, Path/argType);
		(
			[[unit, _, FileName, SL, SC, EL, EC]],
			{TreeOut = TreeIn.add(Path/argType, ast{typeQual:unit, mut:true, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC})}
		)
	),
	[[grave_accent, _, FileName|_]],
	[[right_move, _, FileName|_]],
	parseTypeSpec(TreeOut, TreeOut1, Path/retType),
	{
		ResTree = TreeOut1
			.add(Path/typeQual, func)
			.add(Path/mut, false)
			.add(Path/fileName, FileName)
			.add(Path/startLine, TreeOut1.find(Path/argType/startLine))
			.add(Path/startCol, TreeOut1.find(Path/argType/startCol))
			.add(Path/endLine, TreeOut1.find(Path/retType/endLine))
			.add(Path/endCol, TreeOut1.find(Path/retType/endCol))
	}.

parseStmts(TreeIn, ResTree, Path) --> 
	(
		(
			parseStmt(TreeIn, TreeOut, Path),
			[[comma|_]],
			!
		);
		parseStmt(TreeIn, TreeOut, Path)
	),
	(
		(
			parseStmts(TreeOut, ResTree, Path),
			!
		);
		{ResTree = TreeOut}
	).

parseStmtStar(TreeIn, ResTree, Path) --> 
	(
		(
			parseStmts(TreeIn, ResTree, Path), 
			!
		);
		{ResTree = TreeIn.add(Path, ast{})}
	).

parseStmt(TreeIn, ResTree, Path) -->
	(
		parseLocalVarDef(TreeIn, ResTree, Path);
		parseCmpStmt(TreeIn, ResTree, Path);
		parseIfStmt(TreeIn, ResTree, Path);
		parseWhileStmt(TreeIn, ResTree, Path);
		parseMatchStmt(TreeIn, ResTree, Path);
		parseResStmt(TreeIn, ResTree, Path);
		parseMoveStmt(TreeIn, ResTree, Path);
		parseDropStmt(TreeIn, ResTree, Path);
		parseExprStmt(TreeIn, ResTree, Path)
	), 
	!.

parseLocalVarDef(TreeIn, ResTree, Path) -->
	[[var, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	[[colon, _, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{stmtType:local_var_def, name:Name, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseTypeSpec(TreeOut, TreeOut1, Path/'LAST'/typeSpec),
	parseArrow(TreeOut1, TreeOut2, Path/'LAST'/arrow),
	parseExpr(TreeOut2, TreeOut3, Path/'LAST'/value),
	{
		ResTree = TreeOut3
			.add(Path/'LAST'/endLine, TreeOut3.find(Path/'LAST'/value/endLine))
			.add(Path/'LAST'/endCol, TreeOut3.find(Path/'LAST'/value/endCol))
	}.

parseCmpStmt(TreeIn, ResTree, Path) -->
	[[lbrace, _, FileName, SL, SC|_]],
	{
		Item = ast{stmtType:cmp_stmt, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseStmts(TreeOut, ResTree, Path/'LAST'/stmts),
	[[rbrace, _, FileName, _, _, EL, EC]].

parseIfStmt(TreeIn, ResTree, Path) -->
	[[if, _, FileName, SL, SC|_]],
	{
		Item = ast{stmtType:if_stmt, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseExpr(TreeOut, TreeOut1, Path/'LAST'/cond),
	parseBlock(TreeOut1, TreeOut2, Path/'LAST'/ifBlock),
	parseElseBlock(TreeOut2, TreeOut3, Path/'LAST'/elseBlock),
	{
		ResTree = TreeOut3
			.add(Path/'LAST'/endLine, TreeOut3.find(Path/'LAST'/elseBlock/endLine))
			.add(Path/'LAST'/endCol, TreeOut3.find(Path/'LAST'/elseBlock/endCol))
	}.

parseBlock(TreeIn, ResTree, Path) -->
	[[lbrace, _, FileName, SL, SC|_]],
	{
		Item = ast{fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseStmtStar(TreeOut, ResTree, Path/stmts),
	[[rbrace, _, FileName, _, _, EL, EC]].

% with block
parseElseBlock(TreeIn, ResTree, Path) -->
	[[else|_]],
	parseBlock(TreeIn, ResTree, Path).

% with if stmt
parseElseBlock(TreeIn, ResTree, Path) -->
	[[else, _, FileName|_]],
	parseIfStmt(TreeIn, TreeOut, Path/stmts),
	{
		ResTree = TreeOut
			.add(Path/fileName, FileName)
			.add(Path/startLine, TreeOut.find(Path/stmts/0/startLine))
			.add(Path/startCol, TreeOut.find(Path/stmts/0/startCol))
			.add(Path/endLine, TreeOut.find(Path/stmts/0/endLine))
			.add(Path/endCol, TreeOut.find(Path/stmts/0/endCol))
	}.

parseWhileStmt(TreeIn, ResTree, Path) -->
	[[while, _, FileName, SL, SC|_]],
	{
		Item = ast{stmtType:while_stmt, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseExpr(TreeOut, TreeOut1, Path/'LAST'/cond),
	parseBlock(TreeOut1, TreeOut3, Path/'LAST'/block),
	{
		ResTree = TreeOut3
			.add(Path/'LAST'/endLine, TreeOut3.find(Path/'LAST'/block/endLine))
			.add(Path/'LAST'/endCol, TreeOut3.find(Path/'LAST'/block/endCol))
	}.

parseMatchStmt(TreeIn, ResTree, Path) -->
	[[match, _, FileName, SL, SC|_]],
	{
		Item = ast{stmtType:match_stmt, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseExpr(TreeOut, TreeOut1, Path/'LAST'/arg),
	[[lbrace, _, FileName|_]],
	parseCases(TreeOut1, ResTree, Path/'LAST'/cases),
	[[rbrace, _, FileName, _, _, EL, EC]].

parseCases(TreeIn, ResTree, Path) --> 
	(
		(
			parseCase(TreeIn, TreeOut, Path),
			[[comma|_]],
			!
		);
		parseCase(TreeIn, TreeOut, Path)
	),
	(
		(
			parseCases(TreeOut, ResTree, Path),
			!
		);
		{ResTree = TreeOut}
	).

% normal case
parseCase(TreeIn, ResTree, Path) -->
	[[id, Value, FileName, SL, SC|_]],
	[[colon, _, FileName|_]],
	{
		valueToAtom(Value, Name),
		Item = ast{name:Name, fileName:FileName, startLine:SL, startCol:SC},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseStmtStar(TreeOut, TreeOut1, Path/'LAST'/stmts),
	{
		ResTree = TreeOut1
			.add(Path/'LAST'/endLine, TreeOut1.find(Path/'LAST'/stmts/endLine))
			.add(Path/'LAST'/endCol, TreeOut1.find(Path/'LAST'/stmts/endCol))
	},
	!.

% default case
parseCase(TreeIn, ResTree, Path) -->
	[[colon, _, FileName|_]],
	{
		Item = ast{fileName:FileName},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseStmtStar(TreeOut, TreeOut1, Path/'LAST'/stmts),
	{
		ResTree = TreeOut1
			.add(Path/'LAST'/startLine, TreeOut1.find(Path/'LAST'/stmts/startLine))
			.add(Path/'LAST'/startCol, TreeOut1.find(Path/'LAST'/stmts/startCol))
			.add(Path/'LAST'/endLine, TreeOut1.find(Path/'LAST'/stmts/endLine))
			.add(Path/'LAST'/endCol, TreeOut1.find(Path/'LAST'/stmts/endCol))
	}.

% with designator
parseResStmt(TreeIn, ResTree, Path, TokIn, TokOut) :-
	TokIn = [[_, _, FileName, SL, SC|_]|_],
	Item = ast{stmtType:res_stmt, fileName:FileName, startLine:SL, startCol:SC},
	TreeOut = TreeIn.add(Path/'END', Item),
	parseDesignator(TreeOut, TreeOut1, Path/'LAST'/designator, TokIn, TokOut1),
	parseArrow(TreeOut1, TreeOut2, Path/'LAST'/arrow, TokOut1, TokOut2),
	parseExpr(TreeOut2, TreeOut3, Path/'LAST'/rvalue, TokOut2, TokOut),
	ResTree = TreeOut3
		.add(Path/'LAST'/endLine, TreeOut3.find(Path/'LAST'/rvalue/endLine))
		.add(Path/'LAST'/endCol, TreeOut3.find(Path/'LAST'/rvalue/endCol)).

% without designator
parseResStmt(TreeIn, ResTree, Path, TokIn, TokOut) :-
	TokIn = [[_, _, FileName, SL, SC|_]|_],
	Item = ast{stmtType:res_stmt, fileName:FileName, startLine:SL, startCol:SC},
	TreeOut = TreeIn.add(Path/'END', Item),
	parseArrow(TreeOut, TreeOut2, Path/'LAST'/arrow, TokIn, TokOut2),
	parseExpr(TreeOut2, TreeOut3, Path/'LAST'/rvalue, TokOut2, TokOut),
	ResTree = TreeOut3
		.add(Path/'LAST'/endLine, TreeOut3.find(Path/'LAST'/rvalue/endLine))
		.add(Path/'LAST'/endCol, TreeOut3.find(Path/'LAST'/rvalue/endCol)).

parseMoveStmt(TreeIn, ResTree, Path) -->
	parseExpr(TreeIn, TreeOut1, Path/'END'/lvalue),
	parseArrow(TreeOut1, TreeOut2, Path/'LAST'/arrow),
	parseExpr(TreeOut2, TreeOut3, Path/'LAST'/rvalue),
	{
		ResTree = TreeOut3
			.add(Path/'LAST'/stmtType, move_stmt)
			.add(Path/'LAST'/fileName, TreeOut3.find(Path/'LAST'/lvalue/fileName))
			.add(Path/'LAST'/startLine, TreeOut3.find(Path/'LAST'/lvalue/startLine))
			.add(Path/'LAST'/startCol, TreeOut3.find(Path/'LAST'/lvalue/startCol))
			.add(Path/'LAST'/endLine, TreeOut3.find(Path/'LAST'/rvalue/endLine))
			.add(Path/'LAST'/endCol, TreeOut3.find(Path/'LAST'/rvalue/endCol))
	}.

parseDropStmt(TreeIn, ResTree, Path) -->
	{
		Item = ast{fileName:FileName, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseExpr(TreeOut, TreeOut1, Path/'LAST'/lvalue),
	[[right_move, _, FileName, _, _, EL, EC]],
	{
		ResTree = TreeOut1
			.add(Path/'LAST'/stmtType, drop_stmt)
			.add(Path/'LAST'/startLine, TreeOut1.find(Path/'LAST'/lvalue/startLine))
			.add(Path/'LAST'/startCol, TreeOut1.find(Path/'LAST'/lvalue/startCol))
	}.

parseExprStmt(TreeIn, ResTree, Path) -->
	{TreeOut1 = TreeIn.add(Path/'END'/value, ast{})},
	parseExpr(TreeOut1, TreeOut, Path/'LAST'/value),
	{
		ResTree = TreeOut
			.add(Path/'LAST'/stmtType, expr_stmt)
			.add(Path/'LAST'/fileName, TreeOut.find(Path/'LAST'/value/fileName))
			.add(Path/'LAST'/startLine, TreeOut.find(Path/'LAST'/value/startLine))
			.add(Path/'LAST'/startCol, TreeOut.find(Path/'LAST'/value/startCol))
			.add(Path/'LAST'/endLine, TreeOut.find(Path/'LAST'/value/endLine))
			.add(Path/'LAST'/endCol, TreeOut.find(Path/'LAST'/value/endCol))
	}.

parseArrow(TreeIn, TreeOut, Path) -->
	[[left_move, _, FileName, SL, SC, EL, EC]],
	{
		Item = ast{arrowType:move, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path/'END', Item)
	}.
parseArrow(TreeIn, TreeOut, Path) -->
	[[left_copy, _, FileName, SL, SC, EL, EC]],
	{
		Item = ast{arrowType:copy, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path/'END', Item)
	}.
parseArrow(TreeIn, TreeOut, Path) -->
	[[left_copy, _, FileName, SL, SC|_]],
	[[question_mark, _, FileName, _, _, EL, EC]],
	{
		Item = ast{arrowType:handled_copy, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path/'END', Item)
	}.

parseExpr(TreeIn, ResTree, Path, TokIn, TokOut) :-
	TokIn = [[_, _, FileName, SL, SC|_]|_],
	Item = ast{fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
	TreeOut = TreeIn.add(Path, Item),
	parsePrim(TreeOut, TreeOut1, Path/prim, TokIn, TokOut1),
	parseOperStar(TreeOut1, ResTree, Path/opers, TokOut1, TokOut),
	append(TokUsed, TokOut, TokIn),
	append(_, [Last], TokUsed),
	Last = [_, _, FileName, _, _, EL, EC].

parsePrim(TreeIn, ResTree, Path) -->
	(
		parseCtor(TreeIn, ResTree, Path);
		parseGlobAccess(TreeIn, ResTree, Path);
		parseLocalAccess(TreeIn, ResTree, Path)
	),
	!.

parseLocalAccess(TreeIn, ResTree, Path) -->
	[[id, Value, FileName, SL, SC, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{primType:local_access, name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseGlobAccess(TreeIn, ResTree, Path) -->
	[[id, Value, FileName, SL, SC|_]],
	[[dash, _, FileName|_]],
	[[id, Value1, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		valueToAtom(Value1, Name1),
		Item = ast{primType:glob_access, libName:Name, itemName:Name1, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseCtor(TreeIn, ResTree, Path) -->
(
	% consts
	parseUintConst(TreeIn, ResTree, Path);
	parseIntConst(TreeIn, ResTree, Path);
	parseFloatConst(TreeIn, ResTree, Path);
	parseCharConst(TreeIn, ResTree, Path);
	parseStrConst(TreeIn, ResTree, Path);
	parseBoolConst(TreeIn, ResTree, Path);
	parseUnitConst(TreeIn, ResTree, Path);
	% ctors
	parseStructCtor(TreeIn, ResTree, Path);
	parseUnionCtor(TreeIn, ResTree, Path);
	parseArrayCtor(TreeIn, ResTree, Path)
),
!.

parseUintConst(TreeIn, ResTree, Path) -->
	[[uint_const, Value, FileName, SL, SC, EL, EC]],
	{
		Item = ast{primType:uint_const, value:Value, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseIntConst(TreeIn, ResTree, Path) -->
	[[int_const, Value, FileName, SL, SC, EL, EC]],
	{
		Item = ast{primType:int_const, value:Value, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseFloatConst(TreeIn, ResTree, Path) -->
	[[float_const, Value, FileName, SL, SC, EL, EC]],
	{
		Item = ast{primType:float_const, value:Value, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseCharConst(TreeIn, ResTree, Path) -->
	[[char_const, Value, FileName, SL, SC, EL, EC]],
	{
		valueToAtom(Value, Char),
		Item = ast{primType:char_const, value:Char, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseStrConst(TreeIn, ResTree, Path) -->
	[[str_const, Value, FileName, SL, SC, EL, EC]],
	{
		valueToAtom(Value, Str),
		Item = ast{primType:str_const, value:Str, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseBoolConst(TreeIn, ResTree, Path) -->
	[[bool_const, Value, FileName, SL, SC, EL, EC]],
	{
		valueToAtom(Value, Bool),
		Item = ast{primType:bool_const, value:Bool, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseUnitConst(TreeIn, ResTree, Path) -->
	[[unit, _, FileName, SL, SC, EL, EC]],
	{
		Item = ast{primType:unit_const, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path, Item)
	}.

parseStructCtor(TreeIn, ResTree, Path) -->
	[[lparen, _, FileName, SL, SC|_]],
	{
		Item = ast{primType:struct_ctor, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseIniters(TreeOut, ResTree, Path/initers),
	[[rparen, _, FileName, _, _, EL, EC]].

parseUnionCtor(TreeIn, ResTree, Path) -->
	[[lbrace, _, FileName, SL, SC|_]],
	{
		Item = ast{primType:union_ctor, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseIniters(TreeOut, ResTree, Path/initers),
	[[rbrace, _, FileName, _, _, EL, EC]].

parseArrayCtor(TreeIn, ResTree, Path) -->
	[[lbracket, _, FileName, SL, SC|_]],
	{
		Item = ast{primType:array_ctor, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path, Item)
	},
	parseIniters(TreeOut, ResTree, Path/initers),
	[[rbracket, _, FileName, _, _, EL, EC]].

parseIniters(TreeIn, ResTree, Path) --> 
	(
		(
			parseIniter(TreeIn, TreeOut, Path),
			[[comma|_]],
			!
		);
		parseIniter(TreeIn, TreeOut, Path)
	),
	(
		(
			parseIniters(TreeOut, ResTree, Path),
			!
		);
		{ResTree = TreeOut}
	).

parseIniter(TreeIn, ResTree, Path) --> 
	(
		parseRegIniter(TreeIn, ResTree, Path);
		parsePosIniter(TreeIn, ResTree, Path)
	),
	!.

parseRegIniter(TreeIn, ResTree, Path, TokIn, TokOut) :-
	TokIn = [[_, _, FileName, SL, SC|_]|_],
	Item = ast{fileName:FileName, startLine:SL, startCol:SC},
	TreeOut = TreeIn.add(Path/'END', Item),
	parseDesignator(TreeOut, TreeOut1, Path/'LAST'/designator, TokIn, TokOut1),
	parseArrow(TreeOut1, TreeOut2, Path/'LAST'/arrow, TokOut1, TokOut2),
	parseExpr(TreeOut2, TreeOut3, Path/'LAST'/rvalue, TokOut2, TokOut),
	ResTree = TreeOut3
		.add(Path/'LAST'/endLine, TreeOut3.find(Path/'LAST'/rvalue/endLine))
		.add(Path/'LAST'/endCol, TreeOut3.find(Path/'LAST'/rvalue/endCol)).

% with arrow
parsePosIniter(TreeIn, ResTree, Path) -->
	parseArrow(TreeIn, TreeOut, Path/'END'/arrow),
	parseExpr(TreeOut, TreeOut1, Path/'LAST'/rvalue),
	{
		ResTree = TreeOut1
			.add(Path/'LAST'/fileName, TreeOut1.find(Path/'LAST'/arrow/fileName))
			.add(Path/'LAST'/startLine, TreeOut1.find(Path/'LAST'/arrow/startLine))
			.add(Path/'LAST'/startCol, TreeOut1.find(Path/'LAST'/arrow/startCol))
			.add(Path/'LAST'/endLine, TreeOut1.find(Path/'LAST'/rvalue/endLine))
			.add(Path/'LAST'/endCol, TreeOut1.find(Path/'LAST'/rvalue/endCol))
	}.

% without arrow
parsePosIniter(TreeIn, ResTree, Path) -->
	parseExpr(TreeIn, TreeOut1, Path/'END'/rvalue),
	{
		FileName = TreeOut1.find(Path/'LAST'/rvalue/fileName),
		SL = TreeOut1.find(Path/'LAST'/rvalue/startLine),
		SC = TreeOut1.find(Path/'LAST'/rvalue/startCol),
		EL = TreeOut1.find(Path/'LAST'/rvalue/endLine),
		EC = TreeOut1.find(Path/'LAST'/rvalue/endCol),
		ResTree = TreeOut1
			.add(Path/'LAST'/arrow, ast{arrowType:move, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC})
			.add(Path/'LAST'/fileName, FileName)
			.add(Path/'LAST'/startLine, SL)
			.add(Path/'LAST'/startCol, SC)
			.add(Path/'LAST'/endLine, EL)
			.add(Path/'LAST'/endCol, EC)
	}.

parseOperStar(TreeIn, ResTree, Path) -->
	(
		(
			parseOpers(TreeIn, ResTree, Path), 
			!
		);
		{ResTree = TreeIn.add(Path, ast{})}
	).

parseOpers(TreeIn, ResTree, Path) -->
	(
		(
			parseHandle(TreeIn, TreeOut, Path);
			parseGetAdr(TreeIn, TreeOut, Path);
			parseGetPtr(TreeIn, TreeOut, Path);
			parseDerefAdr(TreeIn, TreeOut, Path);
			parseDerefPtr(TreeIn, TreeOut, Path);
			parseIndexing(TreeIn, TreeOut, Path);
			parseMethodCall(TreeIn, TreeOut, Path);
			parseFieldSelect(TreeIn, TreeOut, Path);
			parseFnCall(TreeIn, TreeOut, Path)
		),
		!,
		(
			(
				parseOpers(TreeOut, ResTree, Path),
				!
			);
			{ResTree = TreeOut}
		)
	).

parseHandle(TreeIn, ResTree, Path) -->
	[[question_mark, _, FileName, SL, SC, EL, EC]],
	{
		Item = ast{operType:handle, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path/'END', Item)
	}.

parseGetAdr(TreeIn, ResTree, Path) -->
	[[ampersand, _, FileName, SL, SC, EL, EC]],
	{
		Item = ast{operType:get_adr, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path/'END', Item)
	}.

parseGetPtr(TreeIn, ResTree, Path) -->
	[[dollar, _, FileName, SL, SC, EL, EC]],
	{
		Item = ast{operType:get_ptr, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path/'END', Item)
	}.

parseDerefAdr(TreeIn, ResTree, Path) -->
	[[asterisk, _, FileName, SL, SC, EL, EC]],
	{
		Item = ast{operType:deref_adr, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path/'END', Item)
	}.

parseDerefPtr(TreeIn, ResTree, Path) -->
	[[caret, _, FileName, SL, SC, EL, EC]],
	{
		Item = ast{operType:deref_ptr, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path/'END', Item)
	}.

parseIndexing(TreeIn, ResTree, Path) -->
	[[lbracket, _, FileName, SL, SC|_]],
	{
		Item = ast{operType:indexing, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		TreeOut = TreeIn.add(Path/'END', Item)
	},
	parseExpr(TreeOut, ResTree, Path/'LAST'/value),
	[[rbracket, _, FileName, _, _, EL, EC]].

parseFieldSelect(TreeIn, ResTree, Path) -->
	[[dot, _, FileName, SL, SC|_]],
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		Item = ast{operType:field_select, name:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
		ResTree = TreeIn.add(Path/'END', Item)
	}.

% with annot
parseFnCall(TreeIn, ResTree, Path) -->
	[[langle_bracket, _, FileName, SL, SC|_]],
	parseTypeSpecs(TreeIn, TreeOut, Path/'END'/typeAnnot),
	[[rangle_bracket, _, FileName|_]],
	(
		parseStructQual(TreeOut, TreeOut1, Path/'LAST'/arg);
		(
			[[unit, _, FileName, SL1, SC1, EL, EC]],
			{TreeOut1 = TreeOut.add(Path/'LAST'/arg, ast{typeQual:unit, mut:true, fileName:FileName, startLine:SL1, startCol:SC1, endLine:EL, endCol:EC})}
		)
	),
	{
		ResTree = TreeOut1
			.add(Path/'LAST'/operType, fn_call)
			.add(Path/'LAST'/fileName, FileName)
			.add(Path/'LAST'/startLine, SL)
			.add(Path/'LAST'/startCol, SC)
			.add(Path/'LAST'/endLine, TreeOut1.find(Path/'LAST'/arg/endLine))
			.add(Path/'LAST'/endCol, TreeOut1.find(Path/'LAST'/arg/endCol))
	}.

% without annot
parseFnCall(TreeIn, ResTree, Path) -->
	(
		parseStructQual(TreeIn, TreeOut1, Path/'LAST'/arg);
		(
			[[unit, _, FileName, SL1, SC1, EL, EC]],
			{TreeOut1 = TreeIn.add(Path/'LAST'/arg, ast{typeQual:unit, mut:true, fileName:FileName, startLine:SL1, startCol:SC1, endLine:EL, endCol:EC})}
		)
	),
	{
		ResTree = TreeOut1
			.add(Path/'LAST'/operType, fn_call)
			.add(Path/'LAST'/fileName, TreeOut1.find(Path/'LAST'/arg/fileName))
			.add(Path/'LAST'/startLine, TreeOut1.find(Path/'LAST'/arg/startLine))
			.add(Path/'LAST'/startCol, TreeOut1.find(Path/'LAST'/arg/startCol))
			.add(Path/'LAST'/endLine, TreeOut1.find(Path/'LAST'/arg/endLine))
			.add(Path/'LAST'/endCol, TreeOut1.find(Path/'LAST'/arg/endCol))
	}.

% with annot
parseMethodCall(TreeIn, ResTree, Path) -->
	[[dot, _, FileName, SL, SC|_]],
	parseExpr(TreeIn, TreeOut, Path/'END'/func),
	[[langle_bracket, _, FileName|_]],
	parseTypeSpecs(TreeOut, TreeOut1, Path/'LAST'/typeAnnot),
	[[rangle_bracket, _, FileName|_]],
	(
		parseStructQual(TreeOut1, TreeOut2, Path/'LAST'/arg);
		(
			[[unit, _, FileName, SL1, SC1, EL, EC]],
			{TreeOut2 = TreeOut1.add(Path/'LAST'/arg, ast{typeQual:unit, mut:true, fileName:FileName, startLine:SL1, startCol:SC1, endLine:EL, endCol:EC})}
		)
	),
	{
		ResTree = TreeOut2
			.add(Path/'LAST'/operType, method_call)
			.add(Path/'LAST'/fileName, FileName)
			.add(Path/'LAST'/startLine, SL)
			.add(Path/'LAST'/startCol, SC)
			.add(Path/'LAST'/endLine, TreeOut2.find(Path/'LAST'/arg/endLine))
			.add(Path/'LAST'/endCol, TreeOut2.find(Path/'LAST'/arg/endCol))
	}.

% without annot
parseMethodCall(TreeIn, ResTree, Path) -->
	[[dot, _, FileName, SL, SC|_]],
	parseExpr(TreeIn, TreeOut1, Path/'END'/func),
	(
		parseStructQual(TreeOut1, TreeOut2, Path/'LAST'/arg);
		(
			[[unit, _, FileName, SL1, SC1, EL, EC]],
			{TreeOut2 = TreeOut1.add(Path/'LAST'/arg, ast{typeQual:unit, mut:true, fileName:FileName, startLine:SL1, startCol:SC1, endLine:EL, endCol:EC})}
		)
	),
	{
		ResTree = TreeOut2
			.add(Path/'LAST'/operType, method_call)
			.add(Path/'LAST'/fileName, FileName)
			.add(Path/'LAST'/startLine, SL)
			.add(Path/'LAST'/startCol, SC)
			.add(Path/'LAST'/endLine, TreeOut2.find(Path/'LAST'/arg/endLine))
			.add(Path/'LAST'/endCol, TreeOut2.find(Path/'LAST'/arg/endCol))
	}.

parseDesignator(TreeIn, ResTree, Path) -->
	(
		parseHandle(TreeIn, TreeOut, Path);
		parseDerefAdr(TreeIn, TreeOut, Path);
		parseDerefPtr(TreeIn, TreeOut, Path);
		parseIndexing(TreeIn, TreeOut, Path);
		parseFieldSelect(TreeIn, TreeOut, Path)
	),
	(
		(
			parseDesignator(TreeOut, ResTree, Path),
			!
		);
		{ResTree = TreeOut}
	).
