
:- dynamic file/1.

lex(File, Tokens) :-
	open(File, read, Stream),
	assert(file(File)),
	readStream(Stream, String),
	tokenize(Tokens, String, []).

readStream(Stream, Str) :-
	readStreamImpl(Stream, Str, 0, 0).

readStreamImpl(Stream, Str, Line, Column) :-
	get_char(Stream, Char),
	(
		Char = end_of_file ->
		(
			close(Stream),
			Str = []
		);
		Char = '\n' ->
		(
			NL is Line + 1,
			Str = [[Char, NL, 0]|Rest],
			readStreamImpl(Stream, Rest, NL, 1)
		);
		(
			NC is Column + 1,
			Str = [[Char, Line, Column]|Rest],
			readStreamImpl(Stream, Rest, Line, NC)
		)
	).

tokenize([], [], []).
tokenize(Res) -->
	(
		(
			floatConst(Token1);
			intConst(Token1);
			uintConst(Token1);
			charConst(Token1);
			strConst(Token1);
			boolConst(Token1);
			symbol(Token1);
			keyword(Token1);
			id(Token1)
		),
		!,
		{toToken(Token1, Token)},
		{Res = [Token|Rest]},
		tokenize(Rest)
	);
	(
		(
			ws;
			comment
		),
		!,
		tokenize(Res)
	).

toToken(List, Token) :-
	List = [Tag, Value, SL, SC, EL, EC],
	file(File),
	Token = [Tag, Value, File, SL, SC, EL, EC].

intConst([int_const, [Sign|Num], SL, SC, EL, EC]) -->
	sign([Sign, SL, SC]),
	(
		zero([Num, EL, EC]);
		natural([Num, _, _, EL, EC])
	).

sign([Sign, L, C]) -->
	[[Sign, L, C]],
	{
		Sign = '+';
		Sign = '-'
	}.

zero(['0', L, C]) -->
	[['0', L, C]].
	
natural([[Digit|Tl], L, C, EL, EC]) -->
	[[Digit, L, C]],
	{
		Digit = '1';
		Digit = '2';
		Digit = '3';
		Digit = '4';
		Digit = '5';
		Digit = '6';
		Digit = '7';
		Digit = '8';
		Digit = '9'
	},
	(
		digits(Tl, _, _, EL, EC);
		(
			{
				EL = L,
				EC = C,
				Tl =[]
			}
		)
	).

digits([Digit|Tl], SL, SC, EL, EC) -->
	[[Digit, SL, SC]],
	{
		Digit = '0';
		Digit = '1';
		Digit = '2';
		Digit = '3';
		Digit = '4';
		Digit = '5';
		Digit = '6';
		Digit = '7';
		Digit = '8';
		Digit = '9'
	},
	(
		digits(Tl, _, _, EL, EC);
		(
			{
				EL = SL,
				EC = SC,
				Tl =[]
			}
		)
	).

uintConst([uint_const, Num, L, C, L, C]) -->
	zero([Num, L, C]).
	
uintConst([uint_const, Num, SL, SC, EL, EC]) -->
	natural([Num, SL, SC, EL, EC]).

floatConst([float_const, ['-'|Tl], SL, SC, EL, EC]) -->
	[['-', SL, SC]],
	(
		zero([Num, _, _]);
		natural([Num|_])
	),
	[['.', _, _]],
	{append(Num, ['.'|Num1], Num2)},
	natural([Num1|_]),
	{append(Num2, Pow, Tl)},
	power([Pow, _, _, EL, EC]).
	
floatConst([float_const, Tl, SL, SC, EL, EC]) -->
	(
		zero([Num, SL, SC]);
		natural([Num, SL, SC|_])
	),
	[['.', _, _]],
	{append(Num, ['.'|Num1], Num2)},
	natural([Num1|_]),
	{append(Num2, Pow, Tl)},
	power([Pow, _, _, EL, EC]).

