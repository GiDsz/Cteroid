
:- module(ast, []).

pathToList(/(Hd, Tl), List) :-
	pathToList(Hd, Res),
	append(Res, [Tl], List).
pathToList(Atom, [Atom]) :-
	atom(Atom).

N.getRec([Hd|[]]) := Res :-
	Res = N.get(Hd).
N.getRec([Hd|Tl]) := Res :-
	Node = N.get(Hd),
	Res = Node.getRec(Tl).

N.find(Path) := Res :-
	pathToList(Path, List),
	Res = N.getRec(List).

valid(Node) :-
	\+ (_ = Node.get(errors)).

invalid(Node) :-
	_ = Node.get(errors).