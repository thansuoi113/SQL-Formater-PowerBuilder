$PBExportHeader$nvo_exprfunc.sru
forward
global type nvo_exprfunc from nonvisualobject
end type
type s_token from structure within nvo_exprfunc
end type
end forward

type s_token from structure
	string		s_tokentype
	string		s_tokenlist
	string		s_userlist
	string		s_tokenArray[]
	string		s_userArray[]
end type

global type nvo_exprfunc from nonvisualobject
end type
global nvo_exprfunc nvo_exprfunc

type variables
Public:
Constant String cs_null = "null"
Constant String cs_keyword = "keyword"
Constant String cs_constant = "constant"
Constant String cs_id = "id"
Constant String cs_id_x = "id_quoted"
Constant String cs_operator = "operator"
Constant String cs_number = "number"
Constant String cs_datetime = "datetime"
Constant String cs_date = "date"
Constant String cs_string = "string"
Constant String cs_lbracket = "lbracket"
Constant String cs_rbracket = "rbracket"
Constant String cs_separator = "separator"
Constant String cs_dot = "dot"
Constant String cs_unknown = "unknown"


Protected:

Boolean ib_UnaryMinus // used for unary minus test

Private:
s_token is_KeyWords[] // keywords list

//string is_KeyWordList = "and,not,or,xor,eqv,imp,mod,è,èëè,íå"
//string is_ConstantList = "true,false,äà,íåò"

end variables

forward prototypes
public function boolean of_isvaliddate (readonly string as_expr)
public function boolean of_isvalidtime (readonly string as_expr)
public function boolean of_isvaliddate (readonly string as_expr, string as_format)
public function boolean of_isvalidtime (readonly string as_expr, string as_format)
public function boolean of_iskeyword (string as_token, ref string as_tokentype, ref string as_usertoken)
public function integer of_gettoken (ref string as_expr, ref string as_token, ref string as_tokentype, ref string as_usertoken)
protected function integer of_gettoken (ref string as_expr, ref string as_token, ref string as_tokentype)
public function integer of_regkeyword (string as_tokentype, string as_tokenlist, string as_userlist)
public function integer of_regkeyword (string as_tokentype, string as_tokenlist)
public function integer of_gettokenarray (string as_expr, ref string as_token[], ref string as_tokentype[], ref string as_usertoken[])
public function integer of_gettokenarray (string as_expr, ref string as_token[], ref string as_tokentype[])
public function boolean of_isvalidrusname (readonly string as_name)
public function boolean of_isvalidengname (readonly string as_name)
public function integer of_expandmacro (ref string as_key[], ref string as_value[], ref string as_result[], string as_startchar, string as_stopchar)
protected function string of_globalreplace (readonly string as_source, readonly string as_lookfor[], readonly string as_replacewith[])
end prototypes

public function boolean of_isvaliddate (readonly string as_expr);//====================================================================
// Function: nvo_exprfunc.of_isvaliddate()
//--------------------------------------------------------------------
// Description: Test string for valid PowerBuilder format ('yyyy-mm-dd')
//--------------------------------------------------------------------
// Arguments:
// 	readonly	string	as_expr	expression string (readonly) [as_Format]	 date format string
//--------------------------------------------------------------------
// Returns:  boolean	True if it succeeds and False if not.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_isvaliddate ( readonly string as_expr )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Boolean lb_Ret, lb_LeapYear
String  ls_Test, ls_DatePattern
Integer li_Year, li_Month, li_Day, li_Days

ls_Test = LeftA(as_expr,10)

// Test IsDate
If Not IsDate(ls_Test) Then Return False

// date must match pattern
ls_DatePattern = "[12][90][0-9][0-9]-[01][0-9]-[0-3][0-9]"
If Not Match (ls_Test, ls_DatePattern) Then Return False

// Year portion must be between from 1000 and 3000
li_Year = Integer(LeftA(ls_Test,4))

// Month portion must be between from 01 to 12
li_Month = Integer(MidA(ls_Test,6,2))

// Day portion must be between from 01 to 31
li_Day = Integer(MidA(ls_Test,9,2))
Choose Case li_Month
	Case 1,3,5,7,8,10,12
		li_Days = 31
	Case 4,6,9,11
		li_Days = 30
	Case 2
		li_Days = 28
		lb_LeapYear = Mod(li_Year,4) = 0 And Mod(li_Year,100) <> 0 And Mod(li_Year,400) = 0
		If lb_LeapYear Then li_Days = 29
	Case Else
		li_Days = -1
