# Generated from Ct.g4 by ANTLR 4.9.1
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .CtParser import CtParser
else:
    from CtParser import CtParser

# This class defines a complete listener for a parse tree produced by CtParser.
class CtListener(ParseTreeListener):

    # Enter a parse tree produced by CtParser#file_.
    def enterFile_(self, ctx:CtParser.File_Context):
        pass

    # Exit a parse tree produced by CtParser#file_.
    def exitFile_(self, ctx:CtParser.File_Context):
        pass


    # Enter a parse tree produced by CtParser#lib_def.
    def enterLib_def(self, ctx:CtParser.Lib_defContext):
        pass

    # Exit a parse tree produced by CtParser#lib_def.
    def exitLib_def(self, ctx:CtParser.Lib_defContext):
        pass


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


    # Enter a parse tree produced by CtParser#type_decl.
    def enterType_decl(self, ctx:CtParser.Type_declContext):
        pass

    # Exit a parse tree produced by CtParser#type_decl.
    def exitType_decl(self, ctx:CtParser.Type_declContext):
        pass


    # Enter a parse tree produced by CtParser#glob_var_decl.
    def enterGlob_var_decl(self, ctx:CtParser.Glob_var_declContext):
        pass

    # Exit a parse tree produced by CtParser#glob_var_decl.
    def exitGlob_var_decl(self, ctx:CtParser.Glob_var_declContext):
        pass


    # Enter a parse tree produced by CtParser#fn_decl.
    def enterFn_decl(self, ctx:CtParser.Fn_declContext):
        pass

    # Exit a parse tree produced by CtParser#fn_decl.
    def exitFn_decl(self, ctx:CtParser.Fn_declContext):
        pass


    # Enter a parse tree produced by CtParser#type_def.
    def enterType_def(self, ctx:CtParser.Type_defContext):
        pass

    # Exit a parse tree produced by CtParser#type_def.
    def exitType_def(self, ctx:CtParser.Type_defContext):
        pass


    # Enter a parse tree produced by CtParser#fn_def.
    def enterFn_def(self, ctx:CtParser.Fn_defContext):
        pass

    # Exit a parse tree produced by CtParser#fn_def.
    def exitFn_def(self, ctx:CtParser.Fn_defContext):
        pass


    # Enter a parse tree produced by CtParser#glob_var_def.
    def enterGlob_var_def(self, ctx:CtParser.Glob_var_defContext):
        pass

    # Exit a parse tree produced by CtParser#glob_var_def.
    def exitGlob_var_def(self, ctx:CtParser.Glob_var_defContext):
        pass


    # Enter a parse tree produced by CtParser#param_annot.
    def enterParam_annot(self, ctx:CtParser.Param_annotContext):
        pass

    # Exit a parse tree produced by CtParser#param_annot.
    def exitParam_annot(self, ctx:CtParser.Param_annotContext):
        pass


    # Enter a parse tree produced by CtParser#placehldr_annot.
    def enterPlacehldr_annot(self, ctx:CtParser.Placehldr_annotContext):
        pass

    # Exit a parse tree produced by CtParser#placehldr_annot.
    def exitPlacehldr_annot(self, ctx:CtParser.Placehldr_annotContext):
        pass


    # Enter a parse tree produced by CtParser#param.
    def enterParam(self, ctx:CtParser.ParamContext):
        pass

    # Exit a parse tree produced by CtParser#param.
    def exitParam(self, ctx:CtParser.ParamContext):
        pass


    # Enter a parse tree produced by CtParser#param_for_param.
    def enterParam_for_param(self, ctx:CtParser.Param_for_paramContext):
        pass

    # Exit a parse tree produced by CtParser#param_for_param.
    def exitParam_for_param(self, ctx:CtParser.Param_for_paramContext):
        pass


    # Enter a parse tree produced by CtParser#placehldr.
    def enterPlacehldr(self, ctx:CtParser.PlacehldrContext):
        pass

    # Exit a parse tree produced by CtParser#placehldr.
    def exitPlacehldr(self, ctx:CtParser.PlacehldrContext):
        pass


    # Enter a parse tree produced by CtParser#path.
    def enterPath(self, ctx:CtParser.PathContext):
        pass

    # Exit a parse tree produced by CtParser#path.
    def exitPath(self, ctx:CtParser.PathContext):
        pass


    # Enter a parse tree produced by CtParser#type_spec.
    def enterType_spec(self, ctx:CtParser.Type_specContext):
        pass

    # Exit a parse tree produced by CtParser#type_spec.
    def exitType_spec(self, ctx:CtParser.Type_specContext):
        pass


    # Enter a parse tree produced by CtParser#immut.
    def enterImmut(self, ctx:CtParser.ImmutContext):
        pass

    # Exit a parse tree produced by CtParser#immut.
    def exitImmut(self, ctx:CtParser.ImmutContext):
        pass


    # Enter a parse tree produced by CtParser#base_type.
    def enterBase_type(self, ctx:CtParser.Base_typeContext):
        pass

    # Exit a parse tree produced by CtParser#base_type.
    def exitBase_type(self, ctx:CtParser.Base_typeContext):
        pass


    # Enter a parse tree produced by CtParser#array_qual.
    def enterArray_qual(self, ctx:CtParser.Array_qualContext):
        pass

    # Exit a parse tree produced by CtParser#array_qual.
    def exitArray_qual(self, ctx:CtParser.Array_qualContext):
        pass


    # Enter a parse tree produced by CtParser#vla_qual.
    def enterVla_qual(self, ctx:CtParser.Vla_qualContext):
        pass

    # Exit a parse tree produced by CtParser#vla_qual.
    def exitVla_qual(self, ctx:CtParser.Vla_qualContext):
        pass


    # Enter a parse tree produced by CtParser#ptr_qual.
    def enterPtr_qual(self, ctx:CtParser.Ptr_qualContext):
        pass

    # Exit a parse tree produced by CtParser#ptr_qual.
    def exitPtr_qual(self, ctx:CtParser.Ptr_qualContext):
        pass


    # Enter a parse tree produced by CtParser#adr_qual.
    def enterAdr_qual(self, ctx:CtParser.Adr_qualContext):
        pass

    # Exit a parse tree produced by CtParser#adr_qual.
    def exitAdr_qual(self, ctx:CtParser.Adr_qualContext):
        pass


    # Enter a parse tree produced by CtParser#struct_qual.
    def enterStruct_qual(self, ctx:CtParser.Struct_qualContext):
        pass

    # Exit a parse tree produced by CtParser#struct_qual.
    def exitStruct_qual(self, ctx:CtParser.Struct_qualContext):
        pass


    # Enter a parse tree produced by CtParser#union_qual.
    def enterUnion_qual(self, ctx:CtParser.Union_qualContext):
        pass

    # Exit a parse tree produced by CtParser#union_qual.
    def exitUnion_qual(self, ctx:CtParser.Union_qualContext):
        pass


    # Enter a parse tree produced by CtParser#field.
    def enterField(self, ctx:CtParser.FieldContext):
        pass

    # Exit a parse tree produced by CtParser#field.
    def exitField(self, ctx:CtParser.FieldContext):
        pass


    # Enter a parse tree produced by CtParser#func_qual.
    def enterFunc_qual(self, ctx:CtParser.Func_qualContext):
        pass

    # Exit a parse tree produced by CtParser#func_qual.
    def exitFunc_qual(self, ctx:CtParser.Func_qualContext):
        pass


    # Enter a parse tree produced by CtParser#typedef.
    def enterTypedef(self, ctx:CtParser.TypedefContext):
        pass

    # Exit a parse tree produced by CtParser#typedef.
    def exitTypedef(self, ctx:CtParser.TypedefContext):
        pass


    # Enter a parse tree produced by CtParser#arg_annot.
    def enterArg_annot(self, ctx:CtParser.Arg_annotContext):
        pass

    # Exit a parse tree produced by CtParser#arg_annot.
    def exitArg_annot(self, ctx:CtParser.Arg_annotContext):
        pass


    # Enter a parse tree produced by CtParser#fn_body.
    def enterFn_body(self, ctx:CtParser.Fn_bodyContext):
        pass

    # Exit a parse tree produced by CtParser#fn_body.
    def exitFn_body(self, ctx:CtParser.Fn_bodyContext):
        pass


    # Enter a parse tree produced by CtParser#stmt.
    def enterStmt(self, ctx:CtParser.StmtContext):
        pass

    # Exit a parse tree produced by CtParser#stmt.
    def exitStmt(self, ctx:CtParser.StmtContext):
        pass


    # Enter a parse tree produced by CtParser#local_var_decl.
    def enterLocal_var_decl(self, ctx:CtParser.Local_var_declContext):
        pass

    # Exit a parse tree produced by CtParser#local_var_decl.
    def exitLocal_var_decl(self, ctx:CtParser.Local_var_declContext):
        pass


    # Enter a parse tree produced by CtParser#local_var_def.
    def enterLocal_var_def(self, ctx:CtParser.Local_var_defContext):
        pass

    # Exit a parse tree produced by CtParser#local_var_def.
    def exitLocal_var_def(self, ctx:CtParser.Local_var_defContext):
        pass


    # Enter a parse tree produced by CtParser#arrow.
    def enterArrow(self, ctx:CtParser.ArrowContext):
        pass

    # Exit a parse tree produced by CtParser#arrow.
    def exitArrow(self, ctx:CtParser.ArrowContext):
        pass


    # Enter a parse tree produced by CtParser#cmp_stmt.
    def enterCmp_stmt(self, ctx:CtParser.Cmp_stmtContext):
        pass

    # Exit a parse tree produced by CtParser#cmp_stmt.
    def exitCmp_stmt(self, ctx:CtParser.Cmp_stmtContext):
        pass


    # Enter a parse tree produced by CtParser#if_stmt.
    def enterIf_stmt(self, ctx:CtParser.If_stmtContext):
        pass

    # Exit a parse tree produced by CtParser#if_stmt.
    def exitIf_stmt(self, ctx:CtParser.If_stmtContext):
        pass


    # Enter a parse tree produced by CtParser#else_stmt.
    def enterElse_stmt(self, ctx:CtParser.Else_stmtContext):
        pass

    # Exit a parse tree produced by CtParser#else_stmt.
    def exitElse_stmt(self, ctx:CtParser.Else_stmtContext):
        pass


    # Enter a parse tree produced by CtParser#iter_stmt.
    def enterIter_stmt(self, ctx:CtParser.Iter_stmtContext):
        pass

    # Exit a parse tree produced by CtParser#iter_stmt.
    def exitIter_stmt(self, ctx:CtParser.Iter_stmtContext):
        pass


    # Enter a parse tree produced by CtParser#match_stmt.
    def enterMatch_stmt(self, ctx:CtParser.Match_stmtContext):
        pass

    # Exit a parse tree produced by CtParser#match_stmt.
    def exitMatch_stmt(self, ctx:CtParser.Match_stmtContext):
        pass


    # Enter a parse tree produced by CtParser#case_.
    def enterCase_(self, ctx:CtParser.Case_Context):
        pass

    # Exit a parse tree produced by CtParser#case_.
    def exitCase_(self, ctx:CtParser.Case_Context):
        pass


    # Enter a parse tree produced by CtParser#res_stmt.
    def enterRes_stmt(self, ctx:CtParser.Res_stmtContext):
        pass

    # Exit a parse tree produced by CtParser#res_stmt.
    def exitRes_stmt(self, ctx:CtParser.Res_stmtContext):
        pass


    # Enter a parse tree produced by CtParser#move_stmt.
    def enterMove_stmt(self, ctx:CtParser.Move_stmtContext):
        pass

    # Exit a parse tree produced by CtParser#move_stmt.
    def exitMove_stmt(self, ctx:CtParser.Move_stmtContext):
        pass


    # Enter a parse tree produced by CtParser#drop_stmt.
    def enterDrop_stmt(self, ctx:CtParser.Drop_stmtContext):
        pass

    # Exit a parse tree produced by CtParser#drop_stmt.
    def exitDrop_stmt(self, ctx:CtParser.Drop_stmtContext):
        pass


    # Enter a parse tree produced by CtParser#expr.
    def enterExpr(self, ctx:CtParser.ExprContext):
        pass

    # Exit a parse tree produced by CtParser#expr.
    def exitExpr(self, ctx:CtParser.ExprContext):
        pass


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


    # Enter a parse tree produced by CtParser#handle.
    def enterHandle(self, ctx:CtParser.HandleContext):
        pass

    # Exit a parse tree produced by CtParser#handle.
    def exitHandle(self, ctx:CtParser.HandleContext):
        pass


    # Enter a parse tree produced by CtParser#get_adr.
    def enterGet_adr(self, ctx:CtParser.Get_adrContext):
        pass

    # Exit a parse tree produced by CtParser#get_adr.
    def exitGet_adr(self, ctx:CtParser.Get_adrContext):
        pass


    # Enter a parse tree produced by CtParser#get_ptr.
    def enterGet_ptr(self, ctx:CtParser.Get_ptrContext):
        pass

    # Exit a parse tree produced by CtParser#get_ptr.
    def exitGet_ptr(self, ctx:CtParser.Get_ptrContext):
        pass


    # Enter a parse tree produced by CtParser#deref_adr.
    def enterDeref_adr(self, ctx:CtParser.Deref_adrContext):
        pass

    # Exit a parse tree produced by CtParser#deref_adr.
    def exitDeref_adr(self, ctx:CtParser.Deref_adrContext):
        pass


    # Enter a parse tree produced by CtParser#deref_ptr.
    def enterDeref_ptr(self, ctx:CtParser.Deref_ptrContext):
        pass

    # Exit a parse tree produced by CtParser#deref_ptr.
    def exitDeref_ptr(self, ctx:CtParser.Deref_ptrContext):
        pass


    # Enter a parse tree produced by CtParser#indexing.
    def enterIndexing(self, ctx:CtParser.IndexingContext):
        pass

    # Exit a parse tree produced by CtParser#indexing.
    def exitIndexing(self, ctx:CtParser.IndexingContext):
        pass


    # Enter a parse tree produced by CtParser#field_select.
    def enterField_select(self, ctx:CtParser.Field_selectContext):
        pass

    # Exit a parse tree produced by CtParser#field_select.
    def exitField_select(self, ctx:CtParser.Field_selectContext):
        pass


    # Enter a parse tree produced by CtParser#fn_call.
    def enterFn_call(self, ctx:CtParser.Fn_callContext):
        pass

    # Exit a parse tree produced by CtParser#fn_call.
    def exitFn_call(self, ctx:CtParser.Fn_callContext):
        pass


    # Enter a parse tree produced by CtParser#method_call.
    def enterMethod_call(self, ctx:CtParser.Method_callContext):
        pass

    # Exit a parse tree produced by CtParser#method_call.
    def exitMethod_call(self, ctx:CtParser.Method_callContext):
        pass


    # Enter a parse tree produced by CtParser#ctor.
    def enterCtor(self, ctx:CtParser.CtorContext):
        pass

    # Exit a parse tree produced by CtParser#ctor.
    def exitCtor(self, ctx:CtParser.CtorContext):
        pass


    # Enter a parse tree produced by CtParser#const_.
    def enterConst_(self, ctx:CtParser.Const_Context):
        pass

    # Exit a parse tree produced by CtParser#const_.
    def exitConst_(self, ctx:CtParser.Const_Context):
        pass


    # Enter a parse tree produced by CtParser#struct_ctor.
    def enterStruct_ctor(self, ctx:CtParser.Struct_ctorContext):
        pass

    # Exit a parse tree produced by CtParser#struct_ctor.
    def exitStruct_ctor(self, ctx:CtParser.Struct_ctorContext):
        pass


    # Enter a parse tree produced by CtParser#union_ctor.
    def enterUnion_ctor(self, ctx:CtParser.Union_ctorContext):
        pass

    # Exit a parse tree produced by CtParser#union_ctor.
    def exitUnion_ctor(self, ctx:CtParser.Union_ctorContext):
        pass


    # Enter a parse tree produced by CtParser#array_ctor.
    def enterArray_ctor(self, ctx:CtParser.Array_ctorContext):
        pass

    # Exit a parse tree produced by CtParser#array_ctor.
    def exitArray_ctor(self, ctx:CtParser.Array_ctorContext):
        pass


    # Enter a parse tree produced by CtParser#initer.
    def enterIniter(self, ctx:CtParser.IniterContext):
        pass

    # Exit a parse tree produced by CtParser#initer.
    def exitIniter(self, ctx:CtParser.IniterContext):
        pass


    # Enter a parse tree produced by CtParser#designator.
    def enterDesignator(self, ctx:CtParser.DesignatorContext):
        pass

    # Exit a parse tree produced by CtParser#designator.
    def exitDesignator(self, ctx:CtParser.DesignatorContext):
        pass



del CtParser