
:- dynamic index/2.

nextIndex(Name, Index) :- 
	index(Name, PrevIndex), retract(index(Name, PrevIndex)), Index is PrevIndex + 1, assert(index(Name, Index));
	assert(index(Name, 0)), Index is 0.

nextTempName(Name) :-
	nextIndex('__temp__', ID),
	atomic_concat('_', ID, Name).

curTempName(Name) :-
	index('__temp__', ID),
	atomic_concat('_', ID, Name).

astNthNode(AST, [Ind|[]], Node):- 
	nth0(Ind, AST, Node).
astNthNode(AST, [Ind|IndTl], Node):- 
	nth0(Ind, AST, AST1),
	astNthNode(AST1, IndTl, Node). 

astSetNode([_|Tl], [0|[]], Node, [ResHd|ResTl]) :- 
	ResHd = Node,
	ResTl = Tl.
astSetNode([Hd|Tl], [Ind|[]], Node, [ResHd|ResTl]) :- 
	ResHd = Hd,
	NextInd is Ind - 1,
	astSetNode(Tl, [NextInd|[]], Node, ResTl).
astSetNode([Hd|Tl], [0|RestInd], Node, [ResHd|ResTl]) :- 
	ResTl = Tl,
	astSetNode(Hd, RestInd, Node, ResHd).
astSetNode([Hd|Tl], [Ind|RestInd], Node, [ResHd|ResTl]) :- 
	ResHd = Hd,
	NextInd is Ind - 1,
	astSetNode(Tl, [NextInd|RestInd], Node, ResTl).

astInsertNode([Hd|Tl], [0|[]], Node, Res) :- 
	Res = [Node, Hd|Tl].
astInsertNode([Hd|Tl], [Ind|[]], Node, [ResHd|ResTl]) :- 
	ResHd = Hd,
	NextInd is Ind - 1,
	astInsertNode(Tl, [NextInd|[]], Node, ResTl).
astInsertNode([Hd|Tl], [0|RestInd], Node, [ResHd|ResTl]) :- 
	ResTl = Tl,
	astInsertNode(Hd, RestInd, Node, ResHd).
astInsertNode([Hd|Tl], [Ind|RestInd], Node, [ResHd|ResTl]) :- 
	ResHd = Hd,
	NextInd is Ind - 1,
	astInsertNode(Tl, [NextInd|RestInd], Node, ResTl).

astAppendNodes([Hd|Tl], [0|[]], Nodes, Res) :- 
	append(Nodes, [Hd|Tl], Res).
astAppendNodes([Hd|Tl], [Ind|[]], Nodes, [ResHd|ResTl]) :- 
	ResHd = Hd,
	NextInd is Ind - 1,
	astAppendNodes(Tl, [NextInd|[]], Nodes, ResTl).
astAppendNodes([Hd|Tl], [0|RestInd], Nodes, [ResHd|ResTl]) :- 
	ResTl = Tl,
	astAppendNodes(Hd, RestInd, Nodes, ResHd).
astAppendNodes([Hd|Tl], [Ind|RestInd], Nodes, [ResHd|ResTl]) :- 
	ResHd = Hd,
	NextInd is Ind - 1,
	astAppendNodes(Tl, [NextInd|RestInd], Nodes, ResTl).

astToPrevNode(AST, Loc, Node, ResLoc) :-
	append(Rest, [Last], Loc),
	(
		Last = -1 ->
		(
			astToPrevNode(AST, Rest, Node, ResLoc)
		);
		(
			astNthNode(AST, Loc, SomeNode),
			(
				SomeNode = Node ->
				(
					ResLoc = Loc
				);
				(
					LastInd is Last - 1,
					append(Rest, [LastInd], Loc1),
					astToPrevNode(AST, Loc1, Node, ResLoc)
				)
			)
		)
	).



astHandle -->
	removeEmpties,
	addArgDefsAndResDeclToFuncs,
	resStmtToMoveStmt,
	lValueStmtalizy
	.





removeEmpties(Arg, Res) :- 
	(
		Arg = [[]|Tl] ->
		(
			removeEmpties(Tl, Res)
		);
		Arg = [Hd|Tl] ->
		(
			(
				Hd = [_|_] ->
				(
					removeEmpties(Hd, Hd1)
				);
				Hd = Hd1
			),
			removeEmpties(Tl, Tl1),
			Res = [Hd1|Tl1]
		);
		Arg = [] -> Res = []
	).

addArgDefsAndResDeclToFuncs(AST, ResAST) :-
	astNthNode(AST, Loc, [fn_body, _]) ->
	(
		append(RestInd, [LastInd], Loc),
		TypeInd is LastInd - 1,
		append(RestInd, [TypeInd], TypeLoc),

		astNthNode(AST, TypeLoc, FnType),
		FnType = [func_qual, [struct_qual, Args], RetType],
		argToDecl(Args, ArgDecls),


		append(ArgDecls, [[local_var_decl, '__res__', RetType]], Decls),

		append(Loc, [1, 0], Pos),
		astAppendNodes(AST, Pos, Decls, AST1),
		astNthNode(AST1, Loc, [fn_body, Stmts]),
		astSetNode(AST1, Loc, [fnBody, Stmts], AST2),


		addArgDefsAndResDeclToFuncs(AST2, ResAST)
	);
	AST = ResAST.

