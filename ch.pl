
nextIndex(Name, Index) :- 
	index(Name, PrevIndex), retract(index(Name, PrevIndex)), Index is PrevIndex + 1, assert(index(Name, Index));
	assert(index(Name, 0)), Index is 0.

nextTempName(Name) :-
	nextIndex('__temp__', ID),
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



astSimplify(AST, ResAST) :-
	astNthNode(AST, Loc, [immut_func_qual, Info|Rest]) ->
	(
		astSetNode(AST, Loc, [immut, Info [func_qual, Info|Rest]], AST1),


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [fn_body, Info, Stmts|_]) ->
	(
		append(RestInd, [LastInd], Loc),
		TypeInd is LastInd - 1,
		append(RestInd, [TypeInd], TypeLoc),

		astNthNode(AST, TypeLoc, FnType),
		astNthNode(FnType, _, [func_qual, Info1, Arg, RetType]),

		astSetNode(AST, Loc, [fn_body, Info, [[local_var_decl, Info1, '__res__', RetType]|Stmts]], AST1),


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [local_var_decl, Info, Name, Type|_]) ->
	(
		astSetNode(AST, Loc, [localVar, Info, Name, Type], AST1),


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [local_var_def, Info, Name, Type, [arrow, Info1, 'LEFT_MOVE'|_], Expr|_]) ->
	(
		astSetNode(AST, Loc, [localVar, Info, Name, Type], AST1),
		
		append(RestInd, [LastInd], Loc),
		Ind is LastInd + 1,
		append(RestInd, [Ind], InsertLoc),

		astInsertNode(AST1, InsertLoc, [move, Info1, Name, Expr], AST2),


		astSimplify(AST2, ResAST)
	);
	astNthNode(AST, Loc, [local_var_def, Info, Name, Type, [arrow, Info1, 'LEFT_COPY', handle|_], Expr|_]) ->
	(
		astSetNode(AST, Loc, [localVar, Info, Name, Type], AST1),

		append(RestInd, [LastInd], Loc),
		Ind is LastInd + 1,
		append(RestInd, [Ind], InsertLoc),

		nextTempName(Temp),

		astInsertNode(AST1, InsertLoc, [move, Info1, Name, [[id, Info1, Temp, []], handle, []]], AST2),
		astInsertNode(AST2, InsertLoc, [copy, Info1, Temp, Expr], AST3),
		astInsertNode(AST3, InsertLoc, [temp, Info1, Temp, [union, Info1, [[field, Info1, res, Type], [field, Info1, outOfMemory, [unit, Info1]]]], AST4),


		astSimplify(AST4, ResAST)
	);
	astNthNode(AST, Loc, [local_var_def, Info, Name, Type, [arrow, Info1, 'LEFT_COPY'|_], Expr|_]) ->
	(
		astSetNode(AST, Loc, [localVar, Info, Name, Type], AST1),
		
		append(RestInd, [LastInd], Loc),
		Ind is LastInd + 1,
		append(RestInd, [Ind], InsertLoc),

		nextTempName(Temp),

		astInsertNode(AST1, InsertLoc, [move, Info1, Name, Temp], AST2),
		astInsertNode(AST2, InsertLoc, [copy, Info1, Temp, Expr], AST3),
		astInsertNode(AST3, InsertLoc, [temp, Info1, Temp, Type], AST4),


		astSimplify(AST4, ResAST)
	);
	astNthNode(AST, Loc, [cmp_stmt, Info, Stmts|_]) ->
	(
		astSetNode(AST, Loc, [cmpStmt, Info, Stmts], AST1),


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [if_stmt, Info, Expr, [cmpStmt, Info1, Stmts|_], MayBeElse|_]) ->
	(
		(
			MayBeElse = [cmpStmt, Info2, Stmts1] ->
			(
				astSetNode(AST, Loc, [if, Info, Expr, Stmts, Stmts1], AST1)
			);
			(
				astSetNode(AST, Loc, [if, Info, Expr, Stmts, [MayBeElse]], AST1)
			)
		),


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [iter_stmt, Info, Expr, [cmpStmt, Info1, Stmts|_]|_]) ->
	(
		astSetNode(AST, Loc, [while, Info, Expr, Stmts], AST1),


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [match_stmt, Info, Expr, Cases|_]) ->
	(
		removeEmpties(Cases, Cases1),
		maplist(simplifyCase, Cases1, ResCases),
		astSetNode(AST, Loc, [match, Info, Expr, ResCases], AST1),


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [res_stmt, Info, Desig, Arrow, Expr|_]) ->
	(
		astSetNode(AST, Loc, [move_stmt, Info, [expr, [id, Info, '__res__', []], ResDesig, []], Arrow, Expr], AST1),


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [move_stmt, Info, Expr, [arrow, Info1, 'LEFT_MOVE'|_], Expr1|_]) ->
	(
		astSetNode(AST, Loc, [move, Info, Expr, Expr1], AST1),


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [move_stmt, Info, Expr, [arrow, Info1, 'LEFT_COPY', handle|_], Expr1|_]) ->
	(
		nextTempName(Temp),

		astSetNode(AST, Loc, [move, Info, Expr, [expr, Info1, [id, Info1, Temp, []], handle, []]], AST2),

		astSimplify(Expr, ResExpr),
		append(_, [TempVar, _], ResExpr),
		TempVar = [temp, _, _, Type],

		astInsertNode(AST2, Loc, [copy, Info1, Temp, Expr1], AST3),
		astInsertNode(AST3, Loc, [temp, Info1, Temp, [union, Info1, [[field, Info1, res, Type], [field, Info1, outOfMemory, [unit, Info1]]]], AST4),


		astSimplify(AST4, ResAST)
	);
	astNthNode(AST, Loc, [move_stmt, Info, Expr, [arrow, Info1, 'LEFT_COPY'|_], Expr1|_]) ->
	(
		nextTempName(Temp),

		astSetNode(AST, Loc, [move, Info, Expr, Temp, AST2),

		astSimplify(Expr, ResExpr),
		append(_, [TempVar, _], ResExpr),
		TempVar = [temp, _, _, Type],

		astInsertNode(AST2, Loc, [copy, Info1, Temp, Expr1], AST3),
		astInsertNode(AST3, Loc, [temp, Info1, Temp, Type], AST4),


		astSimplify(AST4, ResAST)
	);
	astNthNode(AST, Loc, [drop_stmt, Info, Expr|_]) ->
	(
		astSetNode(AST, Loc, [drop, Info, Expr], AST1),


		astSimplify(AST1, ResAST)
	);

	%add match access to field

	astNthNode(AST, Loc, [expr, Info, Prim, Opers|_]) ->
	(
		append(_, [Pos, _], Loc),
		
		(
			Prim = [path, PathInfo, LibName, Name|_] ->
			(
				astNthNode(AST, ItemLoc, [func, ItemInfo, true, LibName, Name, _, Type|_]) ->
				(
					
				);
				astNthNode(AST, ItemLoc, [globVar, ItemInfo, true, LibName, Name, _, Type|_]) ->
				(

				)
				%astInsertNode(AST, Pos, [copy, Info1, Temp, Expr1], AST1)
			);
		)


		astSimplify(AST1, ResAST)
	);
	astNthNode(AST, Loc, [expr_stmt, Info, Expr|[]]) ->
	(
		%%%%%%%%
	);
	(AST = ResAST).

simplifyCase([case, Info, [[]], Stmts|_], [defaultCase, Info, Stmts]).
simplifyCase([case, Info, [id, Info1, Name], Stmts|_], [case, Info, Name, Stmts]).



removeEmpties([], []).
removeEmpties([[]|Tl], Tl1) :- removeEmpties(Tl, Tl1).
removeEmpties([Hd|Tl], [Hd|Tl1]) :- removeEmpties(Tl, Tl1).
