$PBExportHeader$nvo_sqlfunc_attrib.sru
forward
global type nvo_sqlfunc_attrib from nonvisualobject
end type
end forward

global type nvo_sqlfunc_attrib from nonvisualobject
end type
global nvo_sqlfunc_attrib nvo_sqlfunc_attrib

type variables
nvo_sqlfunc_columnattrib	istr_column[]
String s_verb
String s_tables
String s_columns
String s_values
String s_where
String s_order
String s_group
String s_having


end variables
on nvo_sqlfunc_attrib.create
call super::create
TriggerEvent( this, "constructor" )
end on

on nvo_sqlfunc_attrib.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

