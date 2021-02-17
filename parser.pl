%token
%[Tag, Value, FileName, SL, SC, EL, EC]

%error
%[Text, FileName, SL, SC, EL, EC]

addErrors(Tree, Error, Res) :-
	(
		Errors = Tree.get(errors) ->
		(
			append(Errors, Error, ResErrors),
			Res = Tree.put(errors, ResErrors)
		);
		(
			Res = Tree.put(errors, Error)
		)
	).

invalid(Node) :- is_list(Node).
valid(Node) :- is_dict(Node).

addNode(TreeIn, Path, Node, ResTree) :-
	(
		is_dict(Node) ->
		(
			ResTree = TreeIn.put(Path, Node)
		);
		(
			addErrors(TreeIn, Node, ResTree)
		)
	).

valueToAtom([], '').
valueToAtom([Hd|Tl], ResAtom) :-
	atomic_concat(Hd, Atom, ResAtom),
	valueToAtom(Tl, Atom).

del0(0, [_|Tl], Tl).
del0(Ind, [Hd|Tl], [Hd|Res]) :-
	Ind \= 0,
	Next is Ind - 1,
	del0(Next, Tl, Res).

dictToList(Dict, List) :-
	findall(Value, get_dict(_, Dict, Value), List).


parse(NodeType, TreeIn, TreeOut) :-
	atomic_concat(parse, NodeType, Goal),
	call(Goal, TreeIn, Node),



parse(TreeIn, TreeIn, [], []).
parse(TreeIn, TreeOut) -->
	(
		parseImport(TreeIn, ResTree);
		parseLibDef(TreeIn, ResTree);
		parseMain(TreeIn, ResTree)
	),
	parse(ResTree, TreeOut).

parseImport(TreeIn, ResTree) -->
	[[import, _, FileName, SL, SC|_]],
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		(
			%errors
			TreeIn.get(imports).get(Name) ->
			(
				atomic_concat('Repeated import of ', Name, Text),
				Item = [[Text, FileName, SL, SC, EL, EC]]
			);
			%valid result
			(
				Item = import{libName:Name, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC}
			)
		),
		addNode(TreeIn, imports/Name, Item, ResTree)
	}.

