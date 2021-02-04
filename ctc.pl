
resVarName('__res__').
validReturnFieldName(res).
stackOverflowErrFieldName(stackOverflow).
outOfMemoryErrFieldName(outOfMemory).
indexOutOfBoundsErrFieldName(indexOutOfBounds).
accessingInactiveUnionMemberErrFieldName(accessingInactiveUnionMember).

nextIndex(Name, Index) :- 
	index(Name, PrevIndex), retract(index(Name, PrevIndex)), Index is PrevIndex + 1, assert(index(Name, Index));
	assert(index(Name, 0)), Index is 0.

desugarFile(File, ResFile) :- maplist(desugarLib, File, ResFile).

desugarLib(Lib, ResLib) :- 
	Lib = [lib_def, Name|RestLib]
	maplist(desugarLibDef, RestLib, ResLib).

desugarLibDef(Arg, Res) :- 
	Arg = [fn_def, Name, Annot, Type, [fn_body|Rest], []] -> 
	(
		desugarStmts(Rest, ResBody),
		append([fn_body], ResBody, Body),
		Res = [fn_def, Name, Annot, Type, Body, []]
	);
	Arg = [fn_def, Name, Type, [fn_body|Rest], []] -> 
	(
		desugarStmts(Rest, ResBody),
		append([fn_body], ResBody, Body),
		Res = [fn_def, Name, Type, Body, []]
	);
	Arg = Res.

desugarStmts([[]], [[]]).
desugarStmts([Hd|Tl], Res1) :- 
(
	Hd = [local_var_def, Name, Type, 'LEFT_MOVE', Expr, []] ->
	(
		desugarExpr(Expr, ResStmts, Result),
		append(ResStmts, [[local_var_def, Name, Type, 'LEFT_MOVE', [Result, []], []]], Res),

		desugarStmts(Tl, Rest),
		append(Res, Rest, Res1)
	);
	Hd = [local_var_def, Name, Type, 'LEFT_COPY', Expr, []] ->
	(
		desugarExpr(Expr, ResStmts, Result),
		append(ResStmts, [[local_var_def, Name, Type, 'LEFT_COPY', [Result, []], []]], Res),

		desugarStmts(Tl, Rest),
		append(Res, Rest, Res1)
	);
	Hd = [local_var_def, Name, Type, 'LEFT_COPY', handle, Expr, []] ->
	(
		desugarExpr(Expr, ResStmts, Result),
		
		desugarStmts(Tl, Rest),
		validReturnFieldName(Name2).
		append([[local_var_def, Name, Type, 'LEFT_COPY', [Result, [field_select, Name2, []], []], []]], Rest, Stmts),
		outOfMemoryErrFieldName(Name1),
		append(ResStmts, [[match_stmt, [Result, []], [case, Name1, [res_stmt, [field_select, Name1, []], 'LEFT_MOVE', [unit_const, []], []], []], [case, Stmts], []]], Res1)
	);
	Hd = [cmp_stmt|Stmts] ->
	(
		desugarStmts(Stmts, ResStmts),

		Res = [cmp_stmt|ResStmts],

		desugarStmts(Tl, Rest),
		append(Res, Rest, Res1)
	);
	Hd = [if_stmt, Expr, CmpStmt, [else_stmt, ElseBlock, []]] ->
	(
		desugarExpr(Expr, ResStmts, Result),
		desugarStmts([CmpStmt, []], [ResCmpStmt, []]),
		desugarStmts([ElseBlock, []], [ResElseBlock, []]),

		append(ResStmts, [[if_stmt, [Result, []], ResCmpStmt, [else_stmt, ResElseBlock, []]]], Res),

		desugarStmts(Tl, Rest),
		append(Res, Rest, Res1)
	);
	Hd = [if_stmt, Expr, CmpStmt, []] ->
	(
		desugarExpr(Expr, ResStmts, Result),
		desugarStmts([CmpStmt, []], [ResCmpStmt, []]),

		append(ResStmts, [[if_stmt, [Result, []], ResCmpStmt, []]]], Res),

		desugarStmts(Tl, Rest),
		append(Res, Rest, Res1)
	);
	Hd = [iter_stmt, Expr, CmpStmt, []] ->
	(
		desugarExpr(Expr, ResStmts, Result),
		desugarStmts([CmpStmt, []], [ResCmpStmt, []]),

		append(ResStmts, [[iter_stmt, [Result, []], ResCmpStmt, []]]], Res),

		desugarStmts(Tl, Rest),
		append(Res, Rest, Res1)
	);
	Hd = [match_stmt, Expr|Cases] ->
	(
		desugarExpr(Expr, ResStmts, Result),
		desugarCases(Cases, ResCases),
		append([match_stmt, [Result, []]], ResCases, Match),
		append(ResStmts, [Match], Res),

		desugarStmts(Tl, Rest),
		append(Res, Rest, Res1)
	);
	Hd = [res_stmt|Rest] ->
	(
		resStmtToMoveStmt(Hd, MoveStmt),
		desugarStmts(MoveStmt, Res),

		desugarStmts(Tl, Rest),
		append(Res, Rest, Res1)
	);
	Hd = [move_stmt, Dest|Rest] ->
	(
		desugarExpr(Dest, ResDest, Result),
		(
			Rest = ['LEFT_MOVE', Src, []] ->
			(
				desugarExpr(Src, ResSrc, Result1),
				append(ResDest, ResSrc, Res2),
				append(Res2, [[move_stmt, [Result, []], 'LEFT_MOVE', [Result1, []], []]], Res),

				desugarStmts(Tl, Rest),
				append(Res, Rest, Res1)
			);
			Rest = ['LEFT_COPY', Src, []] ->
			(
				desugarExpr(Src, ResSrc, Result1),
				append(ResDest, ResSrc, Res2),
				append(Res2, [[move_stmt, [Result, []], 'LEFT_COPY', [Result1, []], []]], Res),

				desugarStmts(Tl, Rest),
				append(Res, Rest, Res1)
			);
			Rest = ['LEFT_COPY', handle, Src, []] ->
			(
				desugarExpr(Src, ResStmts, Result1),

				desugarStmts(Tl, Rest),
				validReturnFieldName(Name2).
				append([[move_stmt, [Result, []], 'LEFT_COPY', [Result1, [field_select, Name2, []], []], []]], Rest, Stmts),
				outOfMemoryErrFieldName(Name1),
				append(ResStmts, [[match_stmt, [Result1, []], [case, Name1, [res_stmt, [field_select, Name1, []], 'LEFT_MOVE', [unit_const, []], []], []], [case, Stmts], []]], Res1)
			)
		)
	);
	Hd = [drop_stmt, Expr, []] ->
	(
		desugarExpr(Expr, ResExpr, Result),
		append(ResExpr, [[drop_stmt, [Result, []], []]], Res),
		desugarStmts(Tl, Rest),
		append(Res, Rest, Res1)
	);
	Hd = Expr ->
	(
		desugarExpr(Expr, ResExpr, Result),
		desugarStmts(Tl, Rest),
		append(ResExpr, Rest, Res1)
	)
).

