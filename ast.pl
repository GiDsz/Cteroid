
:- module(ast, []).

pathToList(/(Hd, Tl), List) :-
	pathToList(Hd, Res),
	append(Res, [Tl], List).
pathToList(Atom, [Atom]) :-
	atom(Atom).

dictToList(Dict, List) :-
	findall(Value, get_dict(_, Dict, Value), List).

N.getRec([Hd|[]]) := Res :-
	Res = N.get(Hd).
N.getRec([Hd|Tl]) := Res :-
	Tl \= [],
	Node = N.get(Hd),
	Res = Node.getRec(Tl).

N.getRec([Hd|Tl]) := Res :-
	(
		Hd = 'END' ->
		(
			dictToList(N, List),
			length(List, Loc)
		);
		Hd = 'LAST' ->
		(
			dictToList(N, List),
			length(List, Len),
			Loc is Len - 1
		);
		(
			Loc = Hd
		)
	),
	(
		Tl = [] ->
		(
			Res = N.get(Loc)
		);
		(
			Res = N.get(Loc).getRec(Tl)
		)
	).

N.setRec([Hd|Tl], Node) := Res :-
	(
		Hd = 'END' ->
		(
			dictToList(N, List),
			length(List, Loc)
		);
		Hd = 'LAST' ->
		(
			dictToList(N, List),
			length(List, Len),
			Loc is Len - 1
		);
		(
			Loc = Hd
		)
	),
	(
		Tl = [] ->
		(
			Res = N.put(Loc, Node)
		);
		(
			(
				(
					Temp = N.get(Loc), 
					!
				);
				(
					Temp = ast{}
				)
			),
			Res = N.put(Loc, Temp.setRec(Tl, Node))
		)
	).

N.find(Path) := Res :-
	pathToList(Path, List),
	Res = N.getRec(List).

N.add(Path, Node) := Res :-
	pathToList(Path, List),
	Res = N.setRec(List, Node).