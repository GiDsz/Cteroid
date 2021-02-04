
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

typeOf, Info, Expr