resStmtToMoveStmt(Tl, Res) :- resStmtToMoveStmtInternal(Tl, [], Res).
resStmtToMoveStmtInternal(Tl, Buffer, Res) :-
	(
		Tl = [res_stmt|Rest] ->
		(
			resStmtToMoveStmtInternal(Rest, Buffer, Res)
		);
		Tl = [deref_adr|Rest] ->
		(
			append(Buffer, [deref_adr], Result),
			resStmtToMoveStmtInternal(Rest, Result, Res)
		);
		Tl = [deref_ptr|Rest] ->
		(
			append(Buffer, [deref_ptr], Result),
			resStmtToMoveStmtInternal(Rest, Result, Res)
		);
		Tl = [[indexing, Expr, []]|Rest] ->
		(
			append(Buffer, [[indexing, Expr, []]], Result),
			resStmtToMoveStmtInternal(Rest, Result, Res)
		);
		Tl = [[field_select, Name, []]|Rest] ->
		(
			append(Buffer, [[field_select, Name, []]], Result),
			resStmtToMoveStmtInternal(Rest, Result, Res)
		);
		(
			resVarName(Name),
			append([Name], Buffer, Res1),
			Res = [move_stmt, Res1|Tl]
		)
	).

desugarCases([[]], [[]]).
desugarCases([[case|Rest]|Tl], [Res|ResRest]) :-
	(
		(
			Rest = [Name|Stmts],
			atom(Name)
		) ->
		(
			desugarStmts(Stmts, ResStmts),
			Res = [case, Name|ResStmts]
		);
		(
			desugarStmts(Rest, ResStmts),
			Res = [case|ResStmts]
		)
	),
	desugarCases(Tl, ResRest).

desugarExpr(Expr, ResStmts, Result) :- 
	(
		(
			Expr = [First|Tl1],
			atom(First)
		) ->
		(
			First = unit_const ->
			(
				Tl1 = Opers,
				nextIndex(temp, ID),
				atomic_concat('_', ID, Name),
				Temp = [[temp, Name], [move_stmt, [Name, []], 'LEFT_MOVE', [unit_const, []], []]],
				desugarOpers(Opers, Name, Stmts, Result),
				append(Temp, Stmts, ResStmts)
			);
			(
				First = LibName,
				Tl1 = [Name|Opers],
				atom(Name),
				Name \= handle,
				Name \= get_adr,
				Name \= get_ptr,
				Name \= deref_adr,
				Name \= deref_ptr
			) ->
			(
%%%%%%%%%%%%%%%%%%%%%%%%
			);
			First = Name ->
			(
				Tl1 = Opers,
%%%%%%%%%%%%%%%%%%%%%%%%
			)
		);
		(
			Expr = [[struct_ctor|Initers]|Opers] ->
			(
				%%%%%%%%%%%%%%
			);
			Expr = [[union_ctor|Initers]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[array_ctor|Initers]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[uint_const, Uint]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[int_const, Int]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[float_const, Float]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[char_const, Char]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[str_const, Str]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[bool_const, Bool]|Opers] ->
			(
				%%%%%%%%%%%%%%
			)
		)
	).