End Choose

// Test for valid range
lb_Ret = (li_Year >= 1000 And li_Year <= 3000) And &
	(li_Month >=    1 And li_Month <=   12) And &
	(li_Day  >=    1 And li_Day  <= li_Days)

Return lb_Ret

end function

public function boolean of_isvalidtime (readonly string as_expr);//====================================================================
// Function: nvo_exprfunc.of_isvalidtime()
//--------------------------------------------------------------------
// Description:	Test string for default valid PowerBuilder time format ('hh:mm:ss')
//--------------------------------------------------------------------
// Arguments:
// 	readonly	string	as_expr	expression string (readonly)
//--------------------------------------------------------------------
// Returns:  boolean	True if it succeeds and False if not.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_isvalidtime ( readonly string as_expr )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Return This.of_IsValidTime(as_expr, 'hh:mm:ss')

end function

public function boolean of_isvaliddate (readonly string as_expr, string as_format);//====================================================================
// Function: nvo_exprfunc.of_isvaliddate()
//--------------------------------------------------------------------
// Description:	Test string for valid date string using format
//--------------------------------------------------------------------
// Arguments:
// 	readonly	string	as_expr  		expression string (readonly)
// 	value   	string	as_format	date format string
//--------------------------------------------------------------------
// Returns:  boolean	True if it succeeds and False if not.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_isvaliddate ( readonly string as_expr, string as_format )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Boolean lb_Ret, lb_LeapYear
String  ls_Test, ls_DatePattern
Integer li_Year, li_Month, li_Day, li_Days
Integer li_Pos

ls_Test = LeftA(as_expr,LenA(as_Format))
as_Format = Lower(as_Format)

// Test IsDate
If Not IsDate(ls_Test) Then Return False

// date must match pattern
//ls_DatePattern = "[12][90][0-9][0-9]-[01][0-9]-[0-3][0-9]"
//IF Not Match (ls_Test, ls_DatePattern) Then Return False


// Get Year
li_Pos = PosA(as_Format, "yyyy")
If ( li_Pos > 0 ) Then
	li_Year = Integer( MidA(as_expr, li_Pos, 4))
Else
	li_Pos = PosA(as_Format, "yy")
	If ( li_Pos > 0 ) Then li_Year = Integer( MidA(as_expr, li_Pos, 2))
	If ( li_Year >= 50 ) Then
		li_Year+= 1900
	Else
		li_Year+= 2000
	End If
End If

// Get month
li_Pos = PosA(as_Format, "mm")
If ( li_Pos > 0 ) Then
	li_Month = Integer( MidA(as_expr, li_Pos, 2) )
Else
	li_Pos = PosA(as_Format, "m")
	If ( li_Pos > 0 ) Then li_Month = Integer( MidA(as_expr, li_Pos, 1) )
End If

// Get Day
li_Pos = PosA(as_Format, "dd")
If ( li_Pos > 0 ) Then
	li_Day = Integer( MidA(as_expr, li_Pos, 2) )
Else
	li_Pos = PosA(as_Format, "d")
	If ( li_Pos > 0 ) Then li_Day = Integer( MidA(as_expr, li_Pos, 1) )
End If

// Day portion must be between from 01 to 31
Choose Case li_Month
	Case 1,3,5,7,8,10,12
		li_Days = 31
	Case 4,6,9,11
		li_Days = 30
	Case 2
		li_Days = 28
		lb_LeapYear = Mod(li_Year,4) = 0 And Mod(li_Year,100) <> 0 And Mod(li_Year,400) = 0
		If lb_LeapYear Then li_Days = 29
	Case Else
		li_Days = -1
End Choose

// Test for valid range
lb_Ret = (li_Year >= 1000 And li_Year <= 3000) And &
	(li_Month >=    1 And li_Month <=   12) And &
	(li_Day  >=    1 And li_Day  <= li_Days)

Return lb_Ret

end function

public function boolean of_isvalidtime (readonly string as_expr, string as_format);//====================================================================
// Function: nvo_exprfunc.of_isvalidtime()
//--------------------------------------------------------------------
// Description:	Test string for valid PowerBuilder time format ('hh:mm:ss' or 'hh:mm:ss.fff' )
//--------------------------------------------------------------------
// Arguments:
// 	readonly	string	as_expr  		expression string (readonly)
// 	value   	string	as_format	time format string 
//--------------------------------------------------------------------
// Returns:  boolean	True if it succeeds and False if not.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_isvalidtime ( readonly string as_expr, string as_format )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Boolean lb_Ret
String  ls_Test, ls_TimePattern
Integer li_Hour, li_Minute, li_Second
Long	  ll_MicroSecond
Integer li_Pos