floatConst([float_const, ['-'|Tl], SL, SC, EL, EC]) -->
	[['-', SL, SC]],
	(
		zero([Num, _, _]);
		natural([Num|_])
	),
	[['.', _, _]],
	{append(Num, ['.'|Num1], Tl)},
	natural([Num1, _, _, EL, EC]).

floatConst([float_const, Tl, SL, SC, EL, EC]) -->
	(
		zero([Num, SL, SC]);
		natural([Num, SL, SC|_])
	),
	[['.', _, _]],
	{append(Num, ['.'|Num1], Tl)},
	natural([Num1, _, _, EL, EC]).

power([['e'|Num], SL, SC, EL, EC]) -->
	(
		[['e', SL, SC]];
		[['E', SL, SC]]
	),
	number([Num, _, _, EL, EC]).

number([[Digit|Tl], SL, SC, EL, EC]) -->
	[[Digit, SL, SC]],
	{
		Digit = '+';
		Digit = '-';
		Digit = '1';
		Digit = '2';
		Digit = '3';
		Digit = '4';
		Digit = '5';
		Digit = '6';
		Digit = '7';
		Digit = '8';
		Digit = '9'
	},
	digits(Tl, _, _, EL, EC).

charConst([char_const, Char, SL, SC, EL, EC]) -->
	[['"', SL, SC]],
	char([Char|_]),
	[['"', EL, EC]].

char([Char, L, C, EL, EC]) -->
	(
		[['"', L, C]];
		[['\n', L, C]]
	) ->
	(
		{fail}
	);
	(
		[['\\', L, C]]
	) ->
	(
		(
			(
				[[Chars, EL, EC]],
				{
					Chars = '\'';
					Chars = '\"';
					Chars = 'a';
					Chars = 'b';
					Chars = 'f';
					Chars = 'n';
					Chars = 'r';
					Chars = 't';
					Chars = 'v'
				}
			);
			hexDigits(Chars, _, _, EL, EC)
		),
		{Char = ['\\'|Chars]}
	);
	(
		[[Char, L, C]],
		{
			L = EL,
			C = EC
		}
	).

hexDigits([Digit|Tl], SL, SC, EL, EC) -->
	[[Digit, SL, SC]],
	{
		Digit = '0';
		Digit = '1';
		Digit = '2';
		Digit = '3';
		Digit = '4';
		Digit = '5';
		Digit = '6';
		Digit = '7';
		Digit = '8';
		Digit = '9';
		Digit = 'a';
		Digit = 'b';
		Digit = 'c';
		Digit = 'd';
		Digit = 'e';
		Digit = 'f';
		Digit = 'A';
		Digit = 'B';
		Digit = 'C';
		Digit = 'D';
		Digit = 'E';
		Digit = 'F'
	},
	(
		hexDigits(Tl, _, _, EL, EC);
		(
			{
				EL = SL,
				EC = SC,
				Tl =[]
			}
		)
	).

strConst([str_const, Chars, SL, SC, EL, EC]) -->
	[['"', SL, SC]],
	chars(Chars, _, _, _, _),
	[['"', EL, EC]].

chars([Char|Tl], SL, SC, EL, EC) -->
	char([Char, SL, SC, L, C]),
	(
		chars(Tl, _, _, EL, EC);
		(
			{
				EL = L,
				EC = C,
				Tl =[]
			}
		)
	).

boolConst([bool_const, ['t', 'r', 'u', 'e'], SL, SC, EL, EC]) -->
	[['t', SL, SC]],
	[['r', _, _]],
	[['u', _, _]],
	[['e', EL, EC]].

boolConst([bool_const, ['f', 'a', 'l', 's', 'e'], SL, SC, EL, EC]) -->
	[['f', SL, SC]],
	[['a', _, _]],
	[['l', _, _]],
	[['s', _, _]],
	[['e', EL, EC]].