argToDecl(Args, ArgDecls) :- argToDeclImpl(Args, ArgDecls, 0).
argToDeclImpl([], [], _).
argToDeclImpl([[field, Name, Type]|Args], [[local_var_decl, Name, Type], [argAccess, Name, Num]|ArgDecls], Num) :-
	Num1 is Num + 1,
	argToDeclImpl(Args, ArgDecls, Num1).

resStmtToMoveStmt(AST, ResAST) :-
	astNthNode(AST, Loc, [res_stmt, [designator, Opers], Arrow, Expr]) ->
	(
		astSetNode(AST, Loc, [move_stmt, [expr, [id, '__res__'], Opers], Arrow, Expr], AST1),


		resStmtToMoveStmt(AST1, ResAST)
	);
	AST = ResAST.

lValueStmtalizy(AST, ResAST) :-
	% mark l-value exprs and morph move_stmt to move
	astNthNode(AST, Loc, [move_stmt, [expr|Rest], [arrow, 'LEFT_MOVE'], Expr1]) ->
	(
		astSetNode(AST, Loc, [move, [markedExpr|Rest], Expr1], AST1),


		lValueStmtalizy(AST1, ResAST)
	);
	astNthNode(AST, Loc, [move_stmt, [expr|Rest], [arrow, 'LEFT_COPY'], [expr, Prim, Opers]]) ->
	(
		append(Opers, [copy], Opers1),
		astSetNode(AST, Loc, [move, [markedExpr|Rest], [expr, Prim, Opers1]], AST1),


		lValueStmtalizy(AST1, ResAST)
	);
	astNthNode(AST, Loc, [move_stmt, [expr|Rest], [arrow, 'LEFT_COPY', handle], [expr, Prim, Opers]]) ->
	(
		append(Opers, [copy, handle], Opers1),
		astSetNode(AST, Loc, [move, [markedExpr|Rest], [expr, Prim, Opers1]], AST1),


		lValueStmtalizy(AST1, ResAST)
	);
	% handle local access marked expr
	astNthNode(AST, Loc, [markedExpr, [id, Name], Opers]) ->
	(
		append(Pos, [_], Loc),

		astToPrevNode(AST, Loc, [fnBody|_], ResLoc),
		astNthNode(AST, ResLoc, FnBody),
		append(ResLoc, Pos1, Loc),
		astToPrevNode(FnBody, Pos1, [local_var_decl, Name, Type], _),

		nextTempName(Temp),
		Stmts = [[local_var_decl, Temp, Type], [localAccess, Temp, Name]],

		astSetNode(AST, Loc, [opers, Temp, Opers], AST1),
		astAppendNodes(AST1, Pos, Stmts, AST2),


		lValueStmtalizy(AST2, ResAST)
	);
	% handle glob access marked expr
	astNthNode(AST, Loc, [markedExpr, [path, LibName, Name], Opers]) ->
	(
		append(Pos, [_], Loc),

		astNthNode(AST, Loc, [lib_def, LibName|_]),
		astNthNode(AST, Loc, Lib),
		(
			astNthNode(Lib, _, [fn_def, Name, _, Type|_]);
			astNthNode(Lib, _, [glob_var_def, Name, Type|_])
		),

		nextTempName(Temp),
		Stmts = [[local_var_decl, Temp, Type], [globAccess, Temp, LibName, Name]],

		astSetNode(AST, Loc, [opers, Temp, Opers], AST1),
		astAppendNodes(AST1, Pos, Stmts, AST2),


		lValueStmtalizy(AST2, ResAST)
	);
	% handle field select oper
	astNthNode(AST, Loc, [opers, Name, [[field_select, ID]|Rest]]) ->
	(
		astToPrevNode(AST, Loc, [fnBody|_], ResLoc),
		astNthNode(AST, ResLoc, FnBody),
		append(ResLoc, Pos1, Loc),
		astToPrevNode(FnBody, Pos1, [local_var_decl, Name, VarType], _),

		VarType = [_, Fields],
		member([field, ID, FieldType], Fields),
		Type = FieldType,
		Stmts = [[local_var_decl, Temp, Type], [fieldSelect, Temp, Name, ID]],

		nextTempName(Temp),
		astSetNode(AST, Loc, [opers, Temp, Rest], AST1),

		append(Pos, [_], Loc),
		astAppendNodes(AST1, Pos, Stmts, AST2),


		lValueStmtalizy(AST2, ResAST)
	);
	% handle indexing oper
	astNthNode(AST, Loc, [opers, Name, [[indexing, Expr]|Rest]]) ->
	(
		astToPrevNode(AST, Loc, [fnBody|_], ResLoc),
		astNthNode(AST, ResLoc, FnBody),
		append(ResLoc, Pos1, Loc),
		astToPrevNode(FnBody, Pos1, [local_var_decl, Name, VarType], _),

		nextTempName(Temp1),
		(
			VarType = [array_qual, _, ElemType] ->
			(
				Stmts = [
							[local_var_decl, Temp, ElemType], 
							[local_var_decl, Temp1, 'SIZE'], 
							[move, Temp1, Expr], 
							[arrayIndexing, Temp, Name, Temp1]
						]
			);
			VarType = [vla_qual, _, ElemType] ->
			(
				Type = [union_qual, [[field, val, ElemType], [field, indexOutOfBounds, 'UNIT']]],
				Stmts = [
							[local_var_decl, Temp, Type], 
							[local_var_decl, Temp1, 'SIZE'], 
							[move, Temp1, Expr], 
							[vlaIndexing, Temp, Name, Temp1]
						]
			)
		),

		nextTempName(Temp),
		astSetNode(AST, Loc, [opers, Temp, Rest], AST1),

		append(Pos, [_], Loc),
		astAppendNodes(AST1, Pos, Stmts, AST2),


		lValueStmtalizy(AST2, ResAST)
	);
	% handle deref adr oper
	astNthNode(AST, Loc, [opers, Name, [deref_adr|Rest]]) ->
	(
		astToPrevNode(AST, Loc, [fnBody|_], ResLoc),
		astNthNode(AST, ResLoc, FnBody),
		append(ResLoc, Pos1, Loc),
		astToPrevNode(FnBody, Pos1, [local_var_decl, Name, VarType], _),

		VarType = [adr_qual, Type],
		Stmts = [[local_var_decl, Temp, Type], [derefAdr, Temp, Name]],

		nextTempName(Temp),
		astSetNode(AST, Loc, [opers, Temp, Rest], AST1),

		append(Pos, [_], Loc),
		astAppendNodes(AST1, Pos, Stmts, AST2),


		lValueStmtalizy(AST2, ResAST)
	);
	% handle deref ptr oper
	astNthNode(AST, Loc, [opers, Name, [deref_ptr|Rest]]) ->
	(
		astToPrevNode(AST, Loc, [fnBody|_], ResLoc),
		astNthNode(AST, ResLoc, FnBody),
		append(ResLoc, Pos1, Loc),
		astToPrevNode(FnBody, Pos1, [local_var_decl, Name, VarType], _),

		VarType = [ptr_qual, Type],
		Stmts = [[local_var_decl, Temp, Type], [derefPtr, Temp, Name]],

		nextTempName(Temp),
		astSetNode(AST, Loc, [opers, Temp, Rest], AST1),

		append(Pos, [_], Loc),
		astAppendNodes(AST1, Pos, Stmts, AST2),


		lValueStmtalizy(AST2, ResAST)
	);
	% handle 'handle' oper
	astNthNode(AST, Loc, [opers, Name, [handle|Rest]]) ->
	(
		astToPrevNode(AST, Loc, [fnBody|_], ResLoc),
		astNthNode(AST, ResLoc, FnBody),
		append(ResLoc, Pos1, Loc),
		astToPrevNode(FnBody, Pos1, [local_var_decl, Name, VarType], _),

		VarType = [union_qual, Fields],
		(
			member([field, ID, Type], Fields),
			Field = [field, ID, Type],
			Type \= 'UNIT'
		) ->
		(
			delete(Fields, Field, UnitFields),
			maplist(unitFieldToCase, UnitFields, Cases)
		),
		Temp = ID,
		astSetNode(AST, Loc, [opers, Temp, Rest], AST1),

		append(Pos, [_], Loc),
		append(BlockPos, [_], Pos),
		astNthNode(AST, Pos, Node),
		astNthNode(AST, BlockPos, Block),

		append(BlockPart, [Node|Tl], Block),

		Stmt = 
		[
			[match, 
				[
					[case, ID, 
						[
							[local_var_decl, Temp, Type], 
							[fieldSelect, Temp, Name, ID],
							Node|
							Tl
						]
					]|
					Cases
				]
			]
		],
		append(BlockPart, Stmt, Stmts),
		astSetNode(AST1, BlockPos, Stmts, AST2),


		lValueStmtalizy(AST2, ResAST)
	);
	% swap empty opers for temp var name
	astNthNode(AST, Loc, [opers, Name, []]) ->
	(
		astSetNode(AST, Loc, Name, AST1),


		lValueStmtalizy(AST1, ResAST)
	);
	AST = ResAST.

unitFieldToCase([field, ID, 'UNIT'], [case, ID, [[move_stmt, [expr, [id, '__res__'], [[field_select, ID]]], [arrow, 'LEFT_MOVE'], [expr, unit_const, []]]]]).

