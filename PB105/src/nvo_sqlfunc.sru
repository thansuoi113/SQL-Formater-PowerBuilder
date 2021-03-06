$PBExportHeader$nvo_sqlfunc.sru
forward
global type nvo_sqlfunc from nonvisualobject
end type
end forward

global type nvo_sqlfunc from nonvisualobject
end type
global nvo_sqlfunc nvo_sqlfunc

type variables
Protected:
nvo_exprfunc	inv_expr
nvo_string	inv_str



end variables
forward prototypes
private function integer of_count (string as_token[], string as_search, integer ai_start, integer ai_finish)
private function integer of_index (string as_token[], string as_search, integer ai_start, integer ai_finish, integer ai_count)
private function string of_assemble (string as_token[], integer ai_start, integer ai_finish, boolean ab_format)
public function integer of_parse (string as_sql, ref nvo_sqlfunc_attrib astr_sql[])
public function integer of_parsecolumns (string as_sql, ref nvo_sqlfunc_columnattrib ao_columnattrib[])
public function integer of_assemblecolumns (ref string as_sql, nvo_sqlfunc_columnattrib ao_columnattrib[])
public function string of_assemble (nvo_sqlfunc_attrib astr_sql[])
public function integer of_format (ref string as_sql)
public function integer of_sqltype (string as_sql, ref string as_sqltype)
end prototypes

private function integer of_count (string as_token[], string as_search, integer ai_start, integer ai_finish);//====================================================================
// Function: nvo_sqlfunc.of_count()
//--------------------------------------------------------------------
// Description:	calculate count of search tokens.
//--------------------------------------------------------------------
// Arguments:
// 	value	string 	as_token[]	token list
// 	value	string 	as_search 	token to search
// 	value	integer	ai_start  		start index
// 	value	integer	ai_finish 		last index (0 - last)
//--------------------------------------------------------------------
// Returns:  integer	1 - ok 	-1- error
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_sqlfunc.of_count ( string as_token[], string as_search, integer ai_start, integer ai_finish )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer li_Index, li_Count

If IsNull(as_token) Then Return -1
If IsNull(as_search) Then Return -1

as_search = Lower(as_search)

If ai_finish = 0 Then ai_finish = UpperBound(as_token[])

For li_Index = ai_start To ai_finish
	If Lower(as_token[li_Index]) = as_search Then li_Count++
Next

Return li_Count


end function

private function integer of_index (string as_token[], string as_search, integer ai_start, integer ai_finish, integer ai_count);//====================================================================
// Function: nvo_sqlfunc.of_index()
//--------------------------------------------------------------------
// Description:	calculate index of search tokens.
//--------------------------------------------------------------------
// Arguments:
// 	value	string 	as_token[]		token list
// 	value	string 	as_search 		token to search
// 	value	integer	ai_start  			start index
// 	value	integer	ai_finish 			last index (0 - last)
// 	value	integer	ai_count  		count of search
//--------------------------------------------------------------------
// Returns:  integer	0 - not found	-1- error
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_sqlfunc.of_index ( string as_token[], string as_search, integer ai_start, integer ai_finish, integer ai_count )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer li_Index, li_Count

If IsNull(as_token) Then Return -1
If IsNull(as_search) Then Return -1

as_search = Lower(as_search)

If ai_finish = 0 Then ai_finish = UpperBound(as_token[])

For li_Index = ai_start To ai_finish
	If Lower(as_token[li_Index]) = as_search Then
		li_Count++
		If li_Count = ai_count Then Return li_Index
	End If
Next

Return 0



end function

private function string of_assemble (string as_token[], integer ai_start, integer ai_finish, boolean ab_format);//====================================================================
// Function: nvo_sqlfunc.of_assemble()
//--------------------------------------------------------------------
// Description:	assemble sql string.
//--------------------------------------------------------------------
// Arguments:
// 	string 	as_token[]	token list
// 	integer	ai_start  		start index
// 	integer	ai_finish 		last index
// 	boolean	ab_format 	using format
//--------------------------------------------------------------------
// Returns:  string	-1- error
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_sqlfunc.of_assemble ( string as_token[], integer ai_start, integer ai_finish, boolean ab_format )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer 	li_Index, li_Count
String	ls_word
String	ls_Res
Boolean	ib_SpaceBefore, ib_SpaceAfter

If IsNull(as_token) Then
	SetNull(ls_Res)
	Return ls_Res
