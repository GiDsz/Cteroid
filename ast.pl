
localVar, Name, Type
temp, Name, Type

move, DestName, SrcName
copy, DestName, SrcName
% unionFieldSelect, FieldName, DestName, SrcName, 

match, Arg, [Cases]
case, FieldName, [Stmts]
defaultCase, [Stmts]

cmpStmt, Stmts
if, Cond, Stmts, ElseStmts or [[]]
while, Arg, Stmts
drop, SrcName

globAccess, DestName, LibName, Name

type, IsExported, LibName, Name, Placehldrs, Type 
func, IsExported, LibName, Name, Params, Type, Body
globVar, IsExported, LibName, Name, Type, Stmts