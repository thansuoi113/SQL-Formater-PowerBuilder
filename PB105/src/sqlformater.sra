$PBExportHeader$sqlformater.sra
$PBExportComments$Generated Application Object
forward
global type sqlformater from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global type sqlformater from application
string appname = "sqlformater"
end type
global sqlformater sqlformater

on sqlformater.create
appname="sqlformater"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on sqlformater.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;open(w_main)
end event