symbol([unit, 0, SL, SC, EL, EC]) -->
	[['(', SL, SC]],
	[[')', EL, EC]].
symbol([left_copy, 0, SL, SC, EL, EC]) -->
	[['<', SL, SC]],
	[['~', EL, EC]].
symbol([left_move, 0, SL, SC, EL, EC]) -->
	[['<', SL, SC]],
	[['-', EL, EC]].
symbol([right_move, 0, SL, SC, EL, EC]) -->
	[['-', SL, SC]],
	[['>', EL, EC]].
symbol([lparen, 0, L, C, L, C]) -->
	[['(', L, C]].
symbol([rparen, 0, L, C, L, C]) -->
	[[')', L, C]].
symbol([colon, 0, L, C, L, C]) -->
	[[':', L, C]].
symbol([ampersand, 0, L, C, L, C]) -->
	[['&', L, C]].
symbol([dollar, 0, L, C, L, C]) -->
	[['$', L, C]].
symbol([question_mark, 0, L, C, L, C]) -->
	[['?', L, C]].
symbol([lbracket, 0, L, C, L, C]) -->
	[['[', L, C]].
symbol([rbracket, 0, L, C, L, C]) -->
	[[']', L, C]].
symbol([lbrace, 0, L, C, L, C]) -->
	[['{', L, C]].
symbol([rbrace, 0, L, C, L, C]) -->
	[['}', L, C]].
symbol([langle_bracket, 0, L, C, L, C]) -->
	[['<', L, C]].
symbol([rangle_bracket, 0, L, C, L, C]) -->
	[['>', L, C]].
symbol([apostrophe, 0, L, C, L, C]) -->
	[['\'', L, C]].
symbol([grave_accent, 0, L, C, L, C]) -->
	[['`', L, C]].
symbol([comma, 0, L, C, L, C]) -->
	[[',', L, C]].
symbol([asterisk, 0, L, C, L, C]) -->
	[['*', L, C]].
symbol([caret, 0, L, C, L, C]) -->
	[['^', L, C]].
symbol([dot, 0, L, C, L, C]) -->
	[['.', L, C]].
symbol([dash, 0, L, C, L, C]) -->
	[['-', L, C]].

keyword([bool_const, ['t', 'r', 'u', 'e'], SL, SC, EL, EC]) -->
	[['t', SL, SC]],
	[['r', _, _]],
	[['u', _, _]],
	[['e', EL, EC]].

keyword([import, ['i', 'm', 'p', 'o', 'r', 't'], SL, SC, EL, EC]) -->
	[['i', SL, SC]],
	[['m', _, _]],
	[['p', _, _]],
	[['o', _, _]],
	[['r', _, _]],
	[['t', EL, EC]].

keyword([lib, ['l', 'i', 'b'], SL, SC, EL, EC]) -->
	[['l', SL, SC]],
	[['i', _, _]],
	[['b', EL, EC]].

keyword([fn, ['f', 'n'], SL, SC, EL, EC]) -->
	[['f', SL, SC]],
	[['n', EL, EC]].

keyword([type, ['t', 'y', 'p', 'e'], SL, SC, EL, EC]) -->
	[['t', SL, SC]],
	[['y', _, _]],
	[['p', _, _]],
	[['e', EL, EC]].

keyword([var, ['v', 'a', 'r'], SL, SC, EL, EC]) -->
	[['v', SL, SC]],
	[['a', _, _]],
	[['r', EL, EC]].
	
keyword([char, ['c', 'h', 'a', 'r'], SL, SC, EL, EC]) -->
	[['c', SL, SC]],
	[['h', _, _]],
	[['a', _, _]],
	[['r', EL, EC]].

keyword([i8, ['i', '8'], SL, SC, EL, EC]) -->
	[['i', SL, SC]],
	[['8', EL, EC]].

keyword([i16, ['i', '1', '6'], SL, SC, EL, EC]) -->
	[['i', SL, SC]],
	[['1', _, _]],
	[['6', EL, EC]].
	
