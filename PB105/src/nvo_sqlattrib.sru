$PBExportHeader$nvo_sqlattrib.sru
forward
global type nvo_sqlattrib from nonvisualobject
end type
end forward

global type nvo_sqlattrib from nonvisualobject
end type
global nvo_sqlattrib nvo_sqlattrib

type variables
String s_verb
String s_tables
String s_columns
String s_values
String s_where
String s_order
String s_group
String s_having


end variables
on nvo_sqlattrib.create
call super::create
TriggerEvent( this, "constructor" )
end on

on nvo_sqlattrib.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