parseLibDef(TreeIn, ResTree) -->
	[[lib, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	{
		valueToAtom(Value, Name),
		(
			%errors
			TreeIn.get(libDefs).get(Name) ->
			(
				format(atom(Text), 'Redefinition of ~w lib', [Name]),
				Item = [[Text, FileName, SL, SC, EL, EC]],
				Silent = true
			);
			%valid result
			(
				Item = lib_def{libName:Name, exports:Exports, items:Items, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
				Silent = false
			)
		),
		addNode(TreeIn, libDefs/Name, Item, TreeOut)
	},
	[[colon, _, FileName|_]],
	[[lparen, _, FileName|_]],
	parseExports(TreeOut, TreeOut1, Name, Silent),
	[[rparen, _, FileName|_]],
	[[lbrace, _, FileName|_]],
	parseLibItems(TreeOut1, TreeOut2, Name, Silent),
	[[rbrace, _, FileName, _, _, EL, EC]],
	{
		valid(Item),
		%error check
		exportOfNotDefinedItem(Name, TreeOut2, ResTree)
	}.

exportOfNotDefinedItem(Name, TreeIn, ResTree) :-
	exportOfNotDefinedItemImpl(Name, 0, TreeIn, ResTree).
exportOfNotDefinedItemImpl(Name, Cur, TreeIn, ResTree) :-
	(
		dictToList(TreeIn.get(libDefs).get(Name).get(exports), Exports)
		nth0(Cur, Exports, Export),
		(
			foreach(member(Item, TreeIn.get(libDefs).get(Name).get(items)), invalidExport(Export, Item)) ->
			(
				del0(Cur, Exports, ResExports),
				TreeOut = TreeIn.put(libDefs/Name/exports, ResExports),
				format(atom(Error), 'Exporting of not defined ~w ~w', [Export.itemType, Export.name]),
				addErrors(TreeOut, [[Error, Export.fileName, Export.startLine, Export.startCol, Export.endLine, Export.endCol]], TreeOut1),
				Next is Cur
			);
			(
				Next is Cur + 1,
				TreeOut1 = TreeIn
			)
		),
		exportOfNotDefinedItemImpl(Name, Next, TreeOut1, ResTree)
	);
	TreeIn = ResTree.

invalidExport(Export, Item) :-
	Export.name \= Item.name,
	Export.itemType \= Item.itemType.

parseExports(TreeIn, ResTree, Name, Silent) -->
	parseExport(TreeIn, TreeOut, Name, Silent),
	(
		parseExports(TreeOut, ResTree, Name, Silent);
		ResTree = TreeOut
	).

parseExport(TreeIn, TreeOut, LibName, Silent) -->
	(
		[[type, _, FileName, SL, SC|_]] -> {ItemType = type};
		[[var, _, FileName, SL, SC|_]] -> {ItemType = var};
		[[fn, _, FileName, SL, SC|_]] -> {ItemType = fn}
	),
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		(
			%errors
			TreeIn.get(libDefs).get(LibName).get(exports).get(Name) ->
			(
				(
					TreeIn.get(libDefs).get(LibName).get(exports).get(Name).get(itemType) = ItemType ->
					(
						format(atom(Text), 'Reexport of ~w ~w', [ItemType, Name])
					);
					(
						format(atom(Text), 'Name collision of exported ~w ~w', [ItemType, Name])
					)
				),
				Item = [[Text, FileName, SL, SC, EL, EC]]
			);
			%valid result
			(
				Item = export{name:Name, itemType:ItemType, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC}
			)
		),
		(
			\+ Silent ->
			addNode(TreeIn, libDefs/LibName/exports/Name, Item, TreeOut)
		)
	}.

parseLibItems(TreeIn, ResTree, LibName Silent),
	parseLibItem(TreeIn, TreeOut, LibName, Silent),
	(
		parseLibItems(TreeOut, ResTree, LibName, Silent);
		ResTree = TreeOut
	).

parseLibItem(TreeIn, TreeOut, LibName, Silent) -->
	parseTypeDef(TreeIn, TreeOut, LibName, Silent);
	parseFnDef(TreeIn, TreeOut, LibName, Silent);
	parseVarDef(TreeIn, TreeOut, LibName, Silent).

parseTypeDef(TreeIn, ResTree, LibName, Silent) -->
	[[type, _, FileName, SL, SC|_]],
	[[id, Value, FileName|_]],
	(
		(
			parsePlacehldrAnnot(Annot),
			(invalid(Annot) -> Silent = true)
		);
		Annot = false
	),
	[[colon, _, FileName|_]],
	parseTypeSpec(TreeIn, Type),
	{
		EL = Type.endLine,
		EC = Type.endCol,
		valueToAtom(Value, Name),
		(
			%errors
			valid(Annot) ->
			(
				dictToList(Annot, Placehldrs),
				(
					TreeIn.get(libDefs).get(LibName).get(items).get(Name).get(itemType) = type ->
					(
						format(atom(Text), 'Redefinition of type ~w', [Name])
					);
					(
						format(atom(Text), 'Name collision of type ~w', [Name])
					)
				),
				Item = [[Text, FileName, SL, SC, EL, EC]]
			);
			TreeIn.get(libDefs).get(LibName).get(items).get(Name) ->
			(
				(
					TreeIn.get(libDefs).get(LibName).get(items).get(Name).get(itemType) = type ->
					(
						format(atom(Text), 'Redefinition of type ~w', [Name])
					);
					(
						format(atom(Text), 'Name collision of type ~w', [Name])
					)
				),
				Item = [[Text, FileName, SL, SC, EL, EC]]
			);
			%valid result
			(
				Annot \= false ->
				(
					Item = type{name:Name, itemType:type, typeSpec:Type, placehldrAnnot:Annot, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC}
				);
				Item = type{name:Name, itemType:type, typeSpec:Type, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC}
			)
		),
		(
			\+ Silent ->
			(
				addNode(TreeIn, libDefs/LibName/items/Name, Item, TreeOut),
				(
					Annot \= false ->
					(addNode(TreeOut, libDefs/LibName/items/Name/placehldrAnnot, Annot, ResTree));
					(ResTree = TreeOut)
				)
			)
		)
	}.

		parsePlacehldrAnnot(Annot) ->




	%%%
	parseFnDef(TreeIn, TreeOut, LibName, Silent);
	parseVarDef(TreeIn, TreeOut, LibName, Silent).

	parseMain(TreeIn, ResTree)














		[[type, _, FileName, SL, SC|_]] -> {ItemType = type};
		[[var, _, FileName, SL, SC|_]] -> {ItemType = var};
		[[fn, _, FileName, SL, SC|_]] -> {ItemType = fn}
	),
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		(
			%errors
			TreeIn.get(libDefs).get(LibName).get(exports).get(Name) ->
			(
				(
					TreeIn.get(libDefs).get(LibName).get(exports).get(Name).get(itemType) = ItemType ->
					(
						format(atom(Text), 'Reexport of ~w ~w', [ItemType, Name])
					);
					(
						format(atom(Text), 'Name collision of exported ~w ~w', [ItemType, Name])
					)
				),
				Item = [[Text, FileName, SL, SC, EL, EC]]
			);
			%valid result
			(
				Item = export{name:Name, itemType:ItemType, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC}
			)
		),
		(
			\+ Silent ->
			addNode(TreeIn, libDefs/LibName/exports/Name, Item, TreeOut)
		)
	}.



