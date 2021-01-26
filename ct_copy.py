import sys
from antlr4 import *
from CtLexer import CtLexer
from CtParser import CtParser
from CtListener import CtListener

 
class Analyzer(CtListener):

    # Enter a parse tree produced by CtParser#file_.
    def enterFile_(self, ctx:CtParser.File_Context):
        print("  ",end="")

    # Exit a parse tree produced by CtParser#file_.
    def exitFile_(self, ctx:CtParser.File_Context):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#fn_def.
    def enterFn_def(self, ctx:CtParser.Fn_defContext):
        print(" ( fn_def " ,end="")

    # Exit a parse tree produced by CtParser#fn_def.
    def exitFn_def(self, ctx:CtParser.Fn_defContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#type_def.
    def enterType_def(self, ctx:CtParser.Type_defContext):
        print(" ( type_def "+ctx.ID().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#type_def.
    def exitType_def(self, ctx:CtParser.Type_defContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#param_annot.
    def enterParam_annot(self, ctx:CtParser.Param_annotContext):
        print(" ( param_annot " ,end="")

    # Exit a parse tree produced by CtParser#param_annot.
    def exitParam_annot(self, ctx:CtParser.Param_annotContext):
        print(" ) " ,end="")

    # Enter a parse tree produced by CtParser#placehldr_annot.
    def enterPlacehldr_annot(self, ctx:CtParser.Placehldr_annotContext):
        print(" ( placehldr_annot " ,end="")

    # Exit a parse tree produced by CtParser#placehldr_annot.
    def exitPlacehldr_annot(self, ctx:CtParser.Placehldr_annotContext):
        print(" ) " ,end="")

    # Enter a parse tree produced by CtParser#param.
    def enterParam(self, ctx:CtParser.ParamContext):
        print(" ( param "+ctx.ID().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#param.
    def exitParam(self, ctx:CtParser.ParamContext):
        print(" ) " ,end="")

    # Enter a parse tree produced by CtParser#placehldr.
    def enterPlacehldr(self, ctx:CtParser.PlacehldrContext):
        print(" ( placehldr "+ctx.ID().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#placehldr.
    def exitPlacehldr(self, ctx:CtParser.PlacehldrContext):
        print(" ) " ,end="")

    # Enter a parse tree produced by CtParser#param_for_param.
    def enterParam_for_param(self, ctx:CtParser.Param_for_paramContext):
        print(" ( param_for_param "+ctx.ID().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#param_for_param.
    def exitParam_for_param(self, ctx:CtParser.Param_for_paramContext):
        print(" ) " ,end="")

    # Enter a parse tree produced by CtParser#type_spec.
    def enterType_spec(self, ctx:CtParser.Type_specContext):
        pass

    # Exit a parse tree produced by CtParser#type_spec.
    def exitType_spec(self, ctx:CtParser.Type_specContext):
        pass


    # Enter a parse tree produced by CtParser#base_type.
    def enterBase_type(self, ctx:CtParser.Base_typeContext):
        print(" "+CtLexer.symbolicNames[ctx.getChild(0).getSymbol().type]+" " ,end="")

    # Exit a parse tree produced by CtParser#base_type.
    def exitBase_type(self, ctx:CtParser.Base_typeContext):
        pass


    # Enter a parse tree produced by CtParser#array_qual.
    def enterArray_qual(self, ctx:CtParser.Array_qualContext):
        print(" ( array_qual "+ctx.UINT_CONST().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#array_qual.
    def exitArray_qual(self, ctx:CtParser.Array_qualContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#vla_qual.
    def enterVla_qual(self, ctx:CtParser.Vla_qualContext):
        print(" ( vla_qual "+ctx.ID().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#vla_qual.
    def exitVla_qual(self, ctx:CtParser.Vla_qualContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#ptr_qual.
    def enterPtr_qual(self, ctx:CtParser.Ptr_qualContext):
        print(" ( ptr_qual " ,end="")

    # Exit a parse tree produced by CtParser#ptr_qual.
    def exitPtr_qual(self, ctx:CtParser.Ptr_qualContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#adr_qual.
    def enterAdr_qual(self, ctx:CtParser.Adr_qualContext):
        print(" ( adr_qual " ,end="")

    # Exit a parse tree produced by CtParser#adr_qual.
    def exitAdr_qual(self, ctx:CtParser.Adr_qualContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#struct_qual.
    def enterStruct_qual(self, ctx:CtParser.Struct_qualContext):
        print(" ( struct_qual " ,end="")

    # Exit a parse tree produced by CtParser#struct_qual.
    def exitStruct_qual(self, ctx:CtParser.Struct_qualContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#field.
    def enterField(self, ctx:CtParser.FieldContext):
        print(" ( field "+ctx.ID().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#field.
    def exitField(self, ctx:CtParser.FieldContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#func_qual.
    def enterFunc_qual(self, ctx:CtParser.Func_qualContext):
        print(" ( func_qual " ,end="")

    # Exit a parse tree produced by CtParser#func_qual.
    def exitFunc_qual(self, ctx:CtParser.Func_qualContext):
        print(" ) " ,end="")

    # Enter a parse tree produced by CtParser#union_qual.
    def enterUnion_qual(self, ctx:CtParser.Union_qualContext):
        print(" ( union_qual " ,end="")

    # Exit a parse tree produced by CtParser#union_qual.
    def exitUnion_qual(self, ctx:CtParser.Union_qualContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#fn_body.
    def enterFn_body(self, ctx:CtParser.Fn_bodyContext):
        print(" ( fn_body " ,end="")

    # Exit a parse tree produced by CtParser#fn_body.
    def exitFn_body(self, ctx:CtParser.Fn_bodyContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#stmt.
    def enterStmt(self, ctx:CtParser.StmtContext):
        pass

    # Exit a parse tree produced by CtParser#stmt.
    def exitStmt(self, ctx:CtParser.StmtContext):
        pass


    # Enter a parse tree produced by CtParser#cmp_stmt.
    def enterCmp_stmt(self, ctx:CtParser.Cmp_stmtContext):
        print(" ( cmp_stmt ",end="")

    # Exit a parse tree produced by CtParser#cmp_stmt.
    def exitCmp_stmt(self, ctx:CtParser.Cmp_stmtContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#if_stmt.
    def enterIf_stmt(self, ctx:CtParser.If_stmtContext):
        print(" ( if_stmt ",end="")

    # Exit a parse tree produced by CtParser#if_stmt.
    def exitIf_stmt(self, ctx:CtParser.If_stmtContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#else_stmt.
    def enterElse_stmt(self, ctx:CtParser.Else_stmtContext):
        print(" ( else_stmt ",end="")

    # Exit a parse tree produced by CtParser#else_stmt.
    def exitElse_stmt(self, ctx:CtParser.Else_stmtContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#iter_stmt.
    def enterIter_stmt(self, ctx:CtParser.Iter_stmtContext):
        print(" ( iter_stmt ",end="")

    # Exit a parse tree produced by CtParser#iter_stmt.
    def exitIter_stmt(self, ctx:CtParser.Iter_stmtContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#res_stmt.
    def enterRes_stmt(self, ctx:CtParser.Res_stmtContext):
        print(" ( res_stmt ",end="")

    # Exit a parse tree produced by CtParser#res_stmt.
    def exitRes_stmt(self, ctx:CtParser.Res_stmtContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#move_stmt.
    def enterMove_stmt(self, ctx:CtParser.Move_stmtContext):
        print(" ( move_stmt ",end="")

    # Exit a parse tree produced by CtParser#move_stmt.
    def exitMove_stmt(self, ctx:CtParser.Move_stmtContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#drop_stmt.
    def enterDrop_stmt(self, ctx:CtParser.Drop_stmtContext):
        print(" ( drop_stmt ",end="")

    # Exit a parse tree produced by CtParser#drop_stmt.
    def exitDrop_stmt(self, ctx:CtParser.Drop_stmtContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#arrow.
    def enterArrow(self, ctx:CtParser.ArrowContext):
        if ctx.LEFT_MOVE() != None:
            print(" LEFT_MOVE " ,end="")
        else:
            print(" LEFT_COPY " ,end="")

    # Exit a parse tree produced by CtParser#arrow.
    def exitArrow(self, ctx:CtParser.ArrowContext):
        pass


    # Enter a parse tree produced by CtParser#expr.
    def enterExpr(self, ctx:CtParser.ExprContext):
        print(" ( ",end="")

    # Exit a parse tree produced by CtParser#expr.
    def exitExpr(self, ctx:CtParser.ExprContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#prim_expr.
    def enterPrim_expr(self, ctx:CtParser.Prim_exprContext):
        pass

    # Exit a parse tree produced by CtParser#prim_expr.
    def exitPrim_expr(self, ctx:CtParser.Prim_exprContext):
        pass


    # Enter a parse tree produced by CtParser#operation.
    def enterOperation(self, ctx:CtParser.OperationContext):
        pass

    # Exit a parse tree produced by CtParser#operation.
    def exitOperation(self, ctx:CtParser.OperationContext):
        pass


    # Enter a parse tree produced by CtParser#get_adr.
    def enterGet_adr(self, ctx:CtParser.Get_adrContext):
        print(" get_adr " ,end="")

    # Exit a parse tree produced by CtParser#get_adr.
    def exitGet_adr(self, ctx:CtParser.Get_adrContext):
        pass


    # Enter a parse tree produced by CtParser#get_ptr.
    def enterGet_ptr(self, ctx:CtParser.Get_ptrContext):
        print(" get_ptr " ,end="")

    # Exit a parse tree produced by CtParser#get_ptr.
    def exitGet_ptr(self, ctx:CtParser.Get_ptrContext):
        pass


    # Enter a parse tree produced by CtParser#deref_adr.
    def enterDeref_adr(self, ctx:CtParser.Deref_adrContext):
        print(" deref_adr " ,end="")

    # Exit a parse tree produced by CtParser#deref_adr.
    def exitDeref_adr(self, ctx:CtParser.Deref_adrContext):
        pass


    # Enter a parse tree produced by CtParser#deref_ptr.
    def enterDeref_ptr(self, ctx:CtParser.Deref_ptrContext):
        print(" deref_ptr " ,end="")

    # Exit a parse tree produced by CtParser#deref_ptr.
    def exitDeref_ptr(self, ctx:CtParser.Deref_ptrContext):
        pass


    # Enter a parse tree produced by CtParser#indexing.
    def enterIndexing(self, ctx:CtParser.IndexingContext):
        print(" ( indexing " ,end="")

    # Exit a parse tree produced by CtParser#indexing.
    def exitIndexing(self, ctx:CtParser.IndexingContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#field_select.
    def enterField_select(self, ctx:CtParser.Field_selectContext):
        print(" ( field_select "+ctx.ID().getText() ,end=" ")

    # Exit a parse tree produced by CtParser#field_select.
    def exitField_select(self, ctx:CtParser.Field_selectContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#fn_call.
    def enterFn_call(self, ctx:CtParser.Fn_callContext):
        print(" ( fn_call " ,end="")

    # Exit a parse tree produced by CtParser#fn_call.
    def exitFn_call(self, ctx:CtParser.Fn_callContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#method_call.
    def enterMethod_call(self, ctx:CtParser.Method_callContext):
        print(" ( method_call " ,end="")

    # Exit a parse tree produced by CtParser#method_call.
    def exitMethod_call(self, ctx:CtParser.Method_callContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#arg_annot.
    def enterArg_annot(self, ctx:CtParser.Arg_annotContext):
        print(" ( arg_annot " ,end="")

    # Exit a parse tree produced by CtParser#arg_annot.
    def exitArg_annot(self, ctx:CtParser.Arg_annotContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#ctor.
    def enterCtor(self, ctx:CtParser.CtorContext):
        pass

    # Exit a parse tree produced by CtParser#ctor.
    def exiCtor(self, ctx:CtParser.CtorContext):
        pass


    # Enter a parse tree produced by CtParser#const_.
    def enterConst_(self, ctx:CtParser.Const_Context):
        if ctx.UNIT() != None:
            print(" unit_const " ,end="")
        elif ctx.BOOL_CONST() != None:
            print(" ( bool_const "+ctx.getChild(0).getText()+" ) " ,end="")
        elif ctx.STR_CONST() != None:
            print(" ( str_const "+ctx.getChild(0).getText()+" ) " ,end="")
        elif ctx.CHAR_CONST() != None:
            print(" ( char_const "+ctx.getChild(0).getText()+" ) " ,end="")
        elif ctx.FLOAT_CONST() != None:
            print(" ( float_const "+ctx.getChild(0).getText()+" ) " ,end="")
        elif ctx.INT_CONST() != None:
            print(" ( int_const "+ctx.getChild(0).getText()+" ) " ,end="")
        elif ctx.UINT_CONST() != None:
            print(" ( uint_const "+ctx.getChild(0).getText()+" ) " ,end="")

    # Exit a parse tree produced by CtParser#const_.
    def exitConst_(self, ctx:CtParser.Const_Context):
        pass


    # Enter a parse tree produced by CtParser#struct_ctor.
    def enterStruct_ctor(self, ctx:CtParser.Struct_ctorContext):
        print(" ( struct_ctor " ,end="")

    # Exit a parse tree produced by CtParser#struct_ctor.
    def exitStruct_ctor(self, ctx:CtParser.Struct_ctorContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#union_ctor.
    def enterUnion_ctor(self, ctx:CtParser.Union_ctorContext):
        print(" ( union_ctor " ,end="")

    # Exit a parse tree produced by CtParser#union_ctor.
    def exitUnion_ctor(self, ctx:CtParser.Union_ctorContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#array_ctor.
    def enterArray_ctor(self, ctx:CtParser.Array_ctorContext):
        print(" ( array_ctor " ,end="")

    # Exit a parse tree produced by CtParser#array_ctor.
    def exitArray_ctor(self, ctx:CtParser.Array_ctorContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#initer.
    def enterIniter(self, ctx:CtParser.IniterContext):
        print(" ( initer " ,end="")
        if ctx.arrow() == None:
            print(" LEFT_MOVE " ,end="")

    # Exit a parse tree produced by CtParser#initer.
    def exitIniter(self, ctx:CtParser.IniterContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#designator.
    def enterDesignator(self, ctx:CtParser.DesignatorContext):
        pass

    # Exit a parse tree produced by CtParser#designator.
    def exitDesignator(self, ctx:CtParser.DesignatorContext):
        pass

    # Enter a parse tree produced by CtParser#lib_def.
    def enterLib_def(self, ctx:CtParser.Lib_defContext):
        print(" lib( " ,end="")

    # Exit a parse tree produced by CtParser#lib_def.
    def exitLib_def(self, ctx:CtParser.Lib_defContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#exported_item.
    def enterExported_item(self, ctx:CtParser.Exported_itemContext):
        pass

    # Exit a parse tree produced by CtParser#exported_item.
    def exitExported_item(self, ctx:CtParser.Exported_itemContext):
        pass


    # Enter a parse tree produced by CtParser#lib_item.
    def enterLib_item(self, ctx:CtParser.Lib_itemContext):
        pass

    # Exit a parse tree produced by CtParser#lib_item.
    def exitLib_item(self, ctx:CtParser.Lib_itemContext):
        pass


    # Enter a parse tree produced by CtParser#glob_var_decl.
    def enterGlob_var_decl(self, ctx:CtParser.Glob_var_declContext):
        print(" ( glob_var_decl "+ctx.ID().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#glob_var_decl.
    def exitGlob_var_decl(self, ctx:CtParser.Glob_var_declContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#fn_decl.
    def enterFn_decl(self, ctx:CtParser.Fn_declContext):
        print(" ( fn_decl "+ctx.ID().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#fn_decl.
    def exitFn_decl(self, ctx:CtParser.Fn_declContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#type_decl.
    def enterType_decl(self, ctx:CtParser.Type_declContext):
        print(" ( type_decl "+ctx.ID().getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#type_decl.
    def exitType_decl(self, ctx:CtParser.Type_declContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#glob_var_def.
    def enterGlob_var_def(self, ctx:CtParser.Glob_var_defContext):
        print(" ( glob_var_def " ,end="")

    # Exit a parse tree produced by CtParser#glob_var_def.
    def exitGlob_var_def(self, ctx:CtParser.Glob_var_defContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#path.
    def enterPath(self, ctx:CtParser.PathContext):
        print(" "+ctx.getChild(0).getText()+" " ,end="")
        if ctx.getChildCount() > 1:
            print(" "+ctx.getChild(2).getText()+" " ,end="")

    # Exit a parse tree produced by CtParser#path.
    def exitPath(self, ctx:CtParser.PathContext):
        pass


    # Enter a parse tree produced by CtParser#immut.
    def enterImmut(self, ctx:CtParser.ImmutContext):
        print(" ( immut " ,end="")

    # Exit a parse tree produced by CtParser#immut.
    def exitImmut(self, ctx:CtParser.ImmutContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#local_var_decl.
    def enterLocal_var_decl(self, ctx:CtParser.Local_var_declContext):
        print(" ( local_var_decl "+ctx.ID().getText() ,end=" ")

    # Exit a parse tree produced by CtParser#local_var_decl.
    def exitLocal_var_decl(self, ctx:CtParser.Local_var_declContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#local_var_def.
    def enterLocal_var_def(self, ctx:CtParser.Local_var_defContext):
        print(" ( local_var_def "+ctx.ID().getText() ,end=" ")

    # Exit a parse tree produced by CtParser#local_var_def.
    def exitLocal_var_def(self, ctx:CtParser.Local_var_defContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#match_stmt.
    def enterMatch_stmt(self, ctx:CtParser.Match_stmtContext):
        print(" ( match_stmt " ,end="")

    # Exit a parse tree produced by CtParser#match_stmt.
    def exitMatch_stmt(self, ctx:CtParser.Match_stmtContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#case.
    def enterCase_(self, ctx:CtParser.Case_Context):
        if ctx.ID() != None:
            print(" ( case "+ctx.ID().getText()+" " ,end="")
        else: 
            print(" ( case ",end="")

    # Exit a parse tree produced by CtParser#case.
    def exitCase_(self, ctx:CtParser.Case_Context):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#typedef.
    def enterTypedef(self, ctx:CtParser.TypedefContext):
        print(" ( typedef " ,end="")

    # Exit a parse tree produced by CtParser#typedef.
    def exitTypedef(self, ctx:CtParser.TypedefContext):
        print(" ) " ,end="")


    # Enter a parse tree produced by CtParser#handler.
    def enterHandle(self, ctx:CtParser.HandleContext):
        print(" handle " ,end="")

    # Exit a parse tree produced by CtParser#handler.
    def exitHandle(self, ctx:CtParser.HandleContext):
        pass


def main(argv):
    input_stream = FileStream(argv[1])
    lexer = CtLexer(input_stream)
    # tok = lexer.nextToken()
    # while tok.type != -1:
    #     print(tok)
    #     tok = lexer.nextToken()
    stream = CommonTokenStream(lexer)
    parser = CtParser(stream)

    tree = parser.file_()

    analyzer = Analyzer()
    walker = ParseTreeWalker()
    walker.walk(analyzer, tree)

    #print(tree.toStringTree(parser.ruleNames))
 
if __name__ == '__main__':
    main(sys.argv)