End If

ib_SpaceBefore = False
ib_SpaceAfter = False

For li_Index = ai_start To ai_finish
	ls_word = as_token[li_Index]
	
	Choose Case ls_word
		Case '.'
			ls_Res+= ls_word
			ib_SpaceBefore = False
		Case ','
			ls_Res+= ls_word
			ib_SpaceBefore = True
		Case Else
			If ib_SpaceBefore Then ls_Res+= ' '
			ls_Res+= ls_word
			ib_SpaceBefore = True
	End Choose
Next

ls_Res = Trim(ls_Res)

Return ls_Res


end function

public function integer of_parse (string as_sql, ref nvo_sqlfunc_attrib astr_sql[]);//====================================================================
// Function: nvo_sqlfunc.of_parse()
//--------------------------------------------------------------------
// Description:	Parse a SQL statement into its component parts.
//--------------------------------------------------------------------
// Arguments:
// 	value    	string            	as_sql    				The SQL statement to parse.	
// 	reference	nvo_sqlfunc_attrib	astr_sql[]	An array of sql attributes, passed by reference, to be filled with the parsed SQL.
//--------------------------------------------------------------------
// Returns:  integer	The number of elements in the array.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_sqlfunc.of_parse ( string as_sql, ref nvo_sqlfunc_attrib astr_sql[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer	li_Len, li_Pos, li_KWNum, li_NumStats, li_Cnt
String	ls_UpperSQL, ls_Keyword[7], ls_Clause[7], ls_SQL[]
String	ls_Word, ls_TestString
Integer	li_Start, li_Finish, li_CntLeft, li_CntRight
Boolean	ib_Found
Integer	li_rc

// Function requires the string service
nvo_string  lnv_string

// Separate the statement into multiple statements separated by UNIONs
li_NumStats = lnv_string.of_ParseToArray(as_SQL, "UNION", ls_SQL)