libDefErrors(TreeIn, Exports, Items, Name, Pos, Res) :-
	(
		findall(Member, memberError(Member, Exports), Errors);
		Errors = []
	),
	(
		findall(Member1, memberError(Member1, Items), Errors1);
		Errors1 = []
	),
	(
		TreeIn.get(libDefs).get(Name) ->
		(
			format(atom(Text), 'Redefinition of ~w lib', [Name]),
			Errors2 = [[Text|Pos]],
		);
		Errors2 = []
	),
	(
		findall([Member2|Pos], exportNotDefinedItem(Member2, Exports, Items), Errors3);
		Errors3 = []
	),
	append(Errors, Errors1, Temp),
	append(Temp, Errors2, Temp1),
	append(Temp1, Errors3, Res).

memberError(Member, List) :-
	member(Member, List),
	is_list(Member).

memberValid(Member, List) :-
	member(Member, List),
	is_dict(Member).

exportNotDefinedItem(Error, Exports, Items) :-
	memberValid(Export, Exports),
	foreach(memberValid(Item, Items), invalidExport(Export, Item)),
	format(atom(Error), 'Exporting of not defined ~w ~w', [Export.itemType, Export.name]).


parseExports(Exports) -->
	parseExports(RawExports),
	{exportsErrors(RawExports, Exports)}.

exportsErrors(Exports, Res) :- exportsErrorsImpl(Exports, 0, Res).
exportsErrorsImpl(Exports, Cur, Result) :-
	(
		nth0(Cur, Exports, Export),
		Result = [Res|Rest],
		(
			%reexport
			\+ foreach(elemBefore(Exports, Cur, Elem), difExports(Elem, Export)) ->
			(
				Export = export{name:Name, itemType:ItemType, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
				format(atom(Error), 'Repeated export of ~w ~w', [ItemType, Name]),
				Res = [Error, FileName, SL, SC, EL, EC]
			);
			%same name
			\+ foreach(elemBefore(Exports, Cur, Elem), difNames(Elem, Export)) ->
			(
				Export = export{name:Name, itemType:ItemType, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC},
				format(atom(Error), 'Name collision of exported ~w ~w', [ItemType, Name]),
				Res = [Error, FileName, SL, SC, EL, EC]
			);
			(
				Res = Export
			)
		),
		Next is Cur + 1,
		exportsErrorsImpl(Exports, Next, Rest)
	);
	(
		Result = []
	).

elemBefore(List, Ind, Elem) :-
	Index is Ind - Num,
	between(1, Ind, Num),
	nth0(Index, List, Elem).

difName(Elem, Export) :-
	Export.name \= Elem.name.

difExports(Elem, Export) :-
	Export.name \= Elem.name,
	Export.itemType \= Elem.itemType.

parseExports([Export|Rest]) -->
	parseItemExport(Export),
	(
		parseExports(Rest);
		{Rest = []}
	).

parseItemExport(Export) -->
	(
		[[type, _, FileName, SL, SC|_]] -> {ItemType = type};
		[[var, _, FileName, SL, SC|_]] -> {ItemType = var};
		[[fn, _, FileName, SL, SC|_]] -> {ItemType = fn}
	),
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		Export = export{name:Name, itemType:ItemType, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC}
	}.

parseLibItems(TreeIn, Items) -->



parseLibItem(TreeIn, Item) -->
	parseTypeDef(TreeIn, Item);
	parseFnDef(TreeIn, Item);
	parseVarDef(TreeIn, Item).

parseTypeDef(TreeIn, Item) -->
	(
		[[type, _, FileName, SL, SC|_]] -> {ItemType = type};
		[[var, _, FileName, SL, SC|_]] -> {ItemType = var};
		[[fn, _, FileName, SL, SC|_]] -> {ItemType = fn}
	),
	[[id, Value, FileName, _, _, EL, EC]],
	{
		valueToAtom(Value, Name),
		Export = export{name:Name, itemType:ItemType, fileName:FileName, startLine:SL, startCol:SC, endLine:EL, endCol:EC}
	}.



parseMain(TreeIn, Item) :-



