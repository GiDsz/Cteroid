
localVar, Info, Name, Type
temp, Info, Name, Type

move, Info, DestName, SrcName
copy, Info, DestName, SrcName
% unionFieldSelect, Info, FieldName, DestName, SrcName, 

match, Info, Arg, [Cases]
case, Info, FieldName, [Stmts]
defaultCase, Info, [Stmts]

cmpStmt, Info, Stmts
if, Info, Cond, Stmts, ElseStmts or [[]]
while, Info, Arg, Stmts
drop, Info, SrcName

type, Info, IsExported, LibName, Name, Placehldrs, Type 
func, Info, IsExported, LibName, Name, Params, Type, Body
globVar, Info, IsExported, LibName, Name, Type, Stmts