ls_Test = LeftA(as_expr,LenA(as_Format))
as_Format = Lower(as_Format)

// Test IsDate
If Not IsTime(ls_Test) Then Return False

// time must match pattern
//ls_TimePattern = "[0-9][0-9]:[0-9][0-9]:[0-9][0-9]"
//IF Not Match (ls_Test, ls_TimePattern) Then Return False


// Get Hour
li_Pos = PosA(as_Format, "hh")
If ( li_Pos > 0 ) Then
	li_Hour = Integer( MidA(as_expr, li_Pos, 2))
Else
	li_Pos = PosA(as_Format, "h")
	If ( li_Pos > 0 ) Then li_Hour = Integer( MidA(as_expr, li_Pos, 1))
End If

// Get Minute
li_Pos = PosA(as_Format, "mm")
If ( li_Pos > 0 ) Then
	li_Minute = Integer( MidA(as_expr, li_Pos, 2) )
Else
	li_Pos = PosA(as_Format, "m")
	If ( li_Pos > 0 ) Then li_Minute = Integer( MidA(as_expr, li_Pos, 1) )
End If

// Get Second
li_Pos = PosA(as_Format, "ss")
If ( li_Pos > 0 ) Then
	li_Second = Integer( MidA(as_expr, li_Pos, 2) )
Else
	li_Pos = PosA(as_Format, "s")
	If ( li_Pos > 0 ) Then li_Second = Integer( MidA(as_expr, li_Pos, 1) )
End If

// Get MicroSecond
li_Pos = PosA(as_Format, "ffffff")
If ( li_Pos > 0 ) Then
	ll_MicroSecond = Long( MidA(as_expr, li_Pos, 6) )
Else
	li_Pos = PosA(as_Format, "fff")
	If ( li_Pos > 0 ) Then ll_MicroSecond = Long( MidA(as_expr, li_Pos, 3) )
End If

// Test for valid range
lb_Ret = (li_Hour  >= 0 And li_Hour  <= 23) And &
	(li_Minute >= 0 And li_Minute <= 59) And &
	(li_Second >= 0 And li_Second <= 59) And &
	(ll_MicroSecond >= 0 And ll_MicroSecond <= 999999)

Return lb_Ret

end function

public function boolean of_iskeyword (string as_token, ref string as_tokentype, ref string as_usertoken);//====================================================================
// Function: nvo_exprfunc.of_iskeyword()
//--------------------------------------------------------------------
// Description:	test if token is keyword (look of_RegKeyWord())
//--------------------------------------------------------------------
// Arguments:
// 	value    	string	as_token    			token (eg., 'true')
// 	reference	string	as_tokentype	type of token (eg., 'logical constant')
// 	reference	string	as_usertoken	token translation (eg, 'èñòèíà')
//--------------------------------------------------------------------
// Returns:  boolean	True if it succeeds and False if not.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_iskeyword ( string as_token, ref string as_tokentype, ref string as_usertoken )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer 	li_Index, li_TokenIndex
String	ls_TokenList
String   ls_Token, ls_UserToken

// check arguments
If IsNull(as_token) Then Return False

as_UserToken = as_token

as_token = Lower(Trim(as_token))

// find array index
For li_Index = 1 To UpperBound(is_keywords)
	// find user token
	For li_TokenIndex = 1 To UpperBound(is_keywords[li_Index].s_TokenArray)
		ls_Token = is_keywords[li_Index].s_TokenArray[li_TokenIndex]
		If Lower(Trim(ls_Token)) = as_token Then
			as_TokenType = is_keywords[li_Index].s_TokenType
			as_UserToken = is_keywords[li_Index].s_UserArray[li_TokenIndex]
			Return True
		End If
	Next
Next

//as_token = ","+Lower(trim(as_token))+","
//// 	find array index
//FOR li_Index=1 TO UpperBound(is_keywords)
//		ls_TokenList = is_keywords[li_Index].s_TokenList
// 	IF Pos(","+ls_TokenList+",", ","+as_token+",") >  0 THEN // Token found
//			as_tokentype = is_keywords[li_Index].s_TokenType
//			RETURN True
//		END IF
//NEXT
//

Return False


end function

