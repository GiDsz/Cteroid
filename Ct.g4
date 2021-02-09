grammar Ct;

//Tokens
INT_CONST: [+-]([1-9][0-9]* | '0');
UINT_CONST: ([1-9][0-9]* | '0');
FLOAT_CONST: '-'? [0-9]+ '.' [0-9]+ ([Ee][+-]? [0-9]+)?;
CHAR_CONST:
	'"' ([^"\\\n] | ('\\' (['"?\\abfnrtv] | [a-fA-F0-9]+))) '"';
STR_CONST:
	'"' ([^"\\\n] | ('\\' (['"?\\abfnrtv] | [a-fA-F0-9]+)))+ '"';
BOOL_CONST: ('true' | 'false');

UNIT: '()';
LEFT_COPY: '<~';
LEFT_MOVE: '<-';
LPAREN: '(';
RPAREN: ')';
COLON: ':';
AMPERSAND: '&';
DOLLAR: '$';
QUESTION_MARK: '?';
EXCLAMATION_MARK: '!';
LBRACKET: '[';
RBRACKET: ']';
LBRACE: '{';
RBRACE: '}';
LANGLE_BRACKET: '<';
RANGLE_BRACKET: '>';
APOSTROPHE: '\'';
GRAVE_ACCENT: '`';
COMMA: ',';
RIGHT_MOVE: '->';
ASTERISK: '*';
CARET: '^';
DOT: '.';
DASH: '-';

LIB: 'lib';
FN: 'fn';
TYPE: 'type';
VAR: 'var';

CHAR: 'char';
I8: 'i8';
I16: 'i16';
I32: 'i32';
I64: 'i64';
U8: 'u8';
U16: 'u16';
U32: 'u32';
U64: 'u64';
F32: 'f32';
F64: 'f64';
BOOL: 'bool';
SIZE: 'size';

IF: 'if';
ELSE: 'else';
WHILE: 'while';
MATCH: 'match';

ID: [a-zA-Z_][a-zA-Z_0-9]*;

COMMENT: '//' ~[\r\n]* -> skip;
WS: [ \t\r\n\f]+ -> skip;

//Rules
file_: lib_def+ EOF;
lib_def:
	LIB ID COLON LPAREN exported_items RPAREN LBRACE lib_items RBRACE;
lib_items: lib_item+;
exported_items: (exported_item COMMA?)+;
exported_item: type_decl | fn_decl | glob_var_decl;
lib_item: type_def | fn_def | glob_var_def;

type_decl: TYPE ID;
glob_var_decl: VAR ID;
fn_decl: FN ID;

type_def: TYPE ID placehldr_annot COLON type_spec;
fn_def: FN ID param_annot COLON type_spec fn_body;
glob_var_def: VAR ID COLON type_spec LEFT_MOVE expr;

param_annot: LANGLE_BRACKET params RANGLE_BRACKET |;
params: ((param | param_for_param) COMMA?)+;
placehldr_annot:
	LANGLE_BRACKET (placehldr COMMA?)+ RANGLE_BRACKET
	|;
placehldrs: (placehldr COMMA?)+;

param: APOSTROPHE ID;
param_for_param: APOSTROPHE APOSTROPHE ID;
placehldr: ID;

path: ID (DASH ID)?;

type_spec:
	(
		immut
		| base_type
		| array_qual
		| vla_qual
		| ptr_qual
		| adr_qual
		| struct_qual
		| func_qual
		| immut_func_qual
		| union_qual
		| placehldr
		| typedef
		| param
		| param_for_param
	);
immut: GRAVE_ACCENT type_spec;
base_type: (
		CHAR
		| I8
		| I16
		| I32
		| I64
		| U8
		| U16
		| U32
		| U64
		| F32
		| F64
		| BOOL
		| SIZE
		| UNIT
	);
array_qual: LBRACKET UINT_CONST RBRACKET type_spec;
vla_qual: LBRACKET ID RBRACKET type_spec;
ptr_qual: DOLLAR type_spec;
adr_qual: AMPERSAND type_spec;
struct_qual: LPAREN (field COMMA?)+ RPAREN;
union_qual: LBRACE (field COMMA?)+ RBRACE;
field: ID COLON type_spec;
func_qual: struct_qual RIGHT_MOVE type_spec;
immut_func_qual: struct_qual GRAVE_ACCENT RIGHT_MOVE type_spec;
typedef: path arg_annot;

arg_annot: LANGLE_BRACKET (type_spec COMMA?)+ RANGLE_BRACKET |;

fn_body: LBRACE stmt+ RBRACE;

stmt: (
		local_var_decl
		| local_var_def
		| cmp_stmt
		| if_stmt
		| iter_stmt
		| match_stmt
		| res_stmt
		| move_stmt
		| drop_stmt
		| expr_stmt
	) COMMA?;
local_var_decl: VAR ID COLON type_spec;
local_var_def: VAR ID COLON type_spec arrow expr;
arrow: (LEFT_MOVE | LEFT_COPY handle?);
cmp_stmt: LBRACE stmt+ RBRACE;
if_stmt: IF expr block else_stmt;
else_stmt: ELSE (block | if_stmt) |;
iter_stmt: WHILE expr block;
block: LBRACE stmt* RBRACE;
match_stmt: MATCH expr LBRACE case_+ RBRACE;
case_: ID? COLON stmt*;
res_stmt: designator arrow expr;
move_stmt: expr arrow expr;
drop_stmt: expr RIGHT_MOVE;
expr_stmt: expr;
expr: prim_expr operation*;
prim_expr: (path | ctor);
operation: (
		handle
		| get_adr
		| get_ptr
		| deref_adr
		| deref_ptr
		| indexing
		| field_select
		| fn_call
		| method_call
	);
handle: QUESTION_MARK;
get_adr: AMPERSAND;
get_ptr: DOLLAR;
deref_adr: ASTERISK;
deref_ptr: CARET;
indexing: LBRACKET expr RBRACKET;
field_select: DOT ID;
fn_call: arg_annot struct_ctor;
method_call: EXCLAMATION_MARK expr arg_annot struct_ctor;
ctor: (const_ | struct_ctor | union_ctor | array_ctor);
const_: (
		UINT_CONST
		| INT_CONST
		| FLOAT_CONST
		| CHAR_CONST
		| STR_CONST
		| BOOL_CONST
		| UNIT
	);
struct_ctor: LPAREN ((initer | position_initer) COMMA?)+ RPAREN;
union_ctor: LBRACE ((initer | position_initer) COMMA?)+ RBRACE;
array_ctor:
	LBRACKET ((initer | position_initer) COMMA?)+ RBRACKET;
position_initer: (arrow? expr);
initer: designator arrow expr;
designator: (indexing | field_select | deref_adr | deref_ptr | handle)*;