For li_Cnt = 1 To li_NumStats
	// Remove Carriage returns, Newlines, and Tabs
	ls_SQL[li_Cnt] = lnv_string.of_GlobalReplace(ls_SQL[li_Cnt], "~r", " ")
	ls_SQL[li_Cnt] = lnv_string.of_GlobalReplace(ls_SQL[li_Cnt], "~n", " ")
	ls_SQL[li_Cnt] = lnv_string.of_GlobalReplace(ls_SQL[li_Cnt], "~t", " ")
	
	// Remove leading and trailing spaces
	ls_SQL[li_Cnt] = Trim(ls_SQL[li_Cnt])
	
	// Convet to upper case
	ls_UpperSQL = Upper(ls_SQL[li_Cnt])
	
	// Determine what type of SQL this is
	// and assign the appropriate kewords
	// for the corresponding type
	If LeftA(ls_UpperSQL, 7) = "SELECT " Then
		// Parse the SELECT statement
		ls_Keyword[1] = "SELECT "
		ls_Keyword[2] = " FROM "
		ls_Keyword[3] = " WHERE "
		ls_Keyword[4] = " GROUP BY "
		ls_Keyword[5] = " HAVING "
		ls_Keyword[6] = " ORDER BY "
		
	ElseIf LeftA(ls_UpperSQL, 7) = "UPDATE " Then
		// Parse the UPDATE statement
		ls_Keyword[1] = "UPDATE "
		ls_Keyword[2] = " SET "
		ls_Keyword[3] = " WHERE "
		ls_Keyword[6] = " ORDER BY "
		
	ElseIf LeftA(ls_UpperSQL, 12) = "INSERT INTO " Then
		// Parse the INSERT statement (test before 'insert')
		ls_Keyword[1] = "INSERT INTO "
		ls_Keyword[7] = " VALUES "
		
	ElseIf LeftA(ls_UpperSQL, 7) = "INSERT " Then
		// Parse the INSERT statement (test after 'insert to')
		ls_Keyword[1] = "INSERT "
		ls_Keyword[7] = " VALUES "
		
	ElseIf LeftA(ls_UpperSQL, 12) = "DELETE FROM " Then
		// Parse the DELETE statement (test before 'delete')
		ls_Keyword[1] = "DELETE FROM "
		ls_Keyword[3] = " WHERE "
		
	ElseIf LeftA(ls_UpperSQL, 7) = "DELETE " Then
		// Parse the DELETE statement (test after 'delete from')
		ls_Keyword[1] = "DELETE "
		ls_Keyword[3] = " WHERE "
		
	End If
	
	// Corrected by M.K. 09.04.98 (subquery support added)
	//	// There is a maximum of 7 keywords
	//	For li_KWNum = 7 To 1 Step -1
	//		If ls_Keyword[li_KWNum] <> "" Then
	//			// Find the position of the Keyword
	//			li_Pos = Pos(ls_UpperSQL, ls_Keyword[li_KWNum]) - 1
	//
	//			If li_Pos >= 0 Then
	//				ls_Clause[li_KWNum] = Right(ls_SQL[li_Cnt], &
	//													(Len(ls_SQL[li_Cnt]) - &
	//														(li_Pos + Len(ls_Keyword[li_KWNum]))))
	//				ls_SQL[li_Cnt] = Left(ls_SQL[li_Cnt], li_Pos)
	//			Else
	//				ls_Clause[li_KWNum] = ""
	//			End if
	//		End if
	//	Next
	
	li_Start = 1
	
	// There is a maximum of 7 keywords
	For li_KWNum = 7 To 1 Step -1
		ls_Word = ls_Keyword[li_KWNum]
		If ls_Word <> "" Then
			// Find the position of the Keyword
			// check for subquery
			li_Finish = PosA(ls_UpperSQL, ls_Word, li_Start)
			ib_Found = False
			Do While li_Finish > 0
				ls_TestString = MidA(ls_UpperSQL, li_Start+1, li_Finish - li_Start)
				li_CntLeft = lnv_string.of_CountOccurrences ( ls_TestString, '(' )
				li_CntRight = lnv_string.of_CountOccurrences ( ls_TestString, ')' )
				If li_CntLeft = li_CntRight Then
					ib_Found = True
					Exit
				End If
				li_Finish = PosA(ls_UpperSQL, ls_Word, li_Finish+1)
			Loop
			
			If Not ib_Found Then Continue
			
			//li_Pos = Pos(ls_UpperSQL, ls_Word) - 1
			li_Pos = li_Finish - 1
			
			If li_Pos >= 0 Then
				ls_Clause[li_KWNum] = RightA(ls_SQL[li_Cnt], &
					(LenA(ls_SQL[li_Cnt]) - &
					(li_Pos + LenA(ls_Word))))
				ls_SQL[li_Cnt] = LeftA(ls_SQL[li_Cnt], li_Pos)
			Else
				ls_Clause[li_KWNum] = ""
			End If
		End If
	Next
	//	End of Corrections	
	
	astr_sql[li_Cnt].s_Verb = Trim(ls_Keyword[1])
	
	If PosA(astr_sql[li_Cnt].s_Verb, "SELECT") > 0 Then
		astr_sql[li_Cnt].s_Columns = Trim(ls_Clause[1])
		astr_sql[li_Cnt].s_Tables 	 = Trim(ls_Clause[2])
	Else
		astr_sql[li_Cnt].s_Tables = Trim(ls_Clause[1])
		
		If PosA(astr_sql[li_Cnt].s_Verb, "INSERT") > 0 Then
			li_Pos = PosA(astr_sql[li_Cnt].s_Tables, " ")
			If li_Pos > 0 Then
				astr_sql[li_Cnt].s_Columns = Trim(RightA(astr_sql[li_Cnt].s_Tables, &
					(LenA(astr_sql[li_Cnt].s_Tables) - li_Pos)))
				astr_sql[li_Cnt].s_Tables = LeftA(astr_sql[li_Cnt].s_Tables, (li_Pos - 1))
			End If
		Else
			astr_sql[li_Cnt].s_Columns = Trim(ls_Clause[2])
		End If
	End If
	
	astr_sql[li_Cnt].s_Where 	 = Trim(ls_Clause[3])
	astr_sql[li_Cnt].s_Group 	 = Trim(ls_Clause[4])
	astr_sql[li_Cnt].s_Having 	 = Trim(ls_Clause[5])
	astr_sql[li_Cnt].s_Order 	 = Trim(ls_Clause[6])
	astr_sql[li_Cnt].s_Values 	 = Trim(ls_Clause[7])
	
	// Added by M.K. 10.04.98
	// parse columns
	li_rc = This.of_ParseColumns(astr_sql[li_Cnt].s_Columns, astr_sql[li_Cnt].istr_column[])
	// end of adding