public function integer of_gettoken (ref string as_expr, ref string as_token, ref string as_tokentype, ref string as_usertoken);//====================================================================
// Function: nvo_exprfunc.of_gettoken()
//--------------------------------------------------------------------
// Description:	Extract first token from source string and remove it
//--------------------------------------------------------------------
// Arguments:
// 	reference	string	as_expr     		expression string (by ref)
// 	reference	string	as_token    		token (byr ref)
// 	reference	string	as_tokentype	type of token ('id', 'keyword',...)
// 	reference	string	as_usertoken	user token (byr ref)
//--------------------------------------------------------------------
// Returns:  integer	1 if it succeeds and -1 if an error occurs.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_gettoken ( ref string as_expr, ref string as_token, ref string as_tokentype, ref string as_usertoken )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================


Constant	Char 	symbTab = "~t", symbNL = "~n", symbCR = "~r", symbSpace = " ", &
	symbApostroph = "'", symbDoubleQuote = '"',&
	symbLBracket = "(", symbRBracket = ")",&
	symbMinus = "-", symbPlus = "+",&
	symbPoint = ".", symbComma = ","
Char		lc_CurrChar, lc_StopChar, lc_PrevChar, lc_NextChar, lc_TestChar
Integer 	li_CntPoint
Long		ll_PrevPos, ll_Pos
Boolean 	lb_Found, lb_Identificator, lb_KeyWord, lb_Constant, lb_Datetime

// test for input arguments
If ( IsNull(as_Expr) ) Then
	SetNull(as_Token)
	as_TokenType = cs_null
	SetNull(as_UserToken)
	Return 0
End If

as_Token = ""
as_TokenType = ""
as_UserToken = as_Token

// Skip whitespace
Do
	lc_CurrChar = LeftA(as_Expr, 1)
	as_Expr = MidA(as_Expr, 2)
Loop While 	lc_CurrChar = symbSpace Or &
lc_CurrChar = symbTab 	Or &
lc_CurrChar = symbNL 	Or &
lc_CurrChar = symbCR

// Unary minus test
If ( ib_UnaryMinus And lc_CurrChar = "-" )	Then
	as_Token = lc_CurrChar
	as_UserToken = as_Token
	
	//	sInput = mid (sInput, 2)
	Do
		lc_CurrChar = LeftA(as_Expr, 1)
		as_Expr = MidA(as_Expr, 2)
	Loop While 	lc_CurrChar = symbSpace Or &
	lc_CurrChar = symbTab 	Or &
	lc_CurrChar = symbNL 	Or &
	lc_CurrChar = symbCR

If ( lc_CurrChar >= "0" And lc_CurrChar <= "9" ) Then
	// unary minus ok
	// continue
Else
	// operator
	as_TokenType = cs_operator
	as_Token = "-"
	as_UserToken = as_Token
	Return 1
End If
End If


Choose Case Lower(lc_CurrChar)

	Case "0" To "9", "." // Number constant or date (PowerBuilder format:yyyy-mm-dd)
		
		// Check for dot only
		If lc_CurrChar = "." Then
			Choose Case Lower(MidA(as_Expr, 2, 1))
				Case "0" To "9" // Ok - number or date
				Case Else //	dot- so return
					as_TokenType = cs_dot
					as_Token = lc_CurrChar
					as_UserToken = as_Token
					Return 1
			End Choose
		End If
		
		// Test if Date literal (eg., 1997-05-05)
		If This.of_IsValidDate(lc_CurrChar + as_Expr) Then
			as_TokenType = cs_date
			as_Token = LeftA(lc_CurrChar + as_Expr, 10)
			as_UserToken = as_Token
			as_Expr = MidA(as_Expr, 10)
			Return 1
		End If
		
		as_TokenType = cs_number
		
		Do
			If lc_CurrChar = symbPoint Then li_CntPoint++ // test for only one decimal point (.)
			
			as_Token = as_Token + lc_CurrChar
			as_UserToken = as_Token
			lc_CurrChar = LeftA(as_Expr, 1)
			as_Expr = MidA(as_Expr, 2)
			
		Loop While	( LenA(as_Expr) >= 0 ) And &
		((lc_CurrChar >= "0" And lc_CurrChar <= "9") Or &
		(lc_CurrChar = symbPoint And li_CntPoint < 2))
	
	as_Expr = lc_CurrChar + as_Expr
	
