$PBExportHeader$w_main.srw
forward
global type w_main from window
end type
type cb_sqlformater from commandbutton within w_main
end type
type uo_sql from uo_scilexer within w_main
end type
end forward

global type w_main from window
integer width = 2757
integer height = 1876
boolean titlebar = true
string title = "SQL Formater"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_sqlformater cb_sqlformater
uo_sql uo_sql
end type
global w_main w_main

on w_main.create
this.cb_sqlformater=create cb_sqlformater
this.uo_sql=create uo_sql
this.Control[]={this.cb_sqlformater,&
this.uo_sql}
end on

on w_main.destroy
destroy(this.cb_sqlformater)
destroy(this.uo_sql)
end on

event resize;uo_sql.Move(5,5)
cb_sqlformater.Move(newwidth - 10 - cb_sqlformater.Width, newheight - 10 - cb_sqlformater.Height)
uo_sql.Resize( newwidth - 10, newheight - 10 - cb_sqlformater.Height - 5)


end event

type cb_sqlformater from commandbutton within w_main
integer x = 2267
integer y = 1632
integer width = 421
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "SQL Formater"
end type

event clicked;String ls_sql, ls_sqltype
Int li_rc, li_ret
nvo_sqlfunc lnv_sqlfunc

ls_sql = uo_sql.of_gettext()
If IsNull(ls_sql) Or Len(Trim(ls_sql)) = 0 Then Return

lnv_sqlfunc = Create nvo_sqlfunc
li_rc = lnv_sqlfunc.of_Format(ls_sql) 
Destroy lnv_sqlfunc

If li_rc > 0 Then
	If ls_sql <> "" Then
		uo_sql.of_settext(ls_sql)
	End If
End If
end event

type uo_sql from uo_scilexer within w_main
integer width = 2706
integer height = 1632
integer taborder = 10
end type

event constructor;call super::constructor;uo_sql.of_SetFont("System")
uo_sql.of_setfontsize( 12)
uo_sql.of_SetEncoding(EncodingUTF8!)
uo_sql.of_Set_SQL()
end event