keyword([i32, ['i', '3', '2'], SL, SC, EL, EC]) -->
	[['i', SL, SC]],
	[['3', _, _]],
	[['2', EL, EC]].

keyword([i64, ['i', '6', '4'], SL, SC, EL, EC]) -->
	[['i', SL, SC]],
	[['6', _, _]],
	[['4', EL, EC]].

keyword([u8, ['u', '8'], SL, SC, EL, EC]) -->
	[['u', SL, SC]],
	[['8', EL, EC]].

keyword([u16, ['u', '1', '6'], SL, SC, EL, EC]) -->
	[['u', SL, SC]],
	[['1', _, _]],
	[['6', EL, EC]].
	
keyword([u32, ['u', '3', '2'], SL, SC, EL, EC]) -->
	[['u', SL, SC]],
	[['3', _, _]],
	[['2', EL, EC]].

keyword([u64, ['u', '6', '4'], SL, SC, EL, EC]) -->
	[['u', SL, SC]],
	[['6', _, _]],
	[['4', EL, EC]].
	
keyword([f32, ['f', '3', '2'], SL, SC, EL, EC]) -->
	[['f', SL, SC]],
	[['3', _, _]],
	[['2', EL, EC]].

keyword([f64, ['f', '6', '4'], SL, SC, EL, EC]) -->
	[['f', SL, SC]],
	[['6', _, _]],
	[['4', EL, EC]].
	
keyword([bool, ['b', 'o', 'o', 'l'], SL, SC, EL, EC]) -->
	[['b', SL, SC]],
	[['o', _, _]],
	[['o', _, _]],
	[['l', EL, EC]].

keyword([size, ['s', 'i', 'z', 'e'], SL, SC, EL, EC]) -->
	[['s', SL, SC]],
	[['i', _, _]],
	[['z', _, _]],
	[['e', EL, EC]].

keyword([if, ['i', 'f'], SL, SC, EL, EC]) -->
	[['i', SL, SC]],
	[['f', EL, EC]].

keyword([else, ['e', 'l', 's', 'e'], SL, SC, EL, EC]) -->
	[['e', SL, SC]],
	[['l', _, _]],
	[['s', _, _]],
	[['e', EL, EC]].

keyword([while, ['w', 'h', 'i', 'l', 'e'], SL, SC, EL, EC]) -->
	[['w', SL, SC]],
	[['h', _, _]],
	[['i', _, _]],
	[['l', _, _]],
	[['e', EL, EC]].

keyword([match, ['m', 'a', 't', 'c', 'h'], SL, SC, EL, EC]) -->
	[['m', SL, SC]],
	[['a', _, _]],
	[['t', _, _]],
	[['c', _, _]],
	[['h', EL, EC]].

id([id, [Char|Tl], L, C, EL, EC]) -->
	[[Char, L, C]],
	{
		char_type(Char, alpha);
		Char = '_';
		Char = '1';
		Char = '2';
		Char = '3';
		Char = '4';
		Char = '5';
		Char = '6';
		Char = '7';
		Char = '8';
		Char = '9'
	},
	(
		idTl(Tl, _, _, EL, EC);
		(
			{
				EL = L,
				EC = C,
				Tl =[]
			}
		)
	).

idTl([Char|Tl], SL, SC, EL, EC) -->
	[[Char, SL, SC]],
	{
		char_type(Char, alnum);
		Char = '_'
	},
	(
		idTl(Tl, _, _, EL, EC);
		(
			{
				EL = SL,
				EC = SC,
				Tl =[]
			}
		)
	).

comment -->
	[['/'|_]],
	[['/'|_]],
	commentBody.

commentBody -->
	[[Char|_]],
	(
		{Char = '\n'};
		commentBody
	).

ws -->
	[[' '|_]];
	[['\t'|_]];
	[['\r'|_]];
	[['\n'|_]];
	[['\f'|_]].