Case "[" // [identifier]
	
	as_TokenType = cs_id_x
	
	lc_StopChar = "]"
	
	ll_PrevPos = 0
	Do
		ll_Pos = PosA(as_Expr, lc_StopChar, ll_PrevPos + 1)
		If ll_Pos > 0 Then
			lc_NextChar = MidA(as_Expr, ll_Pos + 1, 1)
			If lc_NextChar = lc_StopChar Then // test for double square brackets (']]')
				ll_PrevPos = ll_Pos + 2 // skip double symbol
				lb_Found = False
			Else
				ll_PrevPos = ll_Pos // stop serching
				lb_Found = True
			End If
		End If
	Loop While ll_Pos > 0 And Not lb_Found
	
	If lb_Found Then
		as_Token = MidA(as_Expr, 1, ll_PrevPos - 1)
		as_UserToken = as_Token
		as_Expr = MidA(as_Expr, ll_PrevPos + 1)
	Else
		// error (no pair brackets)
		as_Token = MidA(as_Expr, 1)
		as_UserToken = as_Token
		Return -1
	End If
	
	// Test for keyword
	This.of_IsKeyWord(as_Token, as_TokenType, as_UserToken)
	
	
	//		NextChar = ""
	//		PrevChar = lc_CurrChar
	//      lc_CurrChar = ""
	//      Do
	//			as_Token = as_Token + lc_CurrChar
	//			lc_CurrChar = mid(as_Expr, 1, 1)			
	//         as_Expr = Mid(as_Expr, 2)
	//      Loop until lc_CurrChar = "]" OR Len(as_Expr) = 0
	
Case "a" To "z", "_", &
	"à" To "ÿ" // Identifier or keyword.
as_TokenType = cs_id
Do
	as_Token = as_Token + lc_CurrChar
	as_UserToken = as_Token
	lc_CurrChar = LeftA(as_Expr, 1)
	lc_TestChar = Lower(lc_CurrChar)
	as_Expr = MidA(as_Expr, 2)
	lb_Identificator = (lc_TestChar >= "a" And lc_TestChar <= "z")
	lb_Identificator = lb_Identificator Or lc_CurrChar = "_" Or (lc_CurrChar >= "0" And lc_CurrChar <= "9")
	lb_Identificator = lb_Identificator Or (lc_CurrChar >= "à" And lc_CurrChar <= "ÿ")
	//         lb_Identificator = lb_Identificator Or lc_CurrChar = "]" Or lc_CurrChar = "["
	
Loop While lb_Identificator And ( LenA(as_Expr) >= 0 )
as_Expr = lc_CurrChar + as_Expr

// Test for keyword
This.of_IsKeyWord(as_Token, as_TokenType, as_UserToken)

// // Check for keyword.
//      lb_KeyWord = Pos(","+is_KeyWordList+",", ","+lower(as_Token)+",") > 0
//      If lb_KeyWord Then as_TokenType = cs_keyword
//		
//		// Check for Constant
//      lb_Constant = Pos(","+is_ConstantList+",", ","+lower(as_Token)+",") > 0
//		If lb_Constant Then as_TokenType = cs_constant


//-----   
Case "<", ">", "=" // Check for <=, >=, <>, ==
	as_TokenType = cs_operator
	as_Token = lc_CurrChar
	as_UserToken = as_Token
	lc_CurrChar = LeftA(as_Expr, 1)
	If lc_CurrChar = "=" Or lc_CurrChar = ">" Then
		as_Token = as_Token + lc_CurrChar
		as_UserToken = as_Token
		
		If ( LenA(as_Expr) = 1 ) Then Return 1
		as_Expr = MidA(as_Expr, 2)
	End If
	
Case "'" // 'string'
	as_TokenType = cs_string
	lc_NextChar = ""
	lc_PrevChar = lc_CurrChar
	lc_CurrChar = ""
	
	Do
		as_Token = as_Token + lc_CurrChar
		as_UserToken = as_Token
		//			IF ( Len(as_Expr) <= 1 ) THEN Exit
		If ( LenA(as_Expr) = 0 ) Then Exit
		lc_NextChar = MidA(as_Expr, 2, 1)
		lc_PrevChar = lc_CurrChar
		lc_CurrChar = MidA(as_Expr, 1, 1)
		as_Expr = MidA(as_Expr, 2)
	Loop Until (lc_CurrChar = symbApostroph) And &
	Not (lc_PrevChar = symbApostroph Or lc_NextChar = symbApostroph) &
	Or ( LenA(as_Expr) = 0 )

//      as_Expr = lc_CurrChar + as_Expr

Case '"' // "string"
	as_TokenType = cs_string
	lc_NextChar = ""
	lc_CurrChar = ""
	lc_PrevChar = ""
	
	Do
		as_Token = as_Token + lc_CurrChar
		as_UserToken = as_Token
		If ( LenA(as_Expr) <= 1 ) Then Exit
		lc_NextChar = MidA(as_Expr, 2, 1)
		lc_PrevChar = lc_CurrChar
		lc_CurrChar = MidA(as_Expr, 1, 1)
		as_Expr = MidA(as_Expr, 2)
	Loop Until (lc_CurrChar = symbDoubleQuote) And &
	Not (lc_PrevChar = symbDoubleQuote Or lc_NextChar = symbDoubleQuote) &
	Or ( LenA(as_Expr) = 0 )

Case "{", "#" // DateTime
	as_TokenType = cs_datetime
	lc_CurrChar = ""
	Do
		as_Token = as_Token + lc_CurrChar
		as_UserToken = as_Token
		lc_CurrChar = LeftA(as_Expr, 1)
		lb_Datetime = (lc_CurrChar >= "0" And lc_CurrChar <= "9")
		lb_Datetime = lb_Datetime Or &
			lc_CurrChar = "." Or lc_CurrChar = "-" Or lc_CurrChar = "/" Or &
			lc_CurrChar = ":" Or lc_CurrChar = " "
		
		as_Expr = MidA(as_Expr, 2)
	Loop Until ((lc_CurrChar = "}")  Or (lc_CurrChar = "#")) Or &
	( LenA(as_Expr) = 0 ) Or Not lb_Datetime

Case "+", "-", "*", "/", "\", "%", "^"
	as_TokenType = cs_operator
	as_Token = lc_CurrChar
	as_UserToken = as_Token
Case "("
	as_TokenType = cs_lbracket
	as_Token = lc_CurrChar
	as_UserToken = as_Token
Case ")"
	as_TokenType = cs_rbracket
	as_Token = lc_CurrChar
	as_UserToken = as_Token
Case ",", ";"
	as_TokenType = cs_separator
	as_Token = lc_CurrChar
	as_UserToken = as_Token
Case ":" //BAOGA 20190103
	as_TokenType = cs_operator
	as_Token = lc_CurrChar
	as_UserToken = as_Token
Case Else
	as_TokenType = cs_unknown
	as_Token = lc_CurrChar
	as_UserToken = as_Token
End Choose

//-----
Return 1


end function

protected function integer of_gettoken (ref string as_expr, ref string as_token, ref string as_tokentype);//====================================================================
// Function: nvo_exprfunc.of_gettoken()
//--------------------------------------------------------------------
// Description:	Extract first token from source string and remove it
//--------------------------------------------------------------------
// Arguments:
// 	ref	string	as_expr     			expression string (by ref)
// 	ref	string	as_token    		 	token (byr ref)
// 	ref	string	as_tokentype		type of token ('id', 'keyword',...)
//--------------------------------------------------------------------
// Returns:  integer	1 if it succeeds and -1 if an error occurs.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_gettoken ( ref string as_expr, ref string as_token, ref string as_tokentype )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String ls_UserToken

Return of_GetToken(as_Expr, as_Token, as_TokenType, ls_UserToken)


end function

public function integer of_regkeyword (string as_tokentype, string as_tokenlist, string as_userlist);//====================================================================
// Function: nvo_exprfunc.of_regkeyword()
//--------------------------------------------------------------------
// Description:	register keywords and Used with of_TokenParse() 
//--------------------------------------------------------------------
// Arguments:
// 	value	string	as_tokentype	type of token (eg., 'logical constant')
// 	value	string	as_tokenlist		list of comma-delimited tokens (eg., 'true,false')
// 	value	string	as_userlist 		list of comma-delimited user tokens (eg., 'èñòèíà,ëîæü')
//--------------------------------------------------------------------
// Returns:  integer	1 if it succeeds and -1 if error.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_regkeyword ( string as_tokentype, string as_tokenlist, string as_userlist )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer li_Index
nvo_string lnv_str

// check arguments
If IsNull(as_tokentype) Or IsNull(as_tokenlist) Then Return -1

// find array index
as_tokentype = Lower(as_tokentype)
For li_Index = 1 To UpperBound(is_keywords[])
	If as_tokentype = is_keywords[li_Index].s_TokenType Then
		Exit
	End If
Next

is_keywords[li_Index].s_TokenType = as_tokentype
is_keywords[li_Index].s_TokenList = as_tokenlist
is_keywords[li_Index].s_UserList = as_userlist

lnv_str.of_ParseToArray(as_tokenlist, ",", is_keywords[li_Index].s_TokenArray)
lnv_str.of_ParseToArray(as_userlist, ",", is_keywords[li_Index].s_UserArray)

Return 1

end function

public function integer of_regkeyword (string as_tokentype, string as_tokenlist);//====================================================================
// Function: nvo_exprfunc.of_regkeyword()
//--------------------------------------------------------------------
// Description:	register keywords and Used with of_TokenParse() 
//--------------------------------------------------------------------
// Arguments:
// 	value	string	as_tokentype	type of token (eg., 'logical constant')
// 	value	string	as_tokenlist		list of comma-delimited tokens (eg., 'true,false')
//--------------------------------------------------------------------
// Returns:  integer	1 if it succeeds and -1 if error.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_regkeyword ( string as_tokentype, string as_tokenlist )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Return of_RegKeyWord(as_TokenType, as_TokenList, as_TokenList)


end function

public function integer of_gettokenarray (string as_expr, ref string as_token[], ref string as_tokentype[], ref string as_usertoken[]);//====================================================================
// Function: nvo_exprfunc.of_gettokenarray()
//--------------------------------------------------------------------
// Description:	parse input expression into token array
//--------------------------------------------------------------------
// Arguments:
// 	value    	string	as_expr       			expression string (by ref)
// 	reference	string	as_token[]    		token's array (by ref)
// 	reference	string	as_tokentype[]		type of token's array ('id', 'keyword',...)
// 	reference	string	as_usertoken[]		user token's array (by ref)
//--------------------------------------------------------------------
// Returns:  integer	array size if it succeeds and -1 if an error occurs.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_gettokenarray ( string as_expr, ref string as_token[], ref string as_tokentype[], ref string as_usertoken[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String 	ls_Token, ls_TokenType, ls_UserToken

Integer 	li_Cnt, iNull
Constant	Char c_COMMA = ",", c_LEFTBRACKET = "("


// check input
If ( IsNull(as_Expr) ) Then Return -1

ib_UnaryMinus = True
Do While LenA(as_Expr) > 0
	This.of_GetToken(as_Expr, ls_Token, ls_TokenType, ls_UserToken)
	If ( LenA(ls_TokenType) > 0 ) Then
		li_Cnt++
		as_Token[li_Cnt] = ls_Token
		as_TokenType[li_Cnt] = ls_TokenType
		as_UserToken[li_Cnt] = ls_UserToken
		ib_UnaryMinus = ls_Token = c_LEFTBRACKET Or &
			ls_Token = c_COMMA
	End If
Loop

ib_UnaryMinus = False
Return li_Cnt


end function

public function integer of_gettokenarray (string as_expr, ref string as_token[], ref string as_tokentype[]);//====================================================================
// Function: nvo_exprfunc.of_gettokenarray()
//--------------------------------------------------------------------
// Description:	parse input expression into token array
//--------------------------------------------------------------------
// Arguments:
// 	value    	string	as_expr       			expression string (by ref)
// 	reference	string	as_token[]    		token's array (by ref)
// 	reference	string	as_tokentype[]		type of token's array ('id', 'keyword',...)
//--------------------------------------------------------------------
// Returns:  integer	array size if it succeeds and -1 if an error occurs.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_gettokenarray ( string as_expr, ref string as_token[], ref string as_tokentype[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String ls_usertoken[]
Return of_GetTokenArray(as_expr, as_token, as_tokentype, ls_usertoken)


end function

public function boolean of_isvalidrusname (readonly string as_name);//====================================================================
// Function: nvo_exprfunc.of_isvalidrusname()
//--------------------------------------------------------------------
// Description: Test if string is valid russion name
//--------------------------------------------------------------------
// Arguments:
// 	readonly	string	as_name		test string (readonly)
//--------------------------------------------------------------------
// Returns:  boolean	True if it succeeds and False if not.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_isvalidrusname ( readonly string as_name )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================


Boolean  lb_Ret
Char		lc_Char
Integer  li_Index, li_Length

If IsNull(as_Name) Or LenA(Trim(as_Name)) = 0 Then Return False


li_Length = LenA(as_Name)

// test first symbol
lc_Char = LeftA(as_Name,1)
Choose Case Lower(lc_Char)
	Case "a" To "z", "_", &
		"à" To "ÿ" // Identifier or keyword.
Case Else
	Return False
End Choose

For li_Index = 2 To li_Length
	lc_Char = MidA(as_Name, li_Index, 1)
	Choose Case Lower(lc_Char)
		Case "0" To "9"
		Case "a" To "z", "_", &
			"à" To "ÿ" // Identifier or keyword.
	Case Else
		Return False
End Choose
Next

Return True


end function

public function boolean of_isvalidengname (readonly string as_name);//====================================================================
// Function: nvo_exprfunc.of_isvalidengname()
//--------------------------------------------------------------------
// Description:	Test if string is valid english name
//--------------------------------------------------------------------
// Arguments:
// 	readonly	string	as_name		test string (readonly)
//--------------------------------------------------------------------
// Returns:  boolean	True if it succeeds and False if not.
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_isvalidengname ( readonly string as_name )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Boolean  lb_Ret
Char		lc_Char
Integer  li_Index, li_Length

If IsNull(as_Name) Or LenA(Trim(as_Name)) = 0 Then Return False


li_Length = LenA(as_Name)

// test first symbol
lc_Char = LeftA(as_Name,1)
Choose Case Lower(lc_Char)
	Case "a" To "z", "_"
	Case Else
		Return False
End Choose

For li_Index = 2 To li_Length
	lc_Char = MidA(as_Name, li_Index, 1)
	Choose Case Lower(lc_Char)
		Case "0" To "9"
		Case "a" To "z", "_"
		Case Else
			Return False
	End Choose
Next

Return True


end function

public function integer of_expandmacro (ref string as_key[], ref string as_value[], ref string as_result[], string as_startchar, string as_stopchar);//====================================================================
// Function: nvo_exprfunc.of_expandmacro()
//--------------------------------------------------------------------
// Description: expand macro 
//--------------------------------------------------------------------
// Arguments:
// 		string      	as_key[]   		key array
// 		string      	as_value[] 		key value
// 		string      	as_result[]		result of macro expanding
// 			as_startchar					macro starting char ('%')
// 			as_stopchar 				macro stopping char ('%')
//--------------------------------------------------------------------
// Returns:  integer	1 - ok	 -1- error
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_expandmacro ( ref string as_key[], ref string as_value[], ref string as_result[], string as_startchar, string as_stopchar )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String	ls_macro[]
String 	ls_value[]
String	ls_check
Integer 	li_index, li_count, li_key
Boolean	ib_Found

li_count = UpperBound(as_key[])

// set macro
For li_index = 1 To li_count
	ls_macro[li_index] = as_startchar + as_key[li_index] + as_stopchar
	ls_value[li_index] = as_value[li_index]
Next

// macro replace
Do
	For li_index = 1 To li_count
		ls_value[li_index] = This.of_GlobalReplace(ls_value[li_index], ls_macro, ls_value)
	Next
	
	// check if macro exist
	For li_key = 1 To li_count
		ls_check = Lower(ls_value[li_key])
		For li_index = 1 To li_count
			ib_Found = PosA(ls_check, Lower(ls_macro[li_index])) > 0
			If ib_Found Then Exit
		Next
		If ib_Found Then Exit
	Next
	
Loop While ib_Found

as_result[] = ls_value[]

Return 1

end function

protected function string of_globalreplace (readonly string as_source, readonly string as_lookfor[], readonly string as_replacewith[]);//====================================================================
// Function: nvo_exprfunc.of_globalreplace()
//--------------------------------------------------------------------
// Description: make several replacement.
//--------------------------------------------------------------------
// Arguments:
// 	readonly	string	as_source       	
// 	readonly	string	as_lookfor[]    	
// 	readonly	string	as_replacewith[]	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2021/11/01
//--------------------------------------------------------------------
// Usage: nvo_exprfunc.of_globalreplace ( readonly string as_source, readonly string as_lookfor[], readonly string as_replacewith[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Integer li_index, li_count
String  ls_result
nvo_string	lnv_str

ls_result = as_source

li_count = UpperBound(as_lookfor[])
For li_index = 1 To li_count
	ls_result = lnv_str.of_GlobalReplace(ls_result, as_lookfor[li_index], as_replacewith[li_index], True)
Next

Return ls_result


end function

on nvo_exprfunc.create
call super::create
TriggerEvent( this, "constructor" )
end on

on nvo_exprfunc.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;String ls_KeyWordList = "and,not,or,xor,eqv,imp,mod,è,èëè,íå"
String ls_KeyWordUser = "and,not,or,xor,eqv,imp,mod,and,or,not"

String ls_ConstantList = "true,false,äà,íåò"
String ls_ConstantUser = "true,false,true,false"

This.of_RegKeyWord(cs_keyword, ls_KeyWordList, ls_KeyWordUser)
This.of_RegKeyWord(cs_constant, ls_ConstantList, ls_ConstantUser)



end event