Next


Return li_NumStats


end function

public function integer of_parsecolumns (string as_sql, ref nvo_sqlfunc_columnattrib ao_columnattrib[]);//====================================================================
// Function: nvo_sqlfunc.of_parsecolumns()
//--------------------------------------------------------------------
// Description:		parse columns from sql syntax.
//--------------------------------------------------------------------
// Arguments:
// 	value    	string                  	as_sql           							sql syntax
// 	reference	nvo_sqlfunc_columnattrib	ao_columnattrib[]		(ref) n_cst_sqlfunc_columnattrib
//--------------------------------------------------------------------
// Returns:  integer	1 - ok	-1- error
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_sqlfunc.of_parsecolumns ( string as_sql, ref nvo_sqlfunc_columnattrib ao_columnattrib[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String 	ls_SQL
Integer	li_index, li_count, li_start, li_finish
Integer  li_cntleft, li_cntright
Boolean	ib_Found
Integer	li_prev, li_pos
String	ls_TestString
//n_cst_sql_columnattrib	lo_dummy[]

If IsNull(as_sql) Or LenA(Trim(as_sql)) = 0 Then Return -1

ls_SQL = Trim(as_sql)

li_pos = PosA(ls_SQL, ',', 1)

If li_pos = 0 Then // only one column
	ao_columnattrib[1].is_expr = ls_SQL
	Return 1
End If

// cycle for all columns	
li_count = 0
li_prev = 1
ib_Found = False
Do While li_pos > 0
	ls_TestString = MidA(ls_SQL, li_prev, li_pos - li_prev)
	li_cntleft = inv_str.of_CountOccurrences( ls_TestString, '(' )
	li_cntright = inv_str.of_CountOccurrences( ls_TestString, ')' )
	If li_cntleft = li_cntright Then
		li_count++
		ao_columnattrib[li_count].is_expr = Trim(ls_TestString)
		li_prev = li_pos+1
	End If
	li_pos = PosA(ls_SQL, ',', li_pos+1)
Loop

// last column
li_count++
ao_columnattrib[li_count].is_expr = Trim(MidA(ls_SQL, li_prev))

Return li_count


end function

public function integer of_assemblecolumns (ref string as_sql, nvo_sqlfunc_columnattrib ao_columnattrib[]);//====================================================================
// Function: nvo_sqlfunc.of_assemblecolumns()
//--------------------------------------------------------------------
// Description:	assemble columns to sql syntax.
//--------------------------------------------------------------------
// Arguments:
// 	reference	string                  	as_sql           					(ref) sql syntax
// 	value    	nvo_sqlfunc_columnattrib	ao_columnattrib[]		nov_sqlfunc_columnattrib
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_sqlfunc.of_assemblecolumns ( ref string as_sql, nvo_sqlfunc_columnattrib ao_columnattrib[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String 	ls_SQL
Integer	li_index, li_count

li_count = UpperBound(ao_columnattrib[])

For li_index = 1 To li_count
	If li_index > 1 Then ls_SQL+= ', '
	ls_SQL += ao_columnattrib[li_index].is_expr
Next

as_SQL = Trim(ls_SQL)

Return li_count


end function

public function string of_assemble (nvo_sqlfunc_attrib astr_sql[]);//====================================================================
// Function: nvo_sqlfunc.of_assemble()
//--------------------------------------------------------------------
// Description:	Build a SQL statement from its component parts.
//--------------------------------------------------------------------
// Arguments:
// 	nvo_sqlfunc_attrib	astr_sql[]	Array of sql attributes, each element containing a SQL statement that will be joined with an UNION.
//--------------------------------------------------------------------
// Returns:  string	The function returns an empty string if an error was encountered.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_sqlfunc.of_assemble ( nvo_sqlfunc_attrib astr_sql[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer	li_NumStats, li_Cnt
String	ls_SQL
Integer	li_rc

li_NumStats = UpperBound(astr_sql[])

For li_Cnt = 1 To li_NumStats
	
	// Check for valid data
	If Trim(astr_sql[li_Cnt].s_Verb) = "" Or &
		Trim(astr_sql[li_Cnt].s_Tables) = "" Then
		Return ""
	End If
	
	// Added by M.K. 10.04.98
	// assemble columns
	li_rc = This.of_AssembleColumns(astr_sql[li_Cnt].s_Columns, astr_sql[li_Cnt].istr_column[])
	// end of adding
	
	// If there is more than one statement in the array, they are SELECTs that
	// should be joined by a UNION
	If li_Cnt > 1 Then
		ls_SQL = ls_SQL + " UNION "
	End If
	
	ls_SQL = ls_SQL + astr_sql[li_Cnt].s_Verb
	
	If astr_sql[li_Cnt].s_Verb = "SELECT" Then
		If Trim(astr_sql[li_Cnt].s_Columns) = "" Then
			Return ""
		Else
			ls_SQL = ls_SQL + " " + astr_sql[li_Cnt].s_Columns + &
				" FROM " + astr_sql[li_Cnt].s_Tables
		End If
		
	Else
		ls_SQL = ls_SQL + " " + astr_sql[li_Cnt].s_Tables
		
		If astr_sql[li_Cnt].s_Verb = "UPDATE" Then
			ls_SQL = ls_SQL + " SET " + astr_sql[li_Cnt].s_Columns
		ElseIf Trim(astr_sql[li_Cnt].s_Columns) <> "" Then
			ls_SQL = ls_SQL + " " + astr_sql[li_Cnt].s_Columns
		End If
	End If
	
	If Trim(astr_sql[li_Cnt].s_Values) <> "" Then
		ls_SQL = ls_SQL + " VALUES " + astr_sql[li_Cnt].s_Values
	End If
	
	If Trim(astr_sql[li_Cnt].s_Where) <> "" Then
		ls_SQL = ls_SQL + " WHERE " + astr_sql[li_Cnt].s_Where
	End If
	
	If Trim(astr_sql[li_Cnt].s_Group) <> "" Then
		ls_SQL = ls_SQL + " GROUP BY " + astr_sql[li_Cnt].s_Group
	End If
	
	If Trim(astr_sql[li_Cnt].s_Having) <> "" Then
		ls_SQL = ls_SQL + " HAVING " + astr_sql[li_Cnt].s_Having
	End If
	
	If Trim(astr_sql[li_Cnt].s_Order) <> "" Then
		ls_SQL = ls_SQL + " ORDER BY " + astr_sql[li_Cnt].s_Order
	End If
Next

Return ls_SQL


end function

public function integer of_format (ref string as_sql);//====================================================================
// Function: nvo_sqlfunc.of_format()
//--------------------------------------------------------------------
// Description:	format sql syntax.
//--------------------------------------------------------------------
// Arguments:
// 	reference	string	as_sql	(ref) sql syntax
//--------------------------------------------------------------------
// Returns:  integer 1 - ok 	-1- error
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_sqlfunc.of_format ( ref string as_sql )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String 	ls_SQL
String 	ls_token[], ls_tokentype[], ls_UserToken[]
Integer	li_index, li_count
Integer	li_ind, li_lcnt, li_rcnt
Boolean	lb_function
String	ls_Res
String	ls_word, ls_type, ls_prevword
String	ls_cr = '~r~n', ls_blank4 = Space(4), ls_blank = ' '
Integer	li_Pos
Integer	li_OffsetLevel = 1, li_BrL[], li_BrR[]
String	ls_CurrentOffset[]
Boolean	lb_NewOffset
Boolean 	lb_BlankBefore
String	ls_Offset = ''

If IsNull(as_sql) Or LenA(Trim(as_sql)) = 0 Then Return -1

ls_SQL = Trim(as_sql)

// parse sql syntax
li_count = inv_expr.of_GetTokenArray(ls_SQL, ls_token, ls_tokentype, ls_UserToken)

ls_CurrentOffset[1] = ""

For li_index = 1 To li_count
	ls_type = ls_tokentype[li_index]
	ls_word = ls_UserToken[li_index]
	
	lb_NewOffset = False
	
	Choose Case ls_type
		Case 'sql'
			
			Choose Case Lower(ls_word)
				Case 'select'
					If li_index > 1 Then // check if it is subquery
						If ls_tokentype[li_index - 1] = "lbracket" Then // '(select ...'
							li_OffsetLevel ++ // offset level
							li_BrL[li_OffsetLevel] = 1 // left bracket count
							li_BrR[li_OffsetLevel] = 0 // right bracket count
							ls_CurrentOffset[li_OffsetLevel] = Space(LenA(ls_Res) - inv_str.of_LastPos ( ls_Res, ls_cr ))
							lb_NewOffset = True
						End If
					End If
					
				Case 'into'
					//lb_NewOffset = True
					lb_NewOffset = False //MODIFY BY BAOGA INTO ENTER
					ls_CurrentOffset[li_OffsetLevel]	+= Space(8)
				Case 'insert'
					lb_NewOffset = True
				Case 'set'
					//lb_NewOffset = True
					lb_NewOffset = False //MODIFY BY BAOGA SET ENTER
					ls_CurrentOffset[li_OffsetLevel]	+= Space(8)
			End Choose
			
			If Not lb_NewOffset Then
				ls_Res+= ls_cr + ls_Offset
			End If
			ls_Res+= ' ' + Upper(ls_word) //MODIFY BY BAOGA UPPERKEYWORD
			ls_Offset = ls_CurrentOffset[li_OffsetLevel]
			
		Case 'case_operator'
			
			Choose Case Lower(ls_word)
				Case 'case', 'if'
					ls_Offset = Space(LenA(ls_Res) - inv_str.of_LastPos ( ls_Res, ls_cr ) - 1)
					ls_Res+= ' ' + Upper(ls_word) //MODIFY BY BAOGA UPPERKEYWORD
					li_OffsetLevel ++
					ls_CurrentOffset[li_OffsetLevel] = ls_Offset
				Case 'when', 'else'
					ls_Res+= ls_cr + ls_Offset
					ls_Res+= ' ' + Space(2) + Upper(ls_word) //MODIFY BY BAOGA UPPERKEYWORD
				Case 'then'
					//ls_res+=ls_cr + ls_Offset
					//ls_res+=' ' + space(4) + ls_word
					ls_Res+= ' '+Upper(ls_word) + ls_cr //MODIFY BY BAOGA UPPERKEYWORD
				Case 'end'
					ls_Res+= ls_cr + ls_Offset
					ls_Res+= ' ' + Upper(ls_word) //MODIFY BY BAOGA UPPERKEYWORD
					If li_OffsetLevel > 1 Then li_OffsetLevel -- // offset level
					ls_Offset = ls_CurrentOffset[li_OffsetLevel]
				Case Else
			End Choose
			
		Case "keyword"
			Choose Case Lower(ls_word)
				Case 'and'
					ls_Res+= ls_cr + ls_Offset
					ls_Res+= ' ' + '  ' + Upper(ls_word) //MODIFY BY BAOGA UPPERKEYWORD
				Case 'or'
					ls_Res+= ls_cr + ls_Offset
					ls_Res+= ' ' + '   '+ Upper(ls_word) //MODIFY BY BAOGA UPPERKEYWORD
				Case 'not'
					ls_Res+= ' ' + Upper(ls_word) //MODIFY BY BAOGA UPPERKEYWORD
				Case Else
			End Choose
			
		Case "constant", "null", &
			"id", "id_quoted", &
			"operator", &
			"number", "datetime", "date"
		
		If li_index > 1 Then ls_prevword = ls_UserToken[li_index - 1]
		
		Choose Case ls_prevword
			Case '/' ;
				lb_BlankBefore = ls_word <> '*'
			Case '*' ;
				lb_BlankBefore = ls_word <> '/'
			Case '-' ;
				lb_BlankBefore = ls_word <> '-'
			Case '.' ;
				lb_BlankBefore = False
			Case ':' ;
				lb_BlankBefore = False
			Case Else;
				lb_BlankBefore = True
		End Choose
		
		If lb_BlankBefore Then ls_Res+= ' '
		ls_Res+= ls_word
		
	Case "string"
		ls_Res+= ' ' + "'" + ls_word + "'"
	Case "lbracket"
		li_BrL[li_OffsetLevel]++ // increment left bracket count
		ls_Res+= ' ' + ls_word
	Case "rbracket"
		li_BrR[li_OffsetLevel]++ // increment right bracket count
		If li_BrL[li_OffsetLevel] = li_BrR[li_OffsetLevel] Then
			If li_OffsetLevel > 1 Then li_OffsetLevel --
			ls_Offset = ls_CurrentOffset[li_OffsetLevel]
		End If
		ls_Res+= ' ' + ls_word
	Case "separator"
		ls_Res+= ls_word
		
		// check if ',' is inside function !!!
		li_lcnt = 0 ;
		li_rcnt = 0
		lb_function = False
		For li_ind = li_index To 1 Step -1
			If ls_tokentype[li_ind] = "lbracket" Then li_lcnt++
			If ls_tokentype[li_ind] = "rbracket" Then li_rcnt++
			If li_lcnt > li_rcnt Then
				li_ind --
				If li_ind > 0 Then lb_function = ls_tokentype[li_ind] = "id"
				Exit
			End If
		Next
		
		If Not lb_function Then
			ls_Res+= ls_cr + ' ' + ls_Offset
			ls_Res+= '     '
			//ls_res+=ls_cr // 16.12.2002
		End If
		
	Case "dot"
		ls_Res+= ls_word
	Case "unknown"
		//ls_Res+= ls_word
	Case Else
End Choose

Next

If LeftA(ls_Res, LenA(ls_cr + ' ') ) = ( ls_cr + ' ') Then
	ls_Res = MidA(ls_Res, LenA(ls_cr + ' ')+1)
End If

as_sql = ls_Res

Return 1



end function

public function integer of_sqltype (string as_sql, ref string as_sqltype);//====================================================================
// Function: nvo_sqlfunc.of_sqltype()
//--------------------------------------------------------------------
// Description:		format sql syntax.
//--------------------------------------------------------------------
// Arguments:
// 	value    	string	as_sql    			(ref) sql syntax
// 	reference	string	as_sqltype	
//--------------------------------------------------------------------
// Returns:  integer	1 - ok	-1- error
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_sqlfunc.of_sqltype ( string as_sql, ref string as_sqltype )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String 	ls_SQL
String 	ls_token[], ls_tokentype[], ls_UserToken[]
Integer	li_index, li_count
Integer	li_ind, li_lcnt, li_rcnt
Boolean	lb_function
String	ls_Res
String	ls_word, ls_type, ls_prevword
String	ls_cr = '~r~n', ls_blank4 = Space(4), ls_blank = ' '
Integer	li_Pos
Integer	li_OffsetLevel = 1, li_BrL[], li_BrR[]
String	ls_CurrentOffset[]
Boolean	lb_NewOffset
Boolean 	lb_BlankBefore
String	ls_Offset = ''
String ls_sqltype
Boolean lb_select
Boolean lb_update, lb_insert, lb_delete, lb_begin, lb_ddl

If IsNull(as_sql) Or LenA(Trim(as_sql)) = 0 Then Return -1

ls_SQL = Trim(as_sql)

// parse sql syntax
li_count = inv_expr.of_GetTokenArray(ls_SQL, ls_token, ls_tokentype, ls_UserToken)

ls_CurrentOffset[1] = ""

For li_index = 1 To li_count
	ls_type = ls_tokentype[li_index]
	ls_word = ls_UserToken[li_index]
	
	Choose Case ls_type
		Case 'sql'
			
			Choose Case Lower(ls_word)
				Case "select"
					as_sqltype = "UPDATE"
					lb_select = True
				Case 'update', "set"
					as_sqltype = "UPDATE"
					lb_update = True
				Case 'insert', "into", "values"
					as_sqltype = "INSERT"
					lb_insert = True
				Case 'delete'
					as_sqltype = "DELETE"
					lb_delete = True
				Case 'begin'
					as_sqltype = "BLOCKSQL"
					lb_begin  = True
				Case "alter","drop","create","grant"
					as_sqltype = "DDL"
					lb_ddl  = True
			End Choose
		Case Else
	End Choose
	
Next

If lb_select And Not  (lb_update Or lb_insert Or lb_delete Or lb_begin Or  lb_ddl ) Then
	as_sqltype = "SELECT"
Else
	as_sqltype = "EXECUTE"
End If

Return 1


end function

on nvo_sqlfunc.create
call super::create
TriggerEvent( this, "constructor" )
end on

on nvo_sqlfunc.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;String 	ls_KeyWordList = "select,from,where,group,by,having,union,delete,insert,update,on,set,join,values,into"
String 	ls_UserList 	 = "select, from,where,group,by,having,union,delete,insert,update,   on,  set,  join, values,into,alter,begin,drop,create,grant"
String	ls_CaseOperator = "if,case,then,when,else,end"

inv_expr = Create nvo_exprfunc

inv_expr.of_RegKeyWord('sql', ls_KeyWordList, ls_UserList)
inv_expr.of_RegKeyWord('case_operator', ls_CaseOperator, ls_CaseOperator)


end event

event destructor;Destroy inv_expr

end event