handleOpers([[]], _, Temp, Temp).
handleOpers(Opers, Block, Temp, Res) :-
	(
		Opers = [handle|Rest] ->
		(
			union(Temp, Fields),
			maplist(fieldType, Fields, Types),
			(
				member(OneType, Types),
				\+ unit(OneType) 
			) ->
			(
				Type = OneType
			);
			(
				nextIndex(type_spec, ID1),
				assert(unit(ID1)),
				Type = ID1
			)
			newAllocatedTemp(Block, Type, NextTemp),

			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(match(ID)),
			assert(matchArg(ID, Temp)),
			nextIndex(block, BlockID),
			caseGenForHandle(Fields, NextTemp, Cases),
			handleCases(Cases, BlockID),
			assert(matchCases(ID, BlockID))
		);
		Opers = [get_adr|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [get_ptr|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [deref_adr|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [deref_ptr|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[indexing, Expr, []]|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[field_select, Name, []]|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[fn_call, Annot, StructCtor, []]|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[fn_call, StructCtor, []]|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[method_call|Tl]|Rest] ->
		(
			%%%%%%%%%%%%%%
		)
	),
	handleOpers(Rest, Block, NextTemp, Res).

handleFile(Libs) :- maplist(handleLib, Libs).

handleLib(Lib) :- 
Lib = [];
(
	Lib = [lib_def, Name|RestLib]
	nextIndex(lib, ID), 
	assert(lib(ID, Name)), 
	maplist(handleLibDecl, RestLib, ResLib),
	maplist(handleLibDef, ResLib, Empty),
	maplist(isEmpty, Empty)
).

handleLibDecl(Arg, Res) :- 
	Arg = [type_decl, Name, []] -> 
		(nextIndex(typeAlias, ID), assert(typeAlias(ID)), index(lib, LibID), assert(libOf(ID, LibID)), assert(typeAliasName(ID, Name)), assert(isExported(ID)), Res = []);
	Arg = [fn_decl, Name, []] -> 
		(nextIndex(func, ID), assert(func(ID)), index(lib, LibID), assert(libOf(ID, LibID)), assert(funcName(ID, Name)), assert(isExported(ID)), Res = []);
	Arg = [glob_var_decl, Name, []] -> 
		(nextIndex(globVar, ID), assert(globVar(ID)), index(lib, LibID), assert(libOf(ID, LibID)), assert(globVarName(ID, Name)), assert(isExported(ID)), Res = []);
	Arg = Res.

handleLibDef(Arg, Res) :- 
	Arg = [type_def, Name, Annot, Type, []] -> 
	(
		(
			typeAliasName(ID, Name);
			(
				nextIndex(typeAlias, ID), 
				assert(typeAlias(ID)), 
				index(lib, LibID), 
				assert(libOf(ID, LibID)),
				assert(typeAliasName(ID, Name))
			)
		),
		handlePlacehldrAnnot(Annot, ResAnnot), 
		typeAliasPlacehldrs(ID, ResAnnot),
		handleTypeSpec(Type, ResType), 
		typeAliasType(ID, ResType),
		Res = []
	);
	Arg = [type_def, Name, Type, []] -> 
	(
		(
			typeAliasName(ID, Name);
			(
				nextIndex(typeAlias, ID), 
				assert(typeAlias(ID)), 
				index(lib, LibID), 
				assert(libOf(ID, LibID)),
				assert(typeAliasName(ID, Name))
			)
		),
		handleTypeSpec(Type, ResType), 
		typeAliasType(ID, ResType),
		Res = []
	);
	Arg = [fn_def, Name, Annot, Type, [fn_body|Rest], []] -> 
	(
		(
			funcName(ID, Name);
			(
				nextIndex(func, ID), 
				assert(func(ID)), 
				index(lib, LibID), 
				assert(libOf(ID, LibID)),
				assert(funcName(ID, Name))
			)
		),
		handleParamAnnot(Annot, ResAnnot), 
		funcParams(ID, ResAnnot),
		handleTypeSpec(Type, ResType), 
		funcType(ID, ResType),
		funcQualRetType(ResType, RetType),
		resVarName(ResName),
		nextIndex(block, ResBody),
		handleStmts([[local_var_decl, ResName, RetType]|Rest], ResBody),
		funcBody(ID, ResBody),
		Res = []
	);
	Arg = [fn_def, Name, Type, [fn_body|Rest], []] -> 
	(
		(
			funcName(ID, Name);
			(
				nextIndex(func, ID), 
				assert(func(ID)), 
				index(lib, LibID), 
				assert(libOf(ID, LibID)),
				assert(funcName(ID, Name))
			)
		),
		handleTypeSpec(Type, ResType), 
		funcType(ID, ResType),
		funcQualRetType(ResType, RetType),
		resVarName(ResName),
		nextIndex(block, ResBody),
		handleStmts([[local_var_decl, ResName, RetType]|Rest], ResBody),
		funcBody(ID, ResBody),
		Res = []
	);
	Arg = [glob_var_def, Name, Type, Expr, []] -> 
	(
		(
			globVarName(ID, Name);
			(
				nextIndex(globVar, ID), 
				assert(globVar(ID)), 
				index(lib, LibID), 
				assert(libOf(ID, LibID)),
				assert(globVarName(ID, Name))
			)
		),
		handleTypeSpec(Type, ResType), 
		globVarType(ID, ResType),
		handleGlobExpr(Expr, ResExpr, ResType), 
		globVarExpr(ID, ResExpr),
		Res = []
	);
	Arg = Res.

isEmpty([]).

handlePlacehldrAnnot(Annot, Placehldrs) :-
	Annot = [placehldr_annot|Rest],
	handlePlacehldrs(Rest, Placehldrs).

handlePlacehldrs([[]], []).
handlePlacehldrs([[placehldr, Name, []]|Tl], [Res|Rest]) :- 
	nextIndex(placehldr, ID), 
	assert(placehldr(ID, Name)), 
	Res is ID,
	handlePlacehldrs(Tl, Rest).

handleParamAnnot(Annot, ResAnnot) :-
	Annot = [param_annot|Rest],
	handleParams(Rest, ResAnnot).

handleParams([[]], []).
handleParams([[param, Name, []]|Tl], [Res|Rest]) :- 
	nextIndex(param, ID), 
	assert(param(ID, Name)), 
	Res is ID,
	handleParams(Tl, Rest).
handleParams([[param_for_param, Name, []]|Tl], [Res|Rest]) :- 
	nextIndex(paramForParam, ID), 
	assert(paramForParam(ID, Name)), 
	Res is ID,
	handleParams(Tl, Rest).

handleTypeSpec([immut, Type, []], Res) :-
	handleTypeSpec(Type, ResType),
	assert(immut(ResType)),
	Res = ResType.
handleTypeSpec(['CHAR', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(char(ID)),
	Res = ID.
handleTypeSpec(['I8', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(i8(ID)),
	Res = ID.
handleTypeSpec(['I16', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(i16(ID)),
	Res = ID.
handleTypeSpec(['I32', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(i32(ID)),
	Res = ID.
handleTypeSpec(['I64', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(i64(ID)),
	Res = ID.
handleTypeSpec(['U8', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(u8(ID)),
	Res = ID.
handleTypeSpec(['U16', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(u16(ID)),
	Res = ID.
handleTypeSpec(['U32', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(u32(ID)),
	Res = ID.
handleTypeSpec(['U64', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(u64(ID)),
	Res = ID.
handleTypeSpec(['F32', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(f32(ID)),
	Res = ID.
handleTypeSpec(['F64', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(f64(ID)),
	Res = ID.
handleTypeSpec(['BOOL', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(bool(ID)),
	Res = ID.
handleTypeSpec(['SIZE', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(size(ID)),
	Res = ID.
handleTypeSpec(['UNIT', []], Res) :- 
	nextIndex(type_spec, ID), 
	assert(unit(ID)),
	Res = ID.
handleTypeSpec([array_qual, Length, Type, []], Res) :-
	nextIndex(type_spec, ID), 
	handleTypeSpec(Type, ResType),
	assert(array(ID)),
	assert(lenOfArray(ID, Length)),
	assert(typeOfElemOfArray(ID, ResType)),
	Res = ID.
handleTypeSpec([vla_qual, Length, Type, []], Res) :-
	nextIndex(type_spec, ID), 
	handleTypeSpec(Type, ResType),
	assert(vla(ID)),
	assert(nameOfLenParamOfVla(ID, Length)),
	assert(typeOfElemOfVla(ID, ResType)),
	Res = ID.
handleTypeSpec([ptr_qual, Type, []], Res) :-
	nextIndex(type_spec, ID), 
	handleTypeSpec(Type, ResType),
	assert(ptr(ID, ResType)),
	Res = ID.
handleTypeSpec([adr_qual, Type, []], Res) :-
	nextIndex(type_spec, ID), 
	handleTypeSpec(Type, ResType),
	assert(adr(ID, ResType)),
	Res = ID.
handleTypeSpec([struct_qual, Fields, []], Res) :-
	nextIndex(type_spec, ID), 
	handleFields(Fields, ResFields),
	assert(struct(ID, ResFields)),
	Res = ID.
handleTypeSpec([union_qual, Fields, []], Res) :-
	nextIndex(type_spec, ID), 
	handleFields(Fields, ResFields),
	assert(union(ID, ResFields)),
	Res = ID.
handleTypeSpec([func_qual, Arg, RetType, []], Res) :-
	nextIndex(type_spec, ID), 
	handleTypeSpec(Arg, ResArg),
	handleTypeSpec(RetType, ResRetType),
	assert(funcQual(ID)),
	assert(funcQualArgs(ID, ResArg)),
	assert(funcQualRetType(ID, ResRetType)),
	Res = ID.
handleTypeSpec([placehldr, Name, []], Res) :-
	nextIndex(type_spec, ID), 
	assert(placehldrQual(ID, Name)),
	Res = ID.
handleTypeSpec([param, Name, []], Res) :-
	nextIndex(type_spec, ID), 
	assert(paramQual(ID, Name)),
	Res = ID.
handleTypeSpec([param_for_param, Name, []], Res) :-
	nextIndex(type_spec, ID), 
	assert(paramForParamQual(ID, Name)),
	Res = ID.
handleTypeSpec(Arg, Res) :-
	nextIndex(type_spec, ID), 
	(
		Arg = [typedef, LibName, Name, [arg_annot|Types]] -> 
		(
			assert(typeAliasQualLibName(ID, LibName)),
			maplist(handleTypeSpec, Types, ResTypes),
			assert(typeAliasQualPlacehldrs(ID, ResTypes))
		);
		Arg = [typedef, Name, [arg_annot|Types]] -> 
		(
			maplist(handleTypeSpec, Types, ResTypes),
			assert(typeAliasQualPlacehldrs(ID, ResTypes))
		);
		Arg = [typedef, LibName, Name] -> 
		(
			assert(typeAliasQualLibName(ID, LibName))
		);
		Arg = [typedef, Name]
	),
	assert(typeAliasQual(ID)),
	assert(typeAliasQualName(ID, Name)).

handleFields([[]], []).
handleFields([[field, Name, Type, []]|Rest], [ID|Tl]) :-
	nextIndex(field, ID),
	handleTypeSpec(Type, ResType),
	assert(field(ID)),
	assert(fieldName(ID, Name)),
	assert(fieldType(ID, ResType)),
	handleFields(Rest, Tl).

handleStmts([[]], _).
handleStmts([Hd|Tl], Block) :-
	(
		Hd = [local_var_decl, Name, Type, []] ->
		(
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(varDecl(ID)),
			assert(varDeclName(ID, Name)),
			handleTypeSpec(Type, ResType),
			assert(varDeclType(ID, ResType))
		);
		Hd = [local_var_def, Name, Type|Rest] ->
		(
			handleStmts([[local_var_decl, Name, Type, []], [move_stmt|Rest], []], Block)
		);
		Hd = [cmp_stmt|Stmts] ->
		(
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(cmpStmt(ID)),
			nextIndex(block, BlockID),
			assert(cmpStmtBlock(ID, BlockID)),
			handleStmts(Stmts, BlockID)
		);
		Hd = [if_stmt, Expr, CmpStmt, [else_stmt, ElseBlock, []]] ->
		(
			nextIndex(type_spec, ID1),
			assert(bool(ID1)),
			handleExpr(Expr, Block, ID1, Res), 
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(ifStmt(ID)),
			assert(ifStmtCond(ID, Res)),
			handleStmts(CmpStmt, Block),
			index(block, BlockID),
			assert(ifStmtBlock(ID, BlockID)),
			(
				ElseBlock = [cmp_stmt|Stmts] ->
				(
					nextIndex(block, BlockID),
					handleStmts(Stmts, BlockID),
					assert(ifStmtElseBlock(ID, BlockID))
				);
				ElseBlock = [if_stmt|Rest] ->
				(
					nextIndex(block, BlockID),
					handleStmts(ElseBlock, BlockID),
					assert(ifStmtElseBlock(ID, BlockID))
				)
			),
			assert(ifStmtElseBlock(ID, BlockID))
		);
		Hd = [if_stmt, Expr, CmpStmt, []] ->
		(
			nextIndex(type_spec, ID1),
			assert(bool(ID1)),
			handleExpr(Expr, Block, ID1, Res), 
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(ifStmt(ID)),
			assert(ifStmtCond(ID, Res)),
			nextIndex(block, BlockID),
			CmpStmt = [cmp_stmt|Rest],
			handleStmts(Rest, BlockID),
			assert(ifStmtBlock(ID, BlockID))
		);
		Hd = [iter_stmt, Expr, CmpStmt, []] ->
		(
			nextIndex(type_spec, ID1),
			assert(bool(ID1)),
			handleExpr(Expr, Block, ID1, Res), 
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(while(ID)),
			assert(whileCond(ID, Res)),
			nextIndex(block, BlockID),
			CmpStmt = [cmp_stmt|Rest],
			handleStmts(Rest, BlockID),
			assert(whileBlock(ID, BlockID))
		);
		Hd = [match_stmt, Expr|Cases] ->
		(
			%check that type of Res is union
			handleExprWithoutType(Expr, Block, Res), 

			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(match(ID)),
			assert(matchArg(ID, Res)),
			nextIndex(block, BlockID),
			handleCases(Cases, BlockID),
			assert(matchCases(ID, BlockID)),
		);
		% Hd = [res_stmt|Rest] ->
		% (
		% 	resStmtToMoveStmt(Hd, Res),
		% 	handleStmts(Res, Block)
		% );
		Hd = [move_stmt, Dest|Rest] ->
		(
			handleExprWithoutType(Dest, Block, Res),
			varDeclType(Res, VarType),
			(
				Rest = ['LEFT_MOVE', Src, []] ->
				(
					handleExpr(Src, Block, VarType, Result), 
					nextIndex(op, ID),
					assert(blockOf(ID, Block)),
					assert(move(ID)),
					assert(moveDest(ID, Res)),
					assert(moveSrc(ID, Result))
				);
				Rest = ['LEFT_COPY', Src, []] ->
				(
					handleExpr(Src, Block, VarType, Result), 

					newTemp(Block, VarType, Temp),

					nextIndex(op, ID),
					assert(blockOf(ID, Block)),
					assert(copy(ID)),
					assert(copyDest(ID, Temp)),
					assert(copySrc(ID, Result)),

					nextIndex(op, ID1),
					assert(blockOf(ID1, Block)),
					assert(move(ID1)),
					assert(moveDest(ID1, Res)),
					assert(moveSrc(ID1, Temp))
				)
				% ;
				% Rest = ['LEFT_COPY', handle, Src, []] ->
				% (
				% 	handleExpr(Src, Block, VarType, Result), 

				% 	newTemp(Block, VarType, Temp),

				% 	nextIndex(op, ID),
				% 	assert(blockOf(ID, Block)),
				% 	assert(copy(ID)),
				% 	assert(copyDest(ID, Temp)),
				% 	assert(copySrc(ID, Result)),

				% 	varDeclName(Temp, TempName),
				% 	primExprType([handle], VarType, PrimExprType),
				% 	handleExpr([TempName, handle, []], Block, PrimExprType, Result1), 

				% 	nextIndex(op, ID1),
				% 	assert(blockOf(ID1, Block)),
				% 	assert(move(ID1)),
				% 	assert(moveDest(ID1, Res)),
				% 	assert(moveSrc(ID1, Result1))
				% )
			)
		);
		Hd = [drop_stmt, Expr, []] ->
		(
			handleExprWithoutType(Expr, Block, Res),
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(drop(ID, Res))
		);
		Hd = Expr ->
		(
			handleExprWithoutType(Expr, Block, Res)
		)
	),
	handleStmts(Tl, Block).

% resStmtToMoveStmt(Tl, Res) :- resStmtToMoveStmtInternal(Tl, [], Res).
% resStmtToMoveStmtInternal(Tl, Buffer, Res) :-
% 	(
% 		Tl = [res_stmt|Rest] ->
% 		(
% 			resStmtToMoveStmtInternal(Rest, Buffer, Res)
% 		);
% 		Tl = [deref_adr|Rest] ->
% 		(
% 			append(Buffer, [deref_adr], Result),
% 			resStmtToMoveStmtInternal(Rest, Result, Res)
% 		);
% 		Tl = [deref_ptr|Rest] ->
% 		(
% 			append(Buffer, [deref_ptr], Result),
% 			resStmtToMoveStmtInternal(Rest, Result, Res)
% 		);
% 		Tl = [[indexing, Expr, []]|Rest] ->
% 		(
% 			append(Buffer, [[indexing, Expr, []]], Result),
% 			resStmtToMoveStmtInternal(Rest, Result, Res)
% 		);
% 		Tl = [[field_select, Name, []]|Rest] ->
% 		(
% 			append(Buffer, [[field_select, Name, []]], Result),
% 			resStmtToMoveStmtInternal(Rest, Result, Res)
% 		);
% 		(
% 			resVarName(Name),
% 			append([Name], Buffer, Res1),
% 			Res = [move_stmt, Res1|Tl]
% 		)
% 	).

handleCases([[]], _).
handleCases([[case|Rest]|Tl], Block) :-
	nextIndex(op, ID),
	(
		(
			Rest = [Name|Tl1],
			atom(Name)
		) ->
		(
			assert(blockOf(ID, Block)),
			assert(case(ID)),
			assert(caseArg(ID, Name)),
			nextIndex(block, BlockID),
			assert(caseBlock(ID, BlockID)),
			handleStmts(Tl1, BlockID)
		);
		Rest = Tl1 ->
		(
			assert(blockOf(ID, Block)),
			assert(case(ID)),
			assert(caseDefault(ID)),
			nextIndex(block, BlockID),
			assert(caseBlock(ID, BlockID)),
			handleStmts(Tl1, BlockID)
		)
	),
	handleCases(Tl, Block).

newTemp(Block, Type, ID) :-
	nextIndex(op, ID),
	assert(blockOf(ID, Block)),
	assert(varDecl(ID)),
	atomic_concat('_', ID, Name),
	assert(varDeclName(ID, Name)),
	assert(varDeclType(ID, Type))

handleExpr(Expr, Block, Type, Res) :-
	(
		(
			Expr = [First|Tl1],
			atom(First)
		) ->
		(
			First = unit_const ->
			(
				Tl1 = Opers,
				nextIndex(type_spec, ID),
				assert(unit(ID)),
				newAllocatedTemp(Block, ID, Temp),
				handleOpers(Opers, Block, Temp, Res)
			);
			(
				First = LibName,
				Tl1 = [Name|Opers],
				atom(Name),
				Name \= handle,
				Name \= get_adr,
				Name \= get_ptr,
				Name \= deref_adr,
				Name \= deref_ptr
			) ->
			(
%%%%%%%%%%%%%%%%%%%%%%%%
			);
			First = Name ->
			(
				Tl1 = Opers,
%%%%%%%%%%%%%%%%%%%%%%%%
			)
		);
		(
			Expr = [[struct_ctor|Initers]|Opers] ->
			(
				% primExprType(Opers, Type, PrimExprType),

				% nextIndex(op, ID),
				% assert(blockOf(ID, Block)),
				% assert(varDecl(ID)),
				% atomic_concat('_', ID, Name),
				% assert(varDeclName(ID, Name)),
				% assert(varDeclType(ID, PrimExprType)),

				% nextIndex(op, ID1),
				% assert(blockOf(ID1, Block)),
				% assert(alloc(ID1)),
				% assert(allocDest(ID1, ID)),

				% handleIniters(Initers, ID)
				%%%%%%%%%%%%%%
			);
			Expr = [[union_ctor|Initers]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[array_ctor|Initers]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[uint_const, Uint]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[int_const, Int]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[float_const, Float]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[char_const, Char]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[str_const, Str]|Opers] ->
			(
				%%%%%%%%%%%%%%

			);
			Expr = [[bool_const, Bool]|Opers] ->
			(
				%%%%%%%%%%%%%%

			)
		)
	).

handleOpers([[]], _, Temp, Temp).
handleOpers(Opers, Block, Temp, Res) :-
	(
		Opers = [handle|Rest] ->
		(
			union(Temp, Fields),
			maplist(fieldType, Fields, Types),
			(
				member(OneType, Types),
				\+ unit(OneType) 
			) ->
			(
				Type = OneType
			);
			(
				nextIndex(type_spec, ID1),
				assert(unit(ID1)),
				Type = ID1
			)
			newAllocatedTemp(Block, Type, NextTemp),

			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(match(ID)),
			assert(matchArg(ID, Temp)),
			nextIndex(block, BlockID),
			caseGenForHandle(Fields, NextTemp, Cases),
			handleCases(Cases, BlockID),
			assert(matchCases(ID, BlockID))
		);
		Opers = [get_adr|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [get_ptr|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [deref_adr|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [deref_ptr|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[indexing, Expr, []]|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[field_select, Name, []]|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[fn_call, Annot, StructCtor, []]|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[fn_call, StructCtor, []]|Rest] ->
		(
			%%%%%%%%%%%%%%
		);
		Opers = [[method_call|Tl]|Rest] ->
		(
			%%%%%%%%%%%%%%
		)
	),
	handleOpers(Rest, Block, NextTemp, Res).


newAllocatedTemp(Block, Type, ID) :-
	nextIndex(op, ID),
	assert(blockOf(ID, Block)),
	assert(varDecl(ID)),
	atomic_concat('_', ID, Name),
	assert(varDeclName(ID, Name)),
	assert(varDeclType(ID, Type)),

	nextIndex(op, ID1),
	assert(blockOf(ID1, Block)),
	assert(alloc(ID1)),
	assert(allocDest(ID1, ID))


caseGenForHandle([Field|Fields], Res, [Case|Cases]) :-
	fieldType(Field, Type),
	fieldName(Field, Name),
	(
		unit(Type) ->
		(
			Case = [case, Name, [res_stmt, [field_select, Name, []], LEFT_MOVE, [unit_const, []], []], []]
		);
		(
			atomic_concat('_', Res, Name1),
			Case = [case, Name, [move_stmt, [Name1, []], LEFT_MOVE, [unit_const], []], []]
		)
	)
















		handleGlobExpr(Expr, ResExpr, ResType), 

			handleExprWithoutType(Dest, Block, Res),









primExprType([[]], Type, Type).
primExprType(Opers, Type, PrimExprType) :-
	(
		Opers = [handle|Rest] ->
		(
			union(Type, Fields),
			maplist(fieldType, Fields, Types),
			(
				(
					member(OneType, Types),
					\+ unit(OneType) 
				) ->
				(
					ResType = OneType
				)
			)
		);
		Opers = [get_adr|Rest] ->
		(
			nextIndex(type_spec, ID),
			assert(adr(ID, Type)),
			ResType = ID
		);
		Opers = [get_ptr|Rest] ->
		(
			nextIndex(type_spec, ID),
			assert(ptr(ID, Type)),
			ResType = ID
		);
		Opers = [deref_adr|Rest] ->
		(
			adr(Type, ResType)
		);
		Opers = [deref_ptr|Rest] ->
		(
			ptr(Type, ResType)
		);
		Opers = [[indexing, Expr, []]|Rest] ->
		(
			array(Type) ->
			(
				typeOfElemOfArray(Type, ResType)
			);
			vla(Type) ->
			(
				typeOfElemOfVla(Type, ElemType),

				nextIndex(field, ID1),
				assert(field(ID1)),
				validReturnFieldName(Name1),
				assert(fieldName(ID1, Name1)),
				assert(fieldType(ID1, ElemType)),

				nextIndex(field, ID2),
				assert(field(ID2)),
				indexOutOfBoundsErrFieldName(Name2),
				assert(fieldName(ID2, Name2)),
				nextIndex(type_spec, ID3),
				assert(unit(ID3)),
				assert(fieldType(ID2, ID3)),

				nextIndex(type_spec, ID),
				assert(union(ID, [ID1, ID2])),
				ResType = ID
			)
		);
		Opers = [[field_select, Name, []]|Rest] ->
		(
			struct(Type, Fields) ->
			(
				maplist(fieldName, Fields, Names),
				nth0(Index, Names, Name),
				nth0(Index, Fields, Field),
				fieldType(Field, ResType)
			);
			union(Type, Fields) ->
			(
				maplist(fieldName, Fields, Names),
				nth0(Index, Names, Name),
				nth0(Index, Fields, Field),
				fieldType(Field, ElemType),

				nextIndex(field, ID1),
				assert(field(ID1)),
				validReturnFieldName(Name1),
				assert(fieldName(ID1, Name1)),
				assert(fieldType(ID1, ElemType)),

				nextIndex(field, ID2),
				assert(field(ID2)),
				accessingInactiveUnionMemberErrFieldName(Name2),
				assert(fieldName(ID2, Name2)),
				nextIndex(type_spec, ID3),
				assert(unit(ID3)),
				assert(fieldType(ID2, ID3)),

				nextIndex(type_spec, ID),
				assert(union(ID, [ID1, ID2])),
				ResType = ID
			)			
		);
		Opers = [[fn_call, Annot, StructCtor, []]|Rest] ->
		(
			funcQualRetType(Type, RetType),

			nextIndex(field, ID1),
			assert(field(ID1)),
			fnValidReturnFieldName(Name1),
			assert(fieldName(ID1, Name1)),
			assert(fieldType(ID1, RetType)),

			nextIndex(field, ID2),
			assert(field(ID2)),
			stackOverflowErrFieldName(Name2),
			assert(fieldName(ID2, Name2)),
			nextIndex(type_spec, ID3),
			assert(unit(ID3)),
			assert(fieldType(ID2, ID3)),
			
			nextIndex(type_spec, ID),
			assert(union(ID, [ID1, ID2])),
			ResType = ID
		);
		Opers = [[fn_call, StructCtor, []]|Rest] ->
		(
			funcQualRetType(Type, RetType),

			nextIndex(field, ID1),
			assert(field(ID1)),
			fnValidReturnFieldName(Name1),
			assert(fieldName(ID1, Name1)),
			assert(fieldType(ID1, RetType)),

			nextIndex(field, ID2),
			assert(field(ID2)),
			stackOverflowErrFieldName(Name2),
			assert(fieldName(ID2, Name2)),
			nextIndex(type_spec, ID3),
			assert(unit(ID3)),
			assert(fieldType(ID2, ID3)),
			
			nextIndex(type_spec, ID),
			assert(union(ID, [ID1, ID2])),
			ResType = ID
		);
		Opers = [[method_call|Tl]|Rest] ->
		(
			Tl = [Expr|_],
			Expr = [First, Second|Tl1],
			(
				atom(Second) ->
				(
					First = LibName,
					Second = Name,
					Opers = Tl1
				);
				(
					First = Name,
					index(lib, LibName),
					Opers = [Second|Tl1]
				)
			),

			primExprType(Opers, ResType, PrimExprType),

			funcName(Func, Name),
			libOf(Func, LibName),
			
			handleExprWithoutType(Dest, Block, Res),


			funcQualRetType(Func, RetType),
			nextIndex(field, ID1),
			assert(field(ID1)),
			fnValidReturnFieldName(Name1),
			assert(fieldName(ID1, Name1)),
			assert(fieldType(ID1, RetType)),
			nextIndex(field, ID2),
			assert(field(ID2)),
			stackOverflowErrFieldName(Name2),
			assert(fieldName(ID2, Name2)),
			nextIndex(type_spec, ID3),
			assert(unit(ID3)),
			assert(fieldType(ID2, ID3)),
			nextIndex(type_spec, ID),
			assert(union(ID, [ID1, ID2])),
			ResType = ID
		)
	),
	primExprType(Rest, ResType, PrimExprType).

handleIniters([[]], _).
handleIniters([[initer|Tl]|Rest1], ID) :-
	handleDesignators(Tl, ID, Rest, Result),
	(
		Rest = ['LEFT_MOVE'|Tl1] ->
		(
%%%%%%%%%%%%%%%
		);
		Rest = ['LEFT_COPY'|Tl1] ->
		(
%%%%%%%%%%%%%%%
		)
	),
	handleIniters(Rest1, ID).

handleDesignators([Hd|Tl], ArgID, Rest, Result) :-
	(
		Hd = deref_adr ->
		(
			varDeclType(ArgID, ArgType),
			blockOf(ArgID, Block),
			adr(ArgType, NewType),
			newAllocatedTemp(Block, NewType, Temp),
			
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(derefAdr(ID)),
			assert(derefAdrDest(ID, Temp)),
			assert(derefAdrSrc(ID, ArgID)),

			handleDesignators(Tl, Temp, Rest, Result)
		);
		Hd = deref_ptr ->
		(
			varDeclType(ArgID, ArgType),
			blockOf(ArgID, Block),
			ptr(ArgType, NewType),
			newAllocatedTemp(Block, NewType, Temp),
			
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(derefPtr(ID)),
			assert(derefPtrDest(ID, Temp)),
			assert(derefPtrSrc(ID, ArgID)),

			handleDesignators(Tl, Temp, Rest, Result)
		);
		Hd = [indexing, Expr, []] ->
		(
			blockOf(ArgID, Block),
			nextIndex(type_spec, Type),
			assert(size(Type)),
			handleExpr(Expr, Block, Type, Res),
			
			varDeclType(ArgID, ArgType),
			(
				array(ArgType) -> 
				(
					typeOfElemOfArray(ArgType, NewType)
				);
				vla(ArgType) ->
				(
					typeOfElemOfVla(ArgType, NewType)
				)
			),
			newAllocatedTemp(Block, NewType, Temp),
			
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(indexing(ID)),
			assert(indexingDest(ID, Temp)),
			assert(indexingSrc(ID, ArgID)),
			assert(indexingIndex(ID, Res)),

			handleDesignators(Tl, Temp, Rest, Result)
		);
		Hd = [field_select, Name, []] ->
		(
			blockOf(ArgID, Block),
			varDeclType(ArgID, ArgType),
			(
				struct(ArgType, Fields) -> 
				(
					maplist(fieldName, Fields, Names),
					maplist(fieldType, Fields, Types),
					nth0(Index, Names, Name),
					nth0(Index, Types, NewType)
				);
				union(ArgType, Fields) ->
				(
					maplist(fieldName, Fields, Names),
					maplist(fieldType, Fields, Types),
					nth0(Index, Names, Name),
					nth0(Index, Types, NewType)
				)
			),
			newAllocatedTemp(Block, NewType, Temp),
			
			nextIndex(op, ID),
			assert(blockOf(ID, Block)),
			assert(fieldSelect(ID)),
			assert(fieldSelectDest(ID, Temp)),
			assert(fieldSelectSrc(ID, ArgID)),
			assert(fieldSelectFieldName(ID, Name)),

			handleDesignators(Tl, Temp, Rest, Result)
		);
		(
			Rest = [Hd|Tl],
			Result = ArgID
		)
	).
	





% primExprType(Opers, Type, PrimExprType) :-
% 	(
% 		Opers = [handle|Rest] ->
% 		(
% 			union(Type, Fields),
% 			maplist(fieldType, Fields, Types),
% 			(
% 				(
% 					member(OneType, Types),
% 					\+ unit(OneType) 
% 				) ->
% 				(
% 					ResType = OneType
% 				)
% 			)
% 		);
% 		Opers = [get_adr|Rest] ->
% 		(
% 			nextIndex(type_spec, ID),
% 			assert(adr(ID, Type)),
% 			ResType = ID
% 		);
% 		Opers = [get_ptr|Rest] ->
% 		(
% 			nextIndex(type_spec, ID),
% 			assert(ptr(ID, Type)),
% 			ResType = ID
% 		);
% 		Opers = [deref_adr|Rest] ->
% 		(
% 			adr(Type, ResType)
% 		);
% 		Opers = [deref_ptr|Rest] ->
% 		(
% 			ptr(Type, ResType)
% 		);
% 		Opers = [[indexing, Expr, []]|Rest] ->
% 		(
% 			array(Type) ->
% 			(
% 				typeOfElemOfArray(Type, ResType)
% 			);
% 			vla(Type) ->
% 			(
% 				typeOfElemOfVla(Type, ResType)
% 			)
% 		);
% 		Opers = [[field_select, Name, []]|Rest] ->
% 		(
% 			struct(Type, Fields) ->
% 			(
% 				maplist(fieldName, Fields, Names),
% 				nth0(Index, Names, Name),
% 				nth0(Index, Fields, Field),
% 				fieldType(Field, ResType)
% 			);
% 			union(Type, Fields) ->
% 			(
% 				maplist(fieldName, Fields, Names),
% 				nth0(Index, Names, Name),
% 				nth0(Index, Fields, Field),
% 				fieldType(Field, ResType)
% 			)			
% 		);
% 		Opers = [[fn_call, Annot, StructCtor, []]|Rest] ->
% 		(
% 			funcQualRetType(Type, RetType),

% 			nextIndex(field, ID1),
% 			assert(field(ID1)),
% 			fnValidReturnFieldName(Name1),
% 			assert(fieldName(ID1, Name1)),
% 			assert(fieldType(ID1, RetType)),

% 			nextIndex(field, ID2),
% 			assert(field(ID2)),
% 			stackOverflowErrFieldName(Name2),
% 			assert(fieldName(ID2, Name2)),
% 			nextIndex(type_spec, ID3),
% 			assert(unit(ID3)),
% 			assert(fieldType(ID2, ID3)),
			
% 			nextIndex(type_spec, ID),
% 			assert(union(ID, [ID1, ID2])),
% 			ResType = ID
% 		);
% 		Opers = [[fn_call, StructCtor, []]|Rest] ->
% 		(
% 			funcQualRetType(Type, RetType),

% 			nextIndex(field, ID1),
% 			assert(field(ID1)),
% 			fnValidReturnFieldName(Name1),
% 			assert(fieldName(ID1, Name1)),
% 			assert(fieldType(ID1, RetType)),

% 			nextIndex(field, ID2),
% 			assert(field(ID2)),
% 			stackOverflowErrFieldName(Name2),
% 			assert(fieldName(ID2, Name2)),
% 			nextIndex(type_spec, ID3),
% 			assert(unit(ID3)),
% 			assert(fieldType(ID2, ID3)),
			
% 			nextIndex(type_spec, ID),
% 			assert(union(ID, [ID1, ID2])),
% 			ResType = ID
% 		);
% 		Opers = [[method_call|Tl]|Rest] ->
% 		(
% 			Tl = [First, Second|Tl1],
% 			(
% 				atom(Second) ->
% 				(
% 					First = LibName,
% 					Second = Name,
% 					(
% 						Tl1 = [[arg_annot|Types], [struct_ctor|Initers], []] ->
% 						(
% 							funcName(Func, Name),
% 							libOf(Func, LibName),
							
% 							funcQualRetType(Func, RetType),

% 							nextIndex(field, ID1),
% 							assert(field(ID1)),
% 							fnValidReturnFieldName(Name1),
% 							assert(fieldName(ID1, Name1)),
% 							assert(fieldType(ID1, RetType)),

% 							nextIndex(field, ID2),
% 							assert(field(ID2)),
% 							stackOverflowErrFieldName(Name2),
% 							assert(fieldName(ID2, Name2)),
% 							nextIndex(type_spec, ID3),
% 							assert(unit(ID3)),
% 							assert(fieldType(ID2, ID3)),

% 							nextIndex(type_spec, ID),
% 							assert(union(ID, [ID1, ID2])),
% 							ResType = ID
% 						);
% 						Tl1 = [[struct_ctor|Initers], []] ->
% 						(
% 							%%%%%%%%%%%%%%%%%%5
% 						)
% 					)
% 				);
% 				(
% 					Second = [arg_annot|Types] ->
% 					(
% 						First = Name,
% 						Tl1 = [[struct_ctor|Initers], []],
% 						%%%%%%%%%%%%%
% 					);
% 					Second = [struct_ctor|Initers] ->
% 					(
% 						First = Name,
% 						Tl1 = [[]],
% 						%%%%%%%%%%%%%
% 					)
% 				)
% 			)
% 		);
% 	),
% 	primExprType(Rest, ResType, PrimExprType).