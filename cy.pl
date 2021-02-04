
%location
loc(id, dir, file, startLine, startCol, endLine, endCol).


%libs
root_dir(dir).
root_file(file).

root_lib_decl(loc, name).
root_lib_def(loc, vec).
in_file_lib_def(loc, name).
in_dir_lib_def(dir, name).

err_root_file_lib_decl_and_def(DeclLoc, DefLoc, Name) :- root_lib_decl(DeclLoc, Name), root_lib_def(DefLoc, Name).
err_in_file_lib_redef(Loc1, Loc, Name) :- root_lib_def(Loc1, Name), in_file_lib_def(Loc, Name).
err_in_dir_lib_redef(Dir, Loc, Name) :- in_dir_lib_def(Dir, Name), root_lib_def(Loc, Name).
err_in_dir_lib_redef(Dir, Loc, Name) :- in_dir_lib_def(Dir, Name), in_file_lib_def(Loc, Name).
err_not_declared_in_dir_lib(Dir, Name) :- in_dir_lib_def(Dir, Name), \+ root_lib_decl(_, Name).
err_not_declared_in_file_lib(Loc, Name) :- in_file_lib_def(Loc, Name), \+ root_lib_decl(_, Name).


%lib items
lib_export(loc, lib_name, name).

type_alias(loc, lib, name).
type_alias_placehldrs(loc, lib, name, [a, b, c]).
type_alias_type_spec(loc, lib, name, struct()).

func(loc, lib, name).
func_body(loc, lib, name, [stmt]).
func_type_spec(loc, lib, name, func_qual()).

glob_var(loc, lib, name).
glob_var_type_spec(loc, lib, name, type_spec).
glob_var_value(loc, lib, name, expr).


err_type_alias_without_type_spec(Loc, Lib, Name) :- type_alias(Loc, Lib, Name), \+ type_alias_type_spec(_, Lib, Name, _).
err_multiple_type_alias_placehldrs_annot(Loc, Loc1, Lib, Name) :- type_alias_placehldrs(Loc, Lib, Name, _), type_alias_placehldrs(Loc1, Lib, Name, _), Loc1 \= Loc.
err_multiple_type_alias_type_spec(Loc, Loc1, Lib, Name) :- type_alias_type_spec(Loc, Lib, Name, _), type_alias_type_spec(Loc1, Lib, Name, _), Loc1 \= Loc.
err_unknown_placehldr_in_type_alias(Loc, Lib, Name, Placehldr) :-
    type_alias(_, Lib, Name), 
    type_alias_placehldrs(Loc, Lib, Name, Placehldrs),
    type_alias_type_spec(_, Lib, Name, TypeSpec), 
    placehldr_in_type_spec(Placehldr, TypeSpec),
    \+ member(Placehldr, Placehldrs).
err_unused_placehldr_in_type_alias(Loc, Lib, Name, Placehldr) :- 
    type_alias(_, Lib, Name), 
    type_alias_placehldrs(Loc, Lib, Name, Placehldrs),
    member(Placehldr, Placehldrs),
    type_alias_type_spec(_, Lib, Name, TypeSpec), 
    \+ placehldr_in_type_spec(Placehldr, TypeSpec).

err_func_without_type_spec(Loc, Lib, Name) :- func(Loc, Lib, Name), \+ func_type_spec(_, Lib, Name, _).
err_func_without_body(Loc, Lib, Name) :- func(Loc, Lib, Name), \+ func_body(_, Lib, Name, _).
err_multiple_func_type_spec(Loc, Loc1, Lib, Name) :- func_type_spec(Loc, Lib, Name, _), func_type_spec(Loc1, Lib, Name, _), Loc1 \= Loc.
err_multiple_func_body(Loc, Loc1, Lib, Name) :- func_body(Loc, Lib, Name, _), func_body(Loc1, Lib, Name, _), Loc1 \= Loc.

err_glob_var_without_type_spec(Loc, Lib, Name) :- glob_var(Loc, Lib, Name), \+ glob_var_type_spec(_, Lib, Name, _).
err_glob_var_without_value(Loc, Lib, Name) :- glob_var(Loc, Lib, Name), \+ glob_var_value(_, Lib, Name, _).
err_multiple_glob_var_type_spec(Loc, Loc1, Lib, Name) :- glob_var_type_spec(Loc, Lib, Name, _), glob_var_type_spec(Loc1, Lib, Name, _), Loc1 \= Loc.
err_multiple_glob_var_value(Loc, Loc1, Lib, Name) :- glob_var_value(Loc, Lib, Name, _), glob_var_value(Loc1, Lib, Name, _), Loc1 \= Loc.
err_glob_var_not_immut(Loc, Lib, Name) :- glob_var_type_spec(Loc, Lib, Name, Type), \+ immut_type(Type).
err_glob_var_value_not_pure %IMPL

%type utils
placehldr_in_type_spec(Placehldr, array(_, _, _, TypeSpec)) :- placehldr_in_type_spec(Placehldr, TypeSpec).
placehldr_in_type_spec(Placehldr, vla(_, _, _, TypeSpec)) :- placehldr_in_type_spec(Placehldr, TypeSpec).
placehldr_in_type_spec(Placehldr, ptr(_, _, TypeSpec)) :- placehldr_in_type_spec(Placehldr, TypeSpec).
placehldr_in_type_spec(Placehldr, adr(_, _, TypeSpec)) :- placehldr_in_type_spec(Placehldr, TypeSpec).
placehldr_in_type_spec(Placehldr, struct(_, _, Fields)) :- member(field(_, _, TypeSpec), Fields), placehldr_in_type_spec(Placehldr, TypeSpec).
placehldr_in_type_spec(Placehldr, union(_, _, Fields)) :- member(field(_, _, TypeSpec), Fields), placehldr_in_type_spec(Placehldr, TypeSpec).
placehldr_in_type_spec(Placehldr, typedef_with_placehldrs(_, _, _, _, Types)) :- member(TypeSpec, Types), placehldr_in_type_spec(Placehldr, TypeSpec).
placehldr_in_type_spec(Placehldr, func_qual(_, _, Args, RetType)) :- placehldr_in_type_spec(Placehldr, Args); placehldr_in_type_spec(Placehldr, RetType).
placehldr_in_type_spec(Placehldr, placehldr(_, _, Name)) :- Placehldr = Name.

equal_types(array(_, Mut, Size, Type1), array(_, Mut, Size, Type2)) :- equal_types(Type1, Type2).
equal_types(vla(_, Mut, Name, Type1), vla(_, Mut, Name, Type2)) :- equal_types(Type1, Type2).
equal_types(ptr(_, Mut, Type1), ptr(_, Mut, Type2)) :- equal_types(Type1, Type2).
equal_types(adr(_, Mut, Type1), adr(_, Mut, Type2)) :- equal_types(Type1, Type2).
equal_types(char(_, Mut), char(_, Mut)).
equal_types(i8(_, Mut), i8(_, Mut)).
equal_types(i16(_, Mut), i16(_, Mut)).
equal_types(i32(_, Mut), i32(_, Mut)).
equal_types(i64(_, Mut), i64(_, Mut)).
equal_types(u8(_, Mut), u8(_, Mut)).
equal_types(u16(_, Mut), u16(_, Mut)).
equal_types(u32(_, Mut), u32(_, Mut)).
equal_types(u64(_, Mut), u64(_, Mut)).
equal_types(f32(_, Mut), f32(_, Mut)).
equal_types(f64(_, Mut), f64(_, Mut)).
equal_types(bool(_, Mut), bool(_, Mut)).
equal_types(size(_, Mut), size(_, Mut)).
equal_types(unit(_, Mut), unit(_, Mut)).
equal_types(struct(_, Mut, Fields1), struct(_, Mut, Fields2)) :- merge_to_map(Fields1, Fields2, Pairs), fields_equal(Pairs).
equal_types(union(_, Mut, Fields1), union(_, Mut, Fields2)) :- merge_to_map(Fields1, Fields2, Pairs), fields_equal(Pairs).
equal_types(typedef(_, Mut, Lib, Name), typedef(_, Mut, Lib, Name)).
equal_types(typedef_with_placehldrs(_, Mut, Lib, Name, Types1), typedef_with_placehldrs(_, Mut, Lib, Name, Types2)) :- list_of_equal_types(Types1, Types2).	
equal_types(param(_, Mut, Name), param(_, Mut, Name)).
equal_types(param_for_param(_, Mut, Name), param_for_param(_, Mut, Name)).
equal_types(placehldr(_, Mut, Name), placehldr(_, Mut, Name)).
equal_types(func_qual(_, Mut, Args1, RetType1), func_qual(_, Mut, Args2, RetType2)) :- equal_types(Args1, Args2), equal_types(RetType1, RetType2).

fields_equal([]).
fields_equal([[field(_, Name, Type1)|field(_, Name, Type2)]|Tl]) :- equal_types(Type1, Type2), fields_equal(Tl).

list_of_equal_types([], []).
list_of_equal_types([Hd1|Tl1], [Hd2|Tl2]) :- equal_types(Hd1, Hd2), list_of_equal_types(Tl1, Tl2).

immut_type(array(_, immut, _, Type) :- immut_type(Type).
immut_type(vla(_, immut, _, Type) :- immut_type(Type).
immut_type(ptr(_, immut, Type) :- immut_type(Type).
immut_type(adr(_, immut, Type) :- immut_type(Type).
immut_type(char(_, immut).
immut_type(i8(_, immut).
immut_type(i16(_, immut).
immut_type(i32(_, immut).
immut_type(i64(_, immut).
immut_type(u8(_, immut).
immut_type(u16(_, immut).
immut_type(u32(_, immut).
immut_type(u64(_, immut).
immut_type(f32(_, immut).
immut_type(f64(_, immut).
immut_type(bool(_, immut).
immut_type(size(_, immut).
immut_type(unit(_, immut).
immut_type(struct(_, immut, Fields) :- fields_immut(Fields).
immut_type(union(_, immut, Fields) :- fields_immut(Fields).
immut_type(typedef(_, immut, Lib, Name) :- type_alias_type_spec(_, Lib, Name, Type), immut_type(Type).
immut_type(typedef_with_placehldrs(_, immut, Lib, Name, _) :- type_alias_type_spec(_, Lib, Name, Type), immut_type(Type).
immut_type(param(_, immut, _).
immut_type(param_for_param(_, immut, _).
immut_type(placehldr(_, immut, _).
immut_type(func_qual(_, immut, _, _).

fields_immut([]).
fields_immut([field(_, _, Type)|Tl]) :- immut_type(Type), fields_immut(Tl).

%list utils
member(Elem, [Elem|Tl]).
member(Elem, [Hd|Tl]) :- member(Elem, Tl).

merge_to_map([], [], []).
merge_to_map([Hd1|Tl1], [Hd2|Tl2], [[Hd1|Hd2]|ResTl]) :- merge_to_map(Tl1, Tl2, ResTl).

%type_spec
array(loc, mut, 2 (size), type_of_elem).
vla(loc, mut, len (name of param), type_of_elem).
ptr(loc, mut, type_of_elem).
adr(loc, mut, type_of_elem).
char(loc, mut).
i8(loc, mut).
i16(loc, mut).
i32(loc, mut).
i64(loc, mut).
u8(loc, mut).
u16(loc, mut).
u32(loc, mut).
u64(loc, mut).
f32(loc, mut).
f64(loc, mut).
bool(loc, mut).
size(loc, mut).
unit(loc, mut).
struct(loc, mut, [fields]).
union(loc, mut, [fields]).
typedef(loc, mut, lib, name).
typedef_with_placehldrs(loc, mut, lib, name, [type_of_placehldrs]).
param(loc, mut, '\'a' (name) ). 
param_for_param(loc, mut, '\'\'a' (name) ). % param unifies to param; use only in func type spec
placehldr(loc, mut, a (name) ).
func_qual(loc, mut, struct(), ret_type).

field(loc, name, type_of_elem).

err_unknown_type_alias(Loc, Lib, Name) :- typedef(Loc, _, Lib, Name), \+ type_alias(_, Lib, Name).
err_type_alias_without_placehldrs_used_with_placehldrs(Loc, Lib, Name) :- typedef_with_placehldrs(Loc, _, Lib, Name), type_alias(_, Lib, Name), \+ type_alias_placehldrs(_, Lib, Name, _).
err_unknown_type_alias_with_placehldrs(Loc, Lib, Name) :- typedef_with_placehldrs(Loc, _, Lib, Name), \+ type_alias(_, Lib, Name).
err_type_alias_with_placehldrs_used_without_placehldrs(Loc, Lib, Name) :- typedef(Loc, _, Lib, Name), type_alias(_, Lib, Name), type_alias_placehldrs(_, Lib, Name, _).


%main
main_func(loc, name).
main_func_body(loc, name, [stmt]).
main_func_type_spec(loc, name, func_qual()).

err_invalid_main_func_type(Loc, Name) :-
	main_func_type_spec(Loc, Name, TypeSpec),
    \+ equal_types
    (
        func_qual
        (
            loc, 
            mut, 
            struct
            (
                loc, 
                mut, 
                [
                    field
                    (
                        loc, 
                        arg_len, 
                        size
                        (
                            loc, 
                            immut
                        )
                    ), 
                    field
                    (
                        loc, 
                        args, 
                        adr
                        (
                            loc, 
                            mut, 
                            vla
                            (
                                loc, 
                                mut, 
                                argc, 
                                adr
                                (
                                    loc, 
                                    mut, 
                                    typedef
                                    (
                                        loc, 
                                        immut, 
                                        'C', 
                                        'Str'
                                    )
                                )
                            )
                        )
                    )
                ]
            ),
            unit
			(
				loc,
				mut
			)
        ), %(argc: `size, argv: &[argc]&`C-Str) -> ()
		TypeSpec
    )
. 


%stmt
var_decl(loc, name, type).
var_def(loc, name, type, arrow(handler), expr).
block(loc, [stmt]).
ifs(loc, [branch(cond|[stmt])]).
while(loc, cond, [stmt]).
match(loc, cond, [case(name, [stmt])]).
res_stmt(expr, arrow(handler), expr).
move_stmt(expr, arrow(handler), expr).
drop_stmt(expr).
fail_stmt(code).

get_loc(var_decl(Loc, _, _), Loc).
get_loc(var_decl(Loc, _, _, _, _), Loc).
get_loc(block(Loc, _), Loc).
get_loc(ifs(Loc, _), Loc).
get_loc(while(Loc, _, _), Loc).
get_loc(match(Loc, _, _), Loc).
get_loc(res_stmt(Loc, _, _, _), Loc).
get_loc(move_stmt(Loc, _, _, _), Loc).
get_loc(drop_stmt(Loc, _), Loc).
get_loc(fail_stmt(Loc, _), Loc).

%expr
expr(prim, [oper]).
prim:
    uint_const(loc, 123).
    int_const(loc, -123).
    float_const(loc, 1.0).
    char_const(loc, a).
    str_const(loc, 'as').
    bool_const(loc, false).
    unit_const(loc).

    struct_ctor(loc, [initer(expr, arrow, expr)], handler).
    union_ctor(loc, [initer(expr, arrow, expr)], handler).
    array_ctor(loc, [initer(expr, arrow, expr)], handler).

    path(loc, lib, name).
    var(loc, name).
oper:
    get_adr(loc).
    get_ptr(loc).
    deref_adr(loc).
    deref_ptr(loc).
    indexing(loc, index_expr, handler).
    field_select(loc, name, handler).
    fn_call(loc, struct_ctor(args), handler).

%check this
err_local_var_name_collide_with_arg_name

%ir
fn_ir(Loc, Lib, Name, IR) :- func_body(Loc, Lib, Name, Stmts), func_type_spec(_, Lib, Name, func_qual(Loc1, _, _, RetType)), simplify_stmts([var_decl(Loc1, '__res__', RetType)|Stmts], SStmts).

simplify_stmts(Stmts, SStmts) :- simplify_stmts(Stmts, SStmts, 0, _).

%stmt ir
simplify_stmts([], [], Temp, Temp).

simplify_stmts([var_decl(Loc, Name, Type)|Tl], [Op|Rest], Temp, ResTemp) :- Op = var_decl(Loc, Name, Type), simplify_stmts(Tl, Rest, Temp, ResTemp).

simplify_stmts([var_def(Loc, Name, Type, move(Loc1), Expr)|Tl], [Op|Rest], Temp, ResTemp1) :- 
    simplify_expr(Expr, Ops, Temp, ResTemp), 
    append([var_decl(Loc, Name, Type)|Ops], [move(Loc1, Name, ResTemp)], Op),
    NextTemp is ResTemp + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp1).
simplify_stmts([var_def(Loc, Name, Type, copy(Loc1, Handler), Expr)|Tl], [Op|Rest], Temp, ResTemp3) :- 
    simplify_expr(Expr, Ops, Temp, ResTemp), 
    Temp1 is ResTemp + 1,
    Err is Temp1 + 1,
    Temp2 is Err + 1,
    simplify_handler(Handler, Err, SHandler, Temp2, ResTemp2), 
    append([copy(Loc1, Temp1, Err, ResTemp)|SHandler], [move(Loc1, Name, Temp1)], List),
    append([var_decl(Loc, Name, Type)|Ops], List, Op),
    NextTemp is ResTemp2 + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp3).

simplify_stmts([block(Loc, Stmts)|Tl], [Op|Rest], Temp, ResTemp1) :- 
    simplify_stmts(Stmts, Res, Temp, ResTemp),
    Op = block(Loc, Res),
    NextTemp is ResTemp + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp1).

simplify_stmts([ifs(Loc, Branches)|Tl], [Op|Rest], Temp, ResTemp1) :- 
    simplify_branches(Branches, SBrs, Temp, ResTemp), 
    Op = block(Loc, SBrs),
    NextTemp is ResTemp + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp1).

simplify_stmts([while(Loc, Cond, Stmts)|Tl], [Op|Rest], Temp, ResTemp2) :- 
    simplify_expr(Cond, Ops, Temp, ResTemp), 
    Temp1 is ResTemp + 1,
    simplify_stmts(Stmts, Res, Temp1, ResTemp1),
    append(Ops, [while(Loc, ResTemp, Res)], Op),
    NextTemp is ResTemp1 + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp2).

simplify_stmts([match(Loc, Expr, Cases)|Tl], [Op|Rest], Temp, ResTemp2) :- 
    simplify_expr(Expr, Ops, Temp, ResTemp), 
    Temp1 is ResTemp + 1,
    simplify_cases(Cases, Res, Temp1, ResTemp1),
    append(Ops, [match(Loc, ResTemp, Res)], Op),
    NextTemp is ResTemp1 + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp2).

simplify_stmts([res_stmt(Loc, expr(_, Opers), move(Loc1), Expr)|Tl], [Op|Rest], Temp, ResTemp2) :- 
    simplify_expr(expr(var(Loc, '__res__'), Opers), Ops, Temp, ResTemp), 
    Temp1 is ResTemp + 1,
    simplify_expr(Expr, Ops1, Temp1, ResTemp1), 
    append(Ops, Ops1, Op1),
    append(Op1, [move(Loc1, ResTemp, ResTemp1)], Op),
    NextTemp is ResTemp1 + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp2).
simplify_stmts([res_stmt(Loc, expr(_, Opers), copy(Loc1, Handler), Expr)|Tl], [Op|Rest], Temp, ResTemp4) :- 
    simplify_expr(expr(var(Loc, '__res__'), Opers), Ops, Temp, ResTemp), 
    Temp1 is ResTemp + 1,
    simplify_expr(Expr, Ops1, Temp1, ResTemp1), 
    Err is ResTemp1 + 1,
    Temp2 is Err + 1,
    Temp3 is Temp2 + 1,
    simplify_handler(Handler, Err, SHandler, Temp3, ResTemp3), 
    append(Ops, Ops1, Op1),
    append([copy(Loc1, Temp2, Err, ResTemp1)|SHandler], [move(Loc1, ResTemp, Temp2)], List),
    append(Op1, List, Op),
    NextTemp is ResTemp3 + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp4).

simplify_stmts([move_stmt(Loc, Expr, move(Loc1), Expr1)|Tl], [Op|Rest], Temp, ResTemp4) :- 
    simplify_expr(Expr, Ops, Temp, ResTemp), 
    Temp1 is ResTemp + 1,
    simplify_expr(Expr1, Ops1, Temp1, ResTemp1), 
    append(Ops, Ops1, Op1),
    append(Op1, [move(Loc1, ResTemp, ResTemp1)], Op),
    NextTemp is ResTemp1 + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp4).
simplify_stmts([move_stmt(Loc, Expr, copy(Loc1, Handler), Expr1)|Tl], [Op|Rest], Temp, ResTemp4) :- 
    simplify_expr(Expr, Ops, Temp, ResTemp), 
    Temp1 is ResTemp + 1,
    simplify_expr(Expr1, Ops1, Temp1, ResTemp1), 
    Err is ResTemp1 + 1,
    Temp2 is Err + 1,
    Temp3 is Temp2 + 1,
    simplify_handler(Handler, Err, SHandler, Temp3, ResTemp3), 
    append(Ops, Ops1, Op1),
    append([copy(Loc1, Temp2, Err, ResTemp1)|SHandler], [move(Loc1, ResTemp, Temp2)], List),
    append(Op1, List, Op),
    NextTemp is ResTemp3 + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp4).

simplify_stmts([drop_stmt(Loc, Expr)|Tl], [Op|Rest], Temp, ResTemp3) :- 
    simplify_expr(Expr, Ops, Temp, ResTemp), 
    Op = drop(Loc, ResTemp),
    NextTemp is ResTemp + 1,
    simplify_stmts(Tl, Rest, NextTemp, ResTemp3).
    
simplify_stmts([fail_stmt(Loc, Code)|Tl], [Op|Rest], Temp, ResTemp3) :- 
    Op = fail(Loc, Code),
    simplify_stmts(Tl, Rest, Temp, ResTemp3).

simplify_handler(none, _, [], Temp, Temp).
simplify_handler(handler(Loc, Cases), Err, SHandler, Temp, ResTemp) :-
    simplify_cases(Cases, Res, Temp, ResTemp),
    SHandler = match(Loc, Err, Res).

simplify_branches([], [], Temp, Temp).
simplify_branches([branch(Loc, Cond, Stmts)|Tl], Result, Temp, ResTemp3) :-
    simplify_expr(Cond, SCond, Temp, ResTemp),
    Temp1 is ResTemp + 1,
    simplify_stmts(Stmts, SStmts, Temp1, ResTemp1),
    Br = branch(Loc, ResTemp, SStmts),
    append(SCond, [Br|Rest], Result),
    NextTemp is ResTemp1 + 1,
    simplify_branches(Tl, Rest, NextTemp, ResTemp3).

simplify_cases([], [], Temp, Temp).
simplify_cases([case(Loc, ID, Stmts)|Tl], [Case|Rest], Temp, ResTemp3) :-
    simplify_stmts(Stmts, SStmts, Temp, ResTemp),
    Case = case(Loc, ID, SStmts),
    NextTemp is ResTemp + 1,
    simplify_cases(Tl, Rest, NextTemp, ResTemp3).

%expr ir
simplify_expr(expr(Prim, Opers), Ops, Temp, ResTemp2) :-
    simplify_prim(Prim, SPrim, Temp, ResTemp),
    simplify_opers(Opers, SOpers, ResTemp, ResTemp2),
    append(SPrim, SOpers, Ops).

simplify_prim(uint_const(Loc, Val), SPrim, Temp, ResTemp) :-
    SPrim = [alloc(Loc, Temp, 8), assign(Loc, Temp, Val)],
    ResTemp is Temp + 1.

simplify_prim(int_const(Loc, Val), SPrim, Temp, ResTemp) :-
    SPrim = [alloc(Loc, Temp, 8), assign(Loc, Temp, Val)],
    ResTemp is Temp + 1.

% simplify_prim(float_const(Loc, Val), SPrim, Temp, ResTemp) :-
%     SPrim = [alloc(Loc, Temp, 8), assign(Loc, Temp, Val)],
%     ResTemp is Temp + 1.

simplify_prim(char_const(Loc, Val), SPrim, Temp, ResTemp) :-
    SPrim = [alloc(Loc, Temp, 8), assign(Loc, Temp, Val)],
    ResTemp is Temp + 1.

simplify_prim(str_const(Loc, Val), SPrim, Temp, ResTemp) :-
    SPrim = [alloc(Loc, Temp, strsize(Val)), memcopy(Loc, Temp, Val, strsize(Val))],
    ResTemp is Temp + 1.

simplify_prim(bool_const(Loc, Val), SPrim, Temp, ResTemp) :-
    SPrim = [alloc(Loc, Temp, 1), assign(Loc, Temp, Val)],
    ResTemp is Temp + 1.

simplify_prim(unit_const(Loc, Val), SPrim, Temp, Temp) :-
    SPrim = [].

