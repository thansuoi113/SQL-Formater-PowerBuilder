$PBExportHeader$nvo_sqlfunc_columnattrib.sru
forward
global type nvo_sqlfunc_columnattrib from nonvisualobject
end type
end forward

global type nvo_sqlfunc_columnattrib from nonvisualobject autoinstantiate
end type

type variables
Public Constant String NO_NAME = ''
Public Constant String QE_NAME = '='
Public Constant String AS_NAME = 'as'

String is_expr // full column expression
String is_name // column name
String is_dbtype // column database type
String is_type // column type
String is_namestyle // column naming style
Boolean ib_subquery // column expression is subquery


end variables
on nvo_sqlfunc_columnattrib.create
call super::create
TriggerEvent( this, "constructor" )
end on

on nvo_sqlfunc_columnattrib.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

