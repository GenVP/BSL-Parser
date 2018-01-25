﻿
#Region Constants

Var Keywords;         // enum
Var Tokens;           // enum
Var Nodes;            // enum
Var SelectKinds;      // enum
Var Directives;       // enum
Var PrepInstructions; // enum
Var BasicLitNoString; // array (one of Tokens)
Var RelOperators;     // array (one of Tokens)
Var AddOperators;     // array (one of Tokens)
Var MulOperators;     // array (one of Tokens)
Var InitOfExpression; // array (one of Tokens)
Var EmptyArray;       // array
Var TokenMap;         // map[string] (string)
Var AlphaDigitMap;    // map[string] (string)
Var Alpha, Digit;     // string

#EndRegion // Constants

#Region Settings

Var Verbose Export;  // boolean
Var Debug Export;    // boolean
Var Location Export; // boolean

#EndRegion // Settings

#Region Init

Procedure Init()

	Verbose = False;
	Debug = False;
	Location = True;

	InitEnums();

	BasicLitNoString = New Array;
	BasicLitNoString.Add(Tokens.Number);
	BasicLitNoString.Add(Tokens.DateTime);
	BasicLitNoString.Add(Tokens.True);
	BasicLitNoString.Add(Tokens.False);
	BasicLitNoString.Add(Tokens.Undefined);
	BasicLitNoString.Add(Tokens.Null);

	RelOperators = New Array;
	RelOperators.Add(Tokens.Eql);
	RelOperators.Add(Tokens.Neq);
	RelOperators.Add(Tokens.Lss);
	RelOperators.Add(Tokens.Gtr);
	RelOperators.Add(Tokens.Leq);
	RelOperators.Add(Tokens.Geq);

	AddOperators = New Array;
	AddOperators.Add(Tokens.Add);
	AddOperators.Add(Tokens.Sub);

	MulOperators = New Array;
	MulOperators.Add(Tokens.Mul);
	MulOperators.Add(Tokens.Div);
	MulOperators.Add(Tokens.Mod);

	InitOfExpression = New Array;
	InitOfExpression.Add(Tokens.Add);
	InitOfExpression.Add(Tokens.Sub);
	InitOfExpression.Add(Tokens.Not);
	InitOfExpression.Add(Tokens.Ident);
	InitOfExpression.Add(Tokens.Lparen);
	InitOfExpression.Add(Tokens.Number);
	InitOfExpression.Add(Tokens.String);
	InitOfExpression.Add(Tokens.StringBeg);
	InitOfExpression.Add(Tokens.DateTime);
	InitOfExpression.Add(Tokens.Ternary);
	InitOfExpression.Add(Tokens.New);
	InitOfExpression.Add(Tokens.True);
	InitOfExpression.Add(Tokens.False);
	InitOfExpression.Add(Tokens.Undefined);
	InitOfExpression.Add(Tokens.Null);

	EmptyArray = New Array;

	Alpha = "Alpha";
	Digit = "Digit";

	TokenMap = New Map;
	AlphaDigitMap = New Map;

	Letters = (
		"abcdefghijklmnopqrstuvwxyz" +
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
		"абвгдеёжзийклмнопрстуфхцчшщъыьэюя" +
		"АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
	);
	Index = 1;
	Char = "_";
	While Char <> "" Do
		TokenMap[Char] = Alpha;
		AlphaDigitMap[Char] = Alpha;
		Char = Mid(Letters, Index, 1);
		Index = Index + 1;
	EndDo;

	For Index = 0 To 9 Do
		TokenMap[String(Index)] = Digit;
		AlphaDigitMap[String(Index)] = Digit;
	EndDo;

	TokenMap[""""] = Tokens.String;
	TokenMap["|"] = Tokens.String;
	TokenMap["'"] = Tokens.DateTime;
	TokenMap["="] = Tokens.Eql;
	TokenMap["+"] = Tokens.Add;
	TokenMap["-"] = Tokens.Sub;
	TokenMap["*"] = Tokens.Mul;
	TokenMap["%"] = Tokens.Mod;
	TokenMap["("] = Tokens.Lparen;
	TokenMap[")"] = Tokens.Rparen;
	TokenMap["["] = Tokens.Lbrack;
	TokenMap["]"] = Tokens.Rbrack;
	TokenMap["?"] = Tokens.Ternary;
	TokenMap[","] = Tokens.Comma;
	TokenMap["."] = Tokens.Period;
	TokenMap[":"] = Tokens.Colon;
	TokenMap[";"] = Tokens.Semicolon;
	TokenMap[""] = Tokens.Eof;

EndProcedure // Init()

Procedure InitEnums()
	Keywords = Keywords();
	Tokens = Tokens(Keywords);
	Nodes = Nodes();
	SelectKinds = SelectKinds();
	Directives = Directives();
	PrepInstructions = PrepInstructions();
EndProcedure // InitEnums()

#EndRegion // Init

#Region Enums

Function Keywords() Export
	Return Enum(New Structure,
		"If.Если, Then.Тогда, ElsIf.ИначеЕсли, Else.Иначе, EndIf.КонецЕсли,
		|For.Для, Each.Каждого, In.Из, To.По, While.Пока, Do.Цикл, EndDo.КонецЦикла,
		|Procedure.Процедура, EndProcedure.КонецПроцедуры, Function.Функция, EndFunction.КонецФункции,
		|Var.Перем, Val.Знач, Return.Возврат, Continue.Продолжить, Break.Прервать,
		|And.И, Or.Или, Not.Не,
		|Try.Попытка, Except.Исключение, Raise.ВызватьИсключение, EndTry.КонецПопытки,
		|New.Новый, Execute.Выполнить, Export.Экспорт, Goto.Перейти,
		|True.Истина, False.Ложь, Undefined.Неопределено, Null"
	);
EndFunction // Keywords()

Function Tokens(Keywords = Undefined) Export
	Var Tokens;

	If Keywords = Undefined Then
		Keywords = Keywords();
	EndIf;

	Tokens = Enum(New Structure(Keywords),

		// Literals

		"Ident, Number, String, DateTime,
		// parts of strings
		|StringBeg, StringMid, StringEnd,

		// Operators

		// =   <>    <    >   <=   >=    +    -    *    /    %
		|Eql, Neq, Lss, Gtr, Leq, Geq, Add, Sub, Mul, Div, Mod,
		//    (       )       [       ]
		|Lparen, Rparen, Lbrack, Rbrack,
		//     ?      ,       .      :          ;
		|Ternary, Comma, Period, Colon, Semicolon,

		// Preprocessor instructions
		|_If, _ElsIf, _Else, _EndIf, _Region, _EndRegion,

		// Other

		//         //          &      ~
		|Eof, Comment, Directive, Label"

	);

	Return Tokens;
EndFunction // Tokens()

Function Nodes() Export
	Return Enum(New Structure,
		"Module, Unknown, Func, Proc, VarMod, VarLoc, Param,
		|VarModListDecl, VarLocListDecl, ProcDecl, FuncDecl, PrepIfDecl, PrepElsIfDecl, PrepRegionDecl,
		|BasicLitExpr, SelectExpr, DesigExpr, UnaryExpr, BinaryExpr, NewExpr, TernaryExpr, ParenExpr, NotExpr, StringExpr,
		|AssignStmt, ReturnStmt, BreakStmt, ContinueStmt, RaiseStmt, ExecuteStmt, CallStmt, IfStmt, ElsIfStmt,
		|PrepIfStmt, PrepElsIfStmt, WhileStmt, PrepRegionStmt, ForStmt, ForEachStmt, TryStmt, GotoStmt, LabelStmt"
	);
EndFunction // Nodes()

Function SelectKinds() Export
	Return Enum(New Structure,
		"Ident," // Something._
		"Index," // Something[_]
		"Call"   // Something(_)
	);
EndFunction // SelectKinds()

Function Directives() Export
	Return Enum(New Structure,
		"AtClient.НаКлиенте,"
		"AtServer.НаСервере,"
		"AtServerNoContext.НаСервереБезКонтекста,"
		"AtClientAtServerNoContext.НаКлиентеНаСервереБезКонтекста,"
		"AtClientAtServer.НаКлиентеНаСервере"
	);
EndFunction // Directives()

Function PrepInstructions() Export
	Return Enum(New Structure,
		"If.Если,"
		"ElsIf.ИначеЕсли,"
		"Else.Иначе,"
		"EndIf.КонецЕсли,"
		"Region.Область,"
		"EndRegion.КонецОбласти"
	);
EndFunction // PrepInstructions()

Function Enum(Structure, Keys)
	Var Items, Item, ItemList, Value;

	For Each Items In StrSplit(Keys, ",", False) Do
		ItemList = StrSplit(Items, ".", False);
		Value = TrimAll(ItemList[0]);
		For Each Item In ItemList Do
			Structure.Insert(TrimAll(Item), Value);
		EndDo;
	EndDo;

	Return New FixedStructure(Structure);
EndFunction // Enum()

#EndRegion // Enums

#Region AbstractSyntaxTree

Function Module(Decls, Auto, Statements, Interface, Comments)
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Decls,"     // array (one of #Declarations)
		"Auto,"      // array (VarLoc)
		"Body,"      // array (one of #Statements)
		"Interface," // array (Func, Proc)
		"Comments"   // map[number] (string)
	, Nodes.Module, Decls, Auto, Statements, Interface, Comments);
EndFunction // Module()

#Region Scope

Function Scope(Outer)
	Return New Structure(
		"Outer,"   // undefined, structure (Scope)
		"Objects," // structure as map[string] (Unknown, Func, Proc, VarMod, VarLoc, Param)
		"Auto"     // array (VarLoc)
	, Outer, New Structure, New Array);
EndFunction // Scope()

Function Unknown(Name)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Name"  // string
	, Nodes.Unknown, Name);
EndFunction // Unknown()

Function Func(Name, Directive, Params, Exported)
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Name,"      // string
		"Directive," // string (one of Directives)
		"Params,"    // array (Param)
		"Export"     // boolean
	, Nodes.Func, Name, Directive, Params, Exported);
EndFunction // Func()

Function Proc(Name, Directive, Params, Exported)
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Name,"      // string
		"Directive," // string (one of Directives)
		"Params,"    // array (Param)
		"Export"     // boolean
	, Nodes.Proc, Name, Directive, Params, Exported);
EndFunction // Proc()

Function VarMod(Name, Directive, Exported)
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Name,"      // string
		"Directive," // string (one of Directives)
		"Export"     // boolean
	, Nodes.VarMod, Name, Directive, Exported);
EndFunction // VarMod()

Function VarLoc(Name, Auto = False)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Name," // string
		"Auto"  // boolean
	, Nodes.VarLoc, Name, Auto);
EndFunction // VarLoc()

Function Param(Name, ByVal, Value = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Name,"  // string
		"ByVal," // boolean
		"Value"  // undefined, structure (UnaryExpr, BasicLitExpr)
	, Nodes.Param, Name, ByVal, Value);
EndFunction // Param()

#EndRegion // Scope

#Region Declarations

Function VarModListDecl(Directive, VarList, Place = Undefined)
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Directive," // string (one of Directives)
		"List,"      // array (VarMod)
		"Place"      // undefined, structure (Place)
	, Nodes.VarModListDecl, Directive, VarList, Place);
EndFunction // VarModListDecl()

Function VarLocListDecl(VarList, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"List,"  // array (VarLoc)
		"Place"  // undefined, structure (Place)
	, Nodes.VarLocListDecl, VarList, Place);
EndFunction // VarLocListDecl()

Function ProcDecl(Object, Decls, Auto, Body, Place = Undefined)
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Object," // structure (Proc)
		"Decls,"  // array (one of #Declarations)
		"Auto,"   // array (VarLoc)
		"Body,"   // array (one of #Statements)
		"Place"   // undefined, structure (Place)
	, Nodes.ProcDecl, Object, Decls, Auto, Body, Place);
EndFunction // ProcDecl()

Function FuncDecl(Object, Decls, Auto, Body, Place = Undefined)
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Object," // structure (Func)
		"Decls,"  // array (one of #Declarations)
		"Auto,"   // array (VarLoc)
		"Body,"   // array (one of #Statements)
		"Place"   // undefined, structure (Place)
	, Nodes.FuncDecl, Object, Decls, Auto, Body, Place);
EndFunction // FuncDecl()

Function PrepIfDecl(Cond, ThenPart, ElsIfPart = Undefined, ElsePart = Undefined, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Cond,"  // structure (one of #Expressions)
		"Then,"  // array (one of #Declarations)
		"ElsIf," // undefined, array (PrepElsIfDecl)
		"Else,"  // undefined, array (one of #Declarations)
		"Place"  // undefined, structure (Place)
	, Nodes.PrepIfDecl, Cond, ThenPart, ElsIfPart, ElsePart, Place);
EndFunction // PrepIfDecl()

Function PrepElsIfDecl(Cond, ThenPart, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Cond,"  // structure (one of #Expressions)
		"Then,"  // array (one of #Declarations)
		"Place"  // undefined, structure (Place)
	, Nodes.PrepElsIfDecl, Cond, ThenPart, Place);
EndFunction // PrepElsIfDecl()

Function PrepRegionDecl(Name, Decls, Body, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Name,"  // structure (one of #Expressions)
		"Decls," // array (one of #Declarations)
		"Body,"  // array (one of #Statements)
		"Place"  // undefined, structure (Place)
	, Nodes.PrepRegionDecl, Name, Decls, Body, Place);
EndFunction // PrepRegionDecl()

#EndRegion // Declarations

#Region Expressions

Function BasicLitExpr(Kind, Value, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Kind,"  // string (one of Tokens)
		"Value," // undefined, string, number, boolean, date, null
		"Place"  // undefined, structure (Place)
	, Nodes.BasicLitExpr, Kind, Value, Place);
EndFunction // BasicLitExpr()

Function SelectExpr(Kind, Value, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Kind,"  // string (one of SelectKinds)
		"Value," // string, array (undefined, one of #Expressions)
		"Place"  // undefined, structure (Place)
	, Nodes.SelectExpr, Kind, Value, Place);
EndFunction // SelectExpr()

Function DesigExpr(Object, Select, Call, Place = Undefined)
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Object," // structure (Unknown, Func, Proc, VarMod, VarLoc, Param)
		"Select," // array (SelectExpr)
		"Call,"   // boolean
		"Place"   // undefined, structure (Place)
	, Nodes.DesigExpr, Object, Select, Call, Place);
EndFunction // DesigExpr()

Function UnaryExpr(Operator, Operand, Place = Undefined)
	Return New Structure( // @Node
		"Type,"     // string (one of Nodes)
		"Operator," // string (one of Tokens)
		"Operand,"  // structure (one of #Expressions)
		"Place"     // undefined, structure (Place)
	, Nodes.UnaryExpr, Operator, Operand, Place);
EndFunction // UnaryExpr()

Function BinaryExpr(Left, Operator, Right, Place = Undefined)
	Return New Structure( // @Node
		"Type,"     // string (one of Nodes)
		"Left,"     // structure (one of #Expressions)
		"Operator," // string (one of Tokens)
		"Right,"    // structure (one of #Expressions)
		"Place"     // undefined, structure (Place)
	, Nodes.BinaryExpr, Left, Operator, Right, Place);
EndFunction // BinaryExpr()

Function NewExpr(Constr, Place = Undefined)
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Constr," // structure (DesigExpr) or array (one of #Expressions)
		"Place"   // undefined, structure (Place)
	, Nodes.NewExpr, Constr, Place);
EndFunction // NewExpr()

Function TernaryExpr(Cond, ThenPart, ElsePart, Select, Place = Undefined)
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Cond,"   // structure (one of #Expressions)
		"Then,"   // structure (one of #Expressions)
		"Else,"   // structure (one of #Expressions)
		"Select," // array (SelectExpr)
		"Place"   // undefined, structure (Place)
	, Nodes.TernaryExpr, Cond, ThenPart, ElsePart, Select, Place);
EndFunction // TernaryExpr()

Function ParenExpr(Expr, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.ParenExpr, Expr, Place);
EndFunction // ParenExpr()

Function NotExpr(Expr, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.NotExpr, Expr, Place);
EndFunction // NotExpr()

Function StringExpr(ExprList, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"List," // array (BasicLitExpr)
		"Place" // undefined, structure (Place)
	, Nodes.StringExpr, ExprList, Place);
EndFunction // StringExpr()

#EndRegion // Expressions

#Region Statements

Function AssignStmt(Left, Right, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Left,"  // structure (DesigExpr)
		"Right," // structure (one of #Expressions)
		"Place"  // undefined, structure (Place)
	, Nodes.AssignStmt, Left, Right, Place);
EndFunction // AssignStmt()

Function ReturnStmt(Expr = Undefined, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // undefined, structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.ReturnStmt, Expr, Place);
EndFunction // ReturnStmt()

Function BreakStmt(Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Place" // undefined, structure (Place)
	, Nodes.BreakStmt, Place);
EndFunction // BreakStmt()

Function ContinueStmt(Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Place" // undefined, structure (Place)
	, Nodes.ContinueStmt, Place);
EndFunction // ContinueStmt()

Function RaiseStmt(Expr = Undefined, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // undefined, structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.RaiseStmt, Expr, Place);
EndFunction // RaiseStmt()

Function ExecuteStmt(Expr, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.ExecuteStmt, Expr, Place);
EndFunction // ExecuteStmt()

Function CallStmt(DesigExpr, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Desig," // structure (DesigExpr)
		"Place"  // undefined, structure (Place)
	, Nodes.CallStmt, DesigExpr, Place);
EndFunction // CallStmt()

Function IfStmt(Cond, ThenPart, ElsIfPart = Undefined, ElsePart = Undefined, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Cond,"  // structure (one of #Expressions)
		"Then,"  // array (one of #Statements)
		"ElsIf," // undefined, array (ElsIfStmt)
		"Else,"  // undefined, array (one of #Statements)
		"Place"  // undefined, structure (Place)
	, Nodes.IfStmt, Cond, ThenPart, ElsIfPart, ElsePart, Place);
EndFunction // IfStmt()

Function ElsIfStmt(Cond, ThenPart, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Cond," // structure (one of #Expressions)
		"Then," // array (one of #Statements)
		"Place" // undefined, structure (Place)
	, Nodes.ElsIfStmt, Cond, ThenPart, Place);
EndFunction // ElsIfStmt()

Function PrepIfStmt(Cond, ThenPart, ElsIfPart = Undefined, ElsePart = Undefined, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Cond,"  // structure (one of #Expressions)
		"Then,"  // array (one of #Statements)
		"ElsIf," // undefined, array (PrepElsIfStmt)
		"Else,"  // undefined, array (one of #Statements)
		"Place"  // undefined, structure (Place)
	, Nodes.PrepIfStmt, Cond, ThenPart, ElsIfPart, ElsePart, Place);
EndFunction // PrepIfStmt()

Function PrepElsIfStmt(Cond, ThenPart, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Cond," // structure (one of #Expressions)
		"Then," // array (one of #Statements)
		"Place" // undefined, structure (Place)
	, Nodes.PrepElsIfStmt, Cond, ThenPart, Place);
EndFunction // PrepElsIfStmt()

Function WhileStmt(Cond, Statements, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Cond," // structure (one of #Expressions)
		"Body," // array (one of #Statements)
		"Place" // undefined, structure (Place)
	, Nodes.WhileStmt, Cond, Statements, Place);
EndFunction // WhileStmt()

Function PrepRegionStmt(Name, Statements, Place = Undefined)
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Name," // structure (one of #Expressions)
		"Body," // array (one of #Statements)
		"Place" // undefined, structure (Place)
	, Nodes.PrepRegionStmt, Name, Statements, Place);
EndFunction // PrepRegionStmt()

Function ForStmt(DesigExpr, From, Until, Statements, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Desig," // structure (DesigExpr)
		"From,"  // structure (one of #Expressions)
		"To,"    // structure (one of #Expressions)
		"Body,"  // array (one of #Statements)
		"Place"  // undefined, structure (Place)
	, Nodes.ForStmt, DesigExpr, From, Until, Statements, Place);
EndFunction // ForStmt()

Function ForEachStmt(DesigExpr, Collection, Statements, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Desig," // structure (DesigExpr)
		"In,"    // structure (one of #Expressions)
		"Body,"  // array (one of #Statements)
		"Place"  // undefined, structure (Place)
	, Nodes.ForEachStmt, DesigExpr, Collection, Statements, Place);
EndFunction // ForEachStmt()

Function TryStmt(TryPart, ExceptPart, Place = Undefined)
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Try,"    // array (one of #Statements)
		"Except," // array (one of #Statements)
		"Place"   // undefined, structure (Place)
	, Nodes.TryStmt, TryPart, ExceptPart, Place);
EndFunction // TryStmt()

Function GotoStmt(Label, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Label," // string
		"Place"  // undefined, structure (Place)
	, Nodes.GotoStmt, Label, Place);
EndFunction // GotoStmt()

Function LabelStmt(Label, Place = Undefined)
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Label," // string
		"Place"  // undefined, structure (Place)
	, Nodes.LabelStmt, Label, Place);
EndFunction // LabelStmt()

#EndRegion // Statements

#EndRegion // AbstractSyntaxTree

#Region Parser

Function Parser(Source) Export
	Var Parser;

	Parser = New Structure( // @Class
		"Source,"    // string
		"Len,"       // number
		"Line,"      // number
		"Pos,"       // number
		"BegPos,"    // number
		"EndPos,"    // number
		"Char,"      // string
		"Tok,"       // string (one of Tokens)
		"Lit,"       // string
		"Val,"       // number, string, date, boolean, undefined, null
		"Scope,"     // structure (Scope)
		"Vars,"      // structure as map[string] (VarMod, VarLoc)
		"Methods,"   // structure as map[string] (Func, Proc)
		"Module,"    // structure (Module)
		"Unknown,"   // structure as map[string] (Unknown)
		"IsFunc,"    // boolean
		"Directive," // string (one of Directives)
		"Interface," // array (Func, Proc)
		"Comments"   // map[number] (string)
	);

	Parser.Source = Source;
	Parser.Pos = 0;
	Parser.Line = 1;
	Parser.BegPos = 0;
	Parser.EndPos = 0;
	Parser.Methods = New Structure;
	Parser.Unknown = New Structure;
	Parser.IsFunc = False;
	Parser.Interface = New Array;
	Parser.Comments = New Map;

	Parser.Len = StrLen(Source);
	Parser.Lit = "";

	OpenScope(Parser);

	Return Parser;

EndFunction // Parser()

Function Next(Parser) Export
	Var Tok, Lit, Pos, Char, Source, Beg, Prev, Comment;

	Source = Parser.Source; Char = Parser.Char; Pos = Parser.Pos;

	Parser.EndPos = Pos;

	If Right(Parser.Lit, 1) = Chars.LF Then Parser.Line = Parser.Line + 1 EndIf;

	While True Do

		Comment = False;

		// skip space
		While IsBlankString(Char) And Char <> "" Do
			If Char = Chars.LF Then Parser.Line = Parser.Line + 1 EndIf;
			Pos = Pos + 1; Char = Mid(Source, Pos, 1);
		EndDo;

		Parser.BegPos = Pos;

		Tok = TokenMap[Char];
		If Tok = Alpha Then

			// scan ident
			Beg = Pos; Pos = Pos + 1;
			While AlphaDigitMap[Mid(Source, Pos, 1)] <> Undefined Do Pos = Pos + 1 EndDo;
			Char = Mid(Source, Pos, 1); Lit = Mid(Source, Beg, Pos - Beg);

			// lookup
			If Not Keywords.Property(Lit, Tok) Then Tok = Tokens.Ident EndIf;

		ElsIf Tok = Tokens.String Then

			Beg = Pos;
			Char = """"; // cheat code
			While Char = """" Do
				Pos = Pos + 1; Char = Mid(Source, Pos, 1);
				While Char <> """" And Char <> Chars.LF And Char <> "" Do Pos = Pos + 1; Char = Mid(Source, Pos, 1) EndDo;
				If Char <> "" Then Pos = Pos + 1; Char = Mid(Source, Pos, 1) EndIf;
			EndDo;
			Lit = Mid(Source, Beg, Pos - Beg);

			Tok = StringToken(Lit);

		ElsIf Tok = Digit Then

			Beg = Pos; Pos = Pos + 1;
			While AlphaDigitMap[Mid(Source, Pos, 1)] = Digit Do Pos = Pos + 1 EndDo;
			Char = Mid(Source, Pos, 1);
			If Char = "." Then
				Pos = Pos + 1;
				While AlphaDigitMap[Mid(Source, Pos, 1)] = Digit Do Pos = Pos + 1 EndDo;
				Char = Mid(Source, Pos, 1);
			EndIf;
			Lit = Mid(Source, Beg, Pos - Beg);

			Tok = Tokens.Number;

		ElsIf Tok = Tokens.DateTime Then

			Pos = Pos + 1; Beg = Pos;
			Pos = StrFind(Source, "'",, Pos);
			If Pos = 0 Then
				Char = ""
			Else
				Lit = Mid(Source, Beg, Pos - Beg);
				Pos = Pos + 1; Char = Mid(Source, Pos, 1);
			EndIf;

		ElsIf Tok = Undefined Then

			Prev = Char;
			Pos = Pos + 1; Char = Mid(Source, Pos, 1);

			If Prev = "/" Then

				If Char = "/" Then
					// scan comment
					Beg = Pos + 1; Pos = StrFind(Source, Chars.LF,, Beg);
					Parser.Comments[Parser.Line] = Mid(Source, Beg, Pos - Beg);
					If Pos = 0 Then Char = "" Else Char = Mid(Source, Pos, 1) EndIf;
					Comment = True;
				Else
					Tok = Tokens.Div;
				EndIf;

			ElsIf Prev = "<" Then

				If Char = ">" Then
					Tok = Tokens.Neq;
					Pos = Pos + 1; Char = Mid(Source, Pos, 1);
				ElsIf Char = "=" Then
					Tok = Tokens.Leq;
					Pos = Pos + 1; Char = Mid(Source, Pos, 1);
				Else
					Tok = Tokens.Lss;
				EndIf;

			ElsIf Prev = ">" Then

				If Char = "=" Then
					Tok = Tokens.Geq;
					Pos = Pos + 1; Char = Mid(Source, Pos, 1);
				Else
					Tok = Tokens.Gtr;
				EndIf;

			ElsIf Prev = "&" Then

				// scan ident
				Beg = Pos; Pos = Pos + 1;
				While AlphaDigitMap[Mid(Source, Pos, 1)] <> Undefined Do Pos = Pos + 1 EndDo;
				Char = Mid(Source, Pos, 1); Lit = Mid(Source, Beg, Pos - Beg);

				If Not Directives.Property(Lit) Then
					Error(Parser, StrTemplate("Unknown directive: '%1'", Lit));
				EndIf;

				Tok = Tokens.Directive;

			ElsIf Prev = "#" Then

				// skip space
				While IsBlankString(Char) And Char <> "" Do
					If Char = Chars.LF Then Parser.Line = Parser.Line + 1 EndIf;
					Pos = Pos + 1; Char = Mid(Source, Pos, 1);
				EndDo;

				// scan ident
				Beg = Pos; Pos = Pos + 1;
				While AlphaDigitMap[Mid(Source, Pos, 1)] <> Undefined Do Pos = Pos + 1 EndDo;
				Char = Mid(Source, Pos, 1); Lit = Mid(Source, Beg, Pos - Beg);

				// match token
				If PrepInstructions.Property(Lit, Tok) Then Tok = "_" + Tok;
				Else Error(Parser, StrTemplate("Unknown preprocessor instruction: '%1'", Lit));
				EndIf;

			ElsIf Prev = "~" Then

				// skip space
				While IsBlankString(Char) And Char <> "" Do
					If Char = Chars.LF Then Parser.Line = Parser.Line + 1 EndIf;
					Pos = Pos + 1; Char = Mid(Source, Pos, 1);
				EndDo;

				If AlphaDigitMap[Mid(Source, Pos, 1)] = Undefined Then
					Lit = "";
				Else
					// scan ident
					Beg = Pos; Pos = Pos + 1;
					While AlphaDigitMap[Mid(Source, Pos, 1)] <> Undefined Do Pos = Pos + 1 EndDo;
					Char = Mid(Source, Pos, 1); Lit = Mid(Source, Beg, Pos - Beg);
				EndIf;

				Tok = Tokens.Label;

			Else

				Raise "Unknown char!";

			EndIf;

		Else

			Pos = Pos + 1; Char = Mid(Source, Pos, 1);

		EndIf;

		If Not Comment Then
			Break;
		EndIf;

	EndDo;

	Parser.Char = Char; Parser.Pos = Pos; Parser.Tok = Tok; Parser.Lit = Lit;

	If Tok = Tokens.Number Then
		Parser.Val = Number(Lit);
	ElsIf Tok = Tokens.True Then
		Parser.Val = True;
	ElsIf Tok = Tokens.False Then
		Parser.Val = False;
	ElsIf Tok = Tokens.DateTime Then
		Parser.Val = AsDate(Lit);
	ElsIf Left(Tok, 6) = Tokens.String Then
		Parser.Val = Mid(Lit, 2, StrLen(Lit) - 2);
	ElsIf Tok = Tokens.Null Then
		Parser.Val = Null;
	Else
		Parser.Val = Undefined;
	EndIf;

	Return Tok;

EndFunction // Next()

Function FindObject(Parser, Name)
	Var Scope, Object;
	Scope = Parser.Scope;
	Scope.Objects.Property(Name, Object);
	While Object = Undefined And Scope.Outer <> Undefined Do
		Scope = Scope.Outer;
		Scope.Objects.Property(Name, Object);
	EndDo;
	Return Object;
EndFunction // FindObject()

Function OpenScope(Parser)
	Var Scope;
	Scope = Scope(Parser.Scope);
	Parser.Scope = Scope;
	Parser.Vars = Scope.Objects;
	Return Scope;
EndFunction // OpenScope()

Function CloseScope(Parser)
	Var Scope;
	Scope = Parser.Scope.Outer;
	Parser.Scope = Scope;
	Parser.Vars = Scope.Objects;
	Return Scope;
EndFunction // CloseScope()

Procedure ParseModule(Parser) Export
	Var Decls, Auto, VarObj, Item, Statements;
	Next(Parser);
	Decls = ParseModDecls(Parser);
	Statements = ParseStatements(Parser);
	Auto = New Array;
	For Each VarObj In Parser.Scope.Auto Do
		Auto.Add(VarObj);
	EndDo;
	Parser.Module = Module(Decls, Auto, Statements, Parser.Interface, Parser.Comments);
	If Verbose Then
		For Each Item In Parser.Unknown Do
			Message(StrTemplate("Undeclared method `%1`", Item.Key));
		EndDo;
	EndIf;
	Expect(Parser, Tokens.Eof);
EndProcedure // ParseModule()

#Region ParseExpr

Function ParseExpression(Parser)
	Var Expr, Operator, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Expr = ParseAndExpr(Parser);
	While Parser.Tok = Tokens.Or Do
		Operator = Parser.Tok;
		Next(Parser);
		Expr = BinaryExpr(Expr, Operator, ParseAndExpr(Parser), Place(Parser, Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseExpression()

Function ParseAndExpr(Parser)
	Var Expr, Operator, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Expr = ParseNotExpr(Parser);
	While Parser.Tok = Tokens.And Do
		Operator = Parser.Tok;
		Next(Parser);
		Expr = BinaryExpr(Expr, Operator, ParseNotExpr(Parser), Place(Parser, Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseAndExpr()

Function ParseNotExpr(Parser)
	Var Expr, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	If Parser.Tok = Tokens.Not Then
		Next(Parser);
		Expr = NotExpr(ParseRelExpr(Parser), Place(Parser, Pos, Line));
	Else
		Expr = ParseRelExpr(Parser);
	EndIf;
	Return Expr;
EndFunction // ParseNotExpr()

Function ParseRelExpr(Parser)
	Var Expr, Operator, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Expr = ParseAddExpr(Parser);
	While RelOperators.Find(Parser.Tok) <> Undefined Do
		Operator = Parser.Tok;
		Next(Parser);
		Expr = BinaryExpr(Expr, Operator, ParseAddExpr(Parser), Place(Parser, Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseRelExpr()

Function ParseAddExpr(Parser)
	Var Expr, Operator, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Expr = ParseMulExpr(Parser);
	While AddOperators.Find(Parser.Tok) <> Undefined Do
		Operator = Parser.Tok;
		Next(Parser);
		Expr = BinaryExpr(Expr, Operator, ParseMulExpr(Parser), Place(Parser, Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseAddExpr()

Function ParseMulExpr(Parser)
	Var Expr, Operator, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Expr = ParseUnaryExpr(Parser);
	While MulOperators.Find(Parser.Tok) <> Undefined Do
		Operator = Parser.Tok;
		Next(Parser);
		Expr = BinaryExpr(Expr, Operator, ParseUnaryExpr(Parser), Place(Parser, Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseMulExpr()

Function ParseUnaryExpr(Parser)
	Var Operator, Expr, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Operator = Parser.Tok;
	If AddOperators.Find(Parser.Tok) <> Undefined Then
		Next(Parser);
		Expr = UnaryExpr(Operator, ParseOperand(Parser), Place(Parser, Pos, Line));
	ElsIf Parser.Tok = Tokens.Eof Then
		Expr = Undefined;
	Else
		Expr = ParseOperand(Parser);
	EndIf;
	Return Expr;
EndFunction // ParseUnaryExpr()

Function ParseOperand(Parser)
	Var Tok, Operand;
	Tok = Parser.Tok;
	If Tok = Tokens.String Or Tok = Tokens.StringBeg Then
		Operand = ParseStringExpr(Parser);
	ElsIf BasicLitNoString.Find(Tok) <> Undefined Then
		Operand = BasicLitExpr(Tok, Parser.Val, Place(Parser));
		Next(Parser);
	ElsIf Tok = Tokens.Ident Then
		Operand = ParseDesigExpr(Parser);
	ElsIf Tok = Tokens.Lparen Then
		Operand = ParseParenExpr(Parser);
	ElsIf Tok = Tokens.New Then
		Operand = ParseNewExpr(Parser);
	ElsIf Tok = Tokens.Ternary Then
		Operand = ParseTernaryExpr(Parser);
	Else
		Error(Parser, "Expected operand",, True);
	EndIf;
	Return Operand;
EndFunction // ParseOperand()

Function ParseStringExpr(Parser)
	Var Tok, ExprList, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Tok = Parser.Tok;
	ExprList = New Array;
	While True Do
		If Tok = Tokens.String Then
			ExprList.Add(BasicLitExpr(Tok, Parser.Val, Place(Parser)));
			Tok = Next(Parser);
			While Tok = Tokens.String Do
				ExprList.Add(BasicLitExpr(Tok, Parser.Val, Place(Parser)));
				Tok = Next(Parser);
			EndDo;
		ElsIf Tok = Tokens.StringBeg Then
			ExprList.Add(BasicLitExpr(Tok, Parser.Val, Place(Parser)));
			Tok = Next(Parser);
			While Tok = Tokens.StringMid Do
				ExprList.Add(BasicLitExpr(Tok, Parser.Val, Place(Parser)));
				Tok = Next(Parser);
			EndDo;
			If Tok <> Tokens.StringEnd Then
				Error(Parser, "Expected """,, True);
			EndIf;
			ExprList.Add(BasicLitExpr(Tok, Parser.Val, Place(Parser)));
			Tok = Next(Parser);
		Else
			Break;
		EndIf;
	EndDo;
	Return StringExpr(ExprList, Place(Parser, Pos, Line));
EndFunction // ParseStringExpr()

Function ParseNewExpr(Parser)
	Var Tok, Constr, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Tok = Next(Parser);
	If Tok = Tokens.Lparen Then
		Tok = Next(Parser);
		If Tok = Tokens.Rparen Then
			Constr = EmptyArray;
		Else
			Constr = ParseArguments(Parser);
		EndIf;
		Expect(Parser, Tokens.Rparen);
		Next(Parser);
	Else
		Constr = ParseDesigExpr(Parser);
	EndIf;
	Return NewExpr(Constr, Place(Parser, Pos, Line));
EndFunction // ParseNewExpr()

Function ParseDesigExpr(Parser, Val AllowNewVar = False, NewVar = Undefined)
	Var Name, SelectExpr, Object, List, Kind, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Name = Parser.Lit;
	Next(Parser);
	SelectExpr = ParseSelectExpr(Parser);
	If SelectExpr = Undefined Then
		Object = FindObject(Parser, Name);
		List = EmptyArray;
	Else
		AllowNewVar = False;
		Kind = SelectExpr.Kind;
		If Kind = "Call" Then
			If Not Parser.Methods.Property(Name, Object) Then
				If Not Parser.Unknown.Property(Name, Object) Then
					Object = Unknown(Name);
					Parser.Unknown.Insert(Name, Object);
				EndIf;
			EndIf;
		Else
			Object = FindObject(Parser, Name);
		EndIf;
		List = New Array;
		List.Add(SelectExpr);
		SelectExpr = ParseSelectExpr(Parser);
		While SelectExpr <> Undefined Do
			Kind = SelectExpr.Kind;
			List.Add(SelectExpr);
			SelectExpr = ParseSelectExpr(Parser);
		EndDo;
	EndIf;
	If Object = Undefined Then
		If AllowNewVar Then
			Object = VarLoc(Name, True);
			NewVar = Object;
		Else
			Object = Unknown(Name);
			If Verbose Then
				Error(Parser, StrTemplate("Undeclared identifier `%1`", Name), Pos);
			EndIf;
		EndIf;
	EndIf;
	Return DesigExpr(Object, List, Kind = SelectKinds.Call, Place(Parser, Pos, Line));
EndFunction // ParseDesigExpr()

Function ParseSelectExpr(Parser)
	Var Tok, Value, SelectExpr, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Tok = Parser.Tok;
	If Tok = Tokens.Period Then
		Next(Parser);
		If Not Keywords.Property(Parser.Lit) Then
			Expect(Parser, Tokens.Ident);
		EndIf;
		Value = Parser.Lit;
		Next(Parser);
		SelectExpr = SelectExpr(SelectKinds.Ident, Value, Place(Parser, Pos, Line));
	ElsIf Tok = Tokens.Lbrack Then
		Tok = Next(Parser);
		If Tok = Tokens.Rbrack Then
			Error(Parser, "Expected expression", Pos, True);
		EndIf;
		Value = ParseExprList(Parser);
		Expect(Parser, Tokens.Rbrack);
		Next(Parser);
		SelectExpr = SelectExpr(SelectKinds.Index, Value, Place(Parser, Pos, Line));
	ElsIf Tok = Tokens.Lparen Then
		Tok = Next(Parser);
		If Tok = Tokens.Rparen Then
			Value = EmptyArray;
		Else
			Value = ParseArguments(Parser);
		EndIf;
		Expect(Parser, Tokens.Rparen);
		Next(Parser);
		SelectExpr = SelectExpr(SelectKinds.Call, Value, Place(Parser, Pos, Line));
	EndIf;
	Return SelectExpr;
EndFunction // ParseSelectExpr()

Function ParseExprList(Parser, HeadExpr = Undefined)
	Var ExprList;
	If HeadExpr = Undefined Then
		HeadExpr = ParseExpression(Parser);
	EndIf;
	ExprList = New Array;
	ExprList.Add(HeadExpr);
	While Parser.Tok = Tokens.Comma And InitOfExpression.Find(Next(Parser)) <> Undefined Do
		ExprList.Add(ParseExpression(Parser));
	EndDo;
	Return ExprList;
EndFunction // ParseExprList()

Function ParseArguments(Parser)
	Var ExprList, ExpectExpression;
	ExprList = New Array;
	ExpectExpression = True;
	While ExpectExpression Do
		If InitOfExpression.Find(Parser.Tok) <> Undefined Then
			ExprList.Add(ParseExpression(Parser));
		Else
			ExprList.Add(Undefined);
		EndIf;
		If Parser.Tok = Tokens.Comma Then
			Next(Parser);
		Else
			ExpectExpression = False;
		EndIf;
	EndDo;
	Return ExprList;
EndFunction // ParseArguments()

Function ParseTernaryExpr(Parser)
	Var Cond, ThenPart, ElsePart, SelectList, SelectExpr, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Next(Parser);
	Expect(Parser, Tokens.Lparen);
	Next(Parser);
	Cond = ParseExpression(Parser);
	Expect(Parser, Tokens.Comma);
	Next(Parser);
	ThenPart = ParseExpression(Parser);
	Expect(Parser, Tokens.Comma);
	Next(Parser);
	ElsePart = ParseExpression(Parser);
	Expect(Parser, Tokens.Rparen);
	If Next(Parser) = Tokens.Period Then
		SelectList = New Array;
		SelectExpr = ParseSelectExpr(Parser);
		While SelectExpr <> Undefined Do
			SelectList.Add(SelectExpr);
			SelectExpr = ParseSelectExpr(Parser);
		EndDo;
	Else
		SelectList = EmptyArray;
	EndIf;
	Return TernaryExpr(Cond, ThenPart, ElsePart, SelectList, Place(Parser, Pos, Line));
EndFunction // ParseTernaryExpr()

Function ParseParenExpr(Parser)
	Var Expr, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Next(Parser);
	Expr = ParseExpression(Parser);
	Expect(Parser, Tokens.Rparen);
	Next(Parser);
	Return ParenExpr(Expr, Place(Parser, Pos, Line));
EndFunction // ParseParenExpr()

#EndRegion // ParseExpr

#Region ParseDecl

Function ParseModDecls(Parser)
	Var Tok, Decls;
	Decls = ParseModVarDecls(Parser);
	Tok = Parser.Tok;
	While True Do
		If Tok = Tokens.Function Then
			Decls.Add(ParseFuncDecl(Parser));
		ElsIf Tok = Tokens.Procedure Then
			Decls.Add(ParseProcDecl(Parser));
		ElsIf Tok = Tokens._Region Then
			Decls.Add(ParsePrepRegionDecl(Parser));
		ElsIf Tok = Tokens._If Then
			Decls.Add(ParsePrepIfDecl(Parser));
		Else
			Break;
		EndIf;
		Tok = Parser.Tok;
		Parser.Directive = Undefined;
		While Tok = Tokens.Directive Do
			Parser.Directive = Parser.Lit;
			Tok = Next(Parser);
		EndDo;
	EndDo;
	Return Decls;
EndFunction // ParseModDecls()

Function ParseModVarDecls(Parser)
	Var Tok, Decls;
	Decls = New Array;
	Tok = Parser.Tok;
	While Tok = Tokens.Directive Do
		Parser.Directive = Parser.Lit;
		Tok = Next(Parser);
	EndDo;
	While Tok = Tokens.Var Do
		Next(Parser);
		Decls.Add(ParseModVarListDecl(Parser));
		Expect(Parser, Tokens.Semicolon);
		Tok = Next(Parser);
		Parser.Directive = Undefined;
		While Tok = Tokens.Directive Do
			Parser.Directive = Parser.Lit;
			Tok = Next(Parser);
		EndDo;
	EndDo;
	Return Decls;
EndFunction // ParseModVarDecls()

Function ParseModVarListDecl(Parser)
	Var VarList, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	VarList = New Array;
	VarList.Add(ParseVarMod(Parser));
	While Parser.Tok = Tokens.Comma Do
		Next(Parser);
		VarList.Add(ParseVarMod(Parser));
	EndDo;
	Return VarModListDecl(Parser.Directive, VarList, Place(Parser, Pos, Line));
EndFunction // ParseModVarListDecl()

Function ParseVarMod(Parser)
	Var Name, Object, Exported, Pos;
	Pos = Parser.BegPos;
	Expect(Parser, Tokens.Ident);
	Name = Parser.Lit;
	If Next(Parser) = Tokens.Export Then
		Exported = True;
		Next(Parser);
	Else
		Exported = False;
	EndIf;
	Object = VarMod(Name, Parser.Directive, Exported);
	If Exported Then
		Parser.Interface.Add(Object);
	EndIf;
	If Parser.Vars.Property(Name) Then
		Error(Parser, "Identifier already declared", Pos, True);
	EndIf;
	Parser.Vars.Insert(Name, Object);
	Return Object;
EndFunction // ParseVarMod()

Function ParseVarDecls(Parser)
	Var Tok, Decls;
	Decls = New Array;
	Tok = Parser.Tok;
	While Tok = Tokens.Var Do
		Next(Parser);
		Decls.Add(ParseVarListDecl(Parser));
		Expect(Parser, Tokens.Semicolon);
		Tok = Next(Parser);
	EndDo;
	Return Decls;
EndFunction // ParseVarDecls()

Function ParseVarListDecl(Parser)
	Var VarList, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	VarList = New Array;
	VarList.Add(ParseVarLoc(Parser));
	While Parser.Tok = Tokens.Comma Do
		Next(Parser);
		VarList.Add(ParseVarLoc(Parser));
	EndDo;
	Return VarLocListDecl(VarList, Place(Parser, Pos, Line));
EndFunction // ParseVarListDecl()

Function ParseVarLoc(Parser)
	Var Name, Object, Exported, Pos;
	Pos = Parser.BegPos;
	Expect(Parser, Tokens.Ident);
	Name = Parser.Lit;
	Object = VarLoc(Name);
	If Parser.Vars.Property(Name) Then
		Error(Parser, "Identifier already declared", Pos, True);
	EndIf;
	Parser.Vars.Insert(Name, Object);
	Next(Parser);
	Return Object;
EndFunction // ParseVarLoc()

Function ParseFuncDecl(Parser)
	Var Object, Name, Decls, ParamList, Exported, Statements, Auto, VarObj, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Exported = False;
	Next(Parser);
	Expect(Parser, Tokens.Ident);
	Name = Parser.Lit;
	Next(Parser);
	OpenScope(Parser);
	ParamList = ParseParamList(Parser);
	If Parser.Tok = Tokens.Export Then
		Exported = True;
		Next(Parser);
	EndIf;
	If Parser.Unknown.Property(Name, Object) Then
		Object.Type = Nodes.Func;
		Object.Insert("Directive", Parser.Directive);
		Object.Insert("Params", ParamList);
		Object.Insert("Export", Exported);
		Parser.Unknown.Delete(Name);
	Else
		Object = Func(Name, Parser.Directive, ParamList, Exported);
	EndIf;
	If Parser.Methods.Property(Name) Then
		Error(Parser, "Method already declared", Pos, True);
	EndIf;
	Parser.Methods.Insert(Name, Object);
	If Exported Then
		Parser.Interface.Add(Object);
	EndIf;
	Decls = ParseVarDecls(Parser);
	Parser.IsFunc = True;
	Statements = ParseStatements(Parser);
	Parser.IsFunc = False;
	Expect(Parser, Tokens.EndFunction);
	Auto = New Array;
	For Each VarObj In Parser.Scope.Auto Do
		Auto.Add(VarObj);
	EndDo;
	CloseScope(Parser);
	Next(Parser);
	Return FuncDecl(Object, Decls, Auto, Statements, Place(Parser, Pos, Line));
EndFunction // ParseFuncDecl()

Function ParseProcDecl(Parser)
	Var Object, Name, Decls, ParamList, Exported, Auto, VarObj, Statements, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Exported = False;
	Next(Parser);
	Expect(Parser, Tokens.Ident);
	Name = Parser.Lit;
	Next(Parser);
	OpenScope(Parser);
	ParamList = ParseParamList(Parser);
	If Parser.Tok = Tokens.Export Then
		Exported = True;
		Next(Parser);
	EndIf;
	If Parser.Unknown.Property(Name, Object) Then
		Object.Type = Nodes.Proc;
		Object.Insert("Directive", Parser.Directive);
		Object.Insert("Params", ParamList);
		Object.Insert("Export", Exported);
		Parser.Unknown.Delete(Name);
	Else
		Object = Proc(Name, Parser.Directive, ParamList, Exported);
	EndIf;
	If Parser.Methods.Property(Name) Then
		Error(Parser, "Method already declared", Pos, True);
	EndIf;
	Parser.Methods.Insert(Name, Object);
	If Exported Then
		Parser.Interface.Add(Object);
	EndIf;
	Decls = ParseVarDecls(Parser);
	Statements = ParseStatements(Parser);
	Expect(Parser, Tokens.EndProcedure);
	Auto = New Array;
	For Each VarObj In Parser.Scope.Auto Do
		Auto.Add(VarObj);
	EndDo;
	CloseScope(Parser);
	Next(Parser);
	Return ProcDecl(Object, Decls, Auto, Statements, Place(Parser, Pos, Line));
EndFunction // ParseProcDecl()

Function ParseParamList(Parser)
	Var ParamList;
	Expect(Parser, Tokens.Lparen);
	Next(Parser);
	If Parser.Tok = Tokens.Rparen Then
		ParamList = EmptyArray;
	Else
		ParamList = New Array;
		ParamList.Add(ParseParameter(Parser));
		While Parser.Tok = Tokens.Comma Do
			Next(Parser);
			ParamList.Add(ParseParameter(Parser));
		EndDo;
	EndIf;
	Expect(Parser, Tokens.Rparen);
	Next(Parser);
	Return ParamList;
EndFunction // ParseParamList()

Function ParseParameter(Parser)
	Var Name, Object, ByVal, Pos;
	Pos = Parser.BegPos;
	If Parser.Tok = Tokens.Val Then
		ByVal = True;
		Next(Parser);
	Else
		ByVal = False;
	EndIf;
	Expect(Parser, Tokens.Ident);
	Name = Parser.Lit;
	If Next(Parser) = Tokens.Eql Then
		Next(Parser);
		Object = Param(Name, ByVal, ParseUnaryExpr(Parser));
	Else
		Object = Param(Name, ByVal);
	EndIf;
	If Parser.Vars.Property(Name) Then
		Error(Parser, "Identifier already declared", Pos, True);
	EndIf;
	Parser.Vars.Insert(Name, Object);
	Return Object;
EndFunction // ParseParameter()

Function ParsePrepIfDecl(Parser)
	Var Tok, Cond, ThenPart, ElsePart;
	Var ElsIfPart, ElsIfCond, ElsIfThen, BegPos, Pos, Line;
	BegPos = Parser.BegPos;
	Line = Parser.Line;
	Next(Parser);
	Cond = ParseExpression(Parser); // todo: only logic operators
	Expect(Parser, Tokens.Then);
	Next(Parser);
	ThenPart = ParseModDecls(Parser);
	Tok = Parser.Tok;
	If Tok = Tokens._ElsIf Then
		ElsIfPart = New Array;
		While Tok = Tokens._ElsIf Do
			Pos = Parser.BegPos;
			Line = Parser.Line;
			Next(Parser);
			ElsIfCond = ParseExpression(Parser);
			Expect(Parser, Tokens.Then);
			Next(Parser);
			ElsIfThen = ParseModDecls(Parser);
			ElsIfPart.Add(PrepElsIfDecl(ElsIfCond, ElsIfThen, Place(Parser, Pos, Line)));
			Tok = Parser.Tok;
		EndDo;
	EndIf;
	If Tok = Tokens._Else Then
		Next(Parser);
		ElsePart = ParseModDecls(Parser);
	EndIf;
	Expect(Parser, Tokens._EndIf);
	Next(Parser);
	Return PrepIfDecl(Cond, ThenPart, ElsIfPart, ElsePart, Place(Parser, BegPos, Line));
EndFunction // ParsePrepIfDecl()

Function ParsePrepRegionDecl(Parser)
	Var Name, Decls, Statements, Region, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Next(Parser);
	Expect(Parser, Tokens.Ident);
	Name = Parser.Lit;
	Next(Parser);
	Decls = ParseModDecls(Parser);
	Statements = ParseStatements(Parser);
	Expect(Parser, Tokens._EndRegion);
	Next(Parser);
	Return PrepRegionDecl(Name, Decls, Statements, Place(Parser, Pos, Line));
EndFunction // ParsePrepRegionDecl()

#EndRegion // ParseDecl

#Region ParseStmt

Function ParseStatements(Parser)
	Var Statements, Stmt;
	Statements = New Array;
	Stmt = ParseStmt(Parser);
	If Stmt <> Undefined Then
		Statements.Add(Stmt);
	EndIf;
	While Parser.Tok = Tokens.Semicolon Do
		Next(Parser);
		Stmt = ParseStmt(Parser);
		If Stmt <> Undefined Then
			Statements.Add(Stmt);
		EndIf;
	EndDo;
	Return Statements;
EndFunction // ParseStatements()

Function ParseStmt(Parser)
	Var Tok, Stmt, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Tok = Parser.Tok;
	If Tok = Tokens.Ident Then
		Stmt = ParseAssignOrCallStmt(Parser);
	ElsIf Tok = Tokens.If Then
		Stmt = ParseIfStmt(Parser);
	ElsIf Tok = Tokens.Try Then
		Stmt = ParseTryStmt(Parser);
	ElsIf Tok = Tokens.While Then
		Stmt = ParseWhileStmt(Parser);
	ElsIf Tok = Tokens.For Then
		If Next(Parser) = Tokens.Each Then
			Stmt = ParseForEachStmt(Parser);
		Else
			Stmt = ParseForStmt(Parser);
		EndIf;
	ElsIf Tok = Tokens.Return Then
		Stmt = ParseReturnStmt(Parser);
	ElsIf Tok = Tokens.Break Then
		Next(Parser);
		Stmt = BreakStmt();
	ElsIf Tok = Tokens.Continue Then
		Next(Parser);
		Stmt = ContinueStmt();
	ElsIf Tok = Tokens.Raise Then
		Stmt = ParseRaiseStmt(Parser);
	ElsIf Tok = Tokens.Execute Then
		Stmt = ParseExecuteStmt(Parser);
	ElsIf Tok = Tokens.Goto Then
		Stmt = ParseGotoStmt(Parser);
	ElsIf Tok = Tokens.Label Then
		Stmt = LabelStmt(Parser.Lit);
		Next(Parser);
		Expect(Parser, Tokens.Colon);
		Parser.Tok = Tokens.Semicolon; // cheat code
	ElsIf Tok = Tokens._Region Then
		Stmt = ParsePrepRegionStmt(Parser);
	ElsIf Tok = Tokens._If Then
		Stmt = ParsePrepIfStmt(Parser);
	ElsIf Tok = Tokens.Semicolon Then
		// NOP
	EndIf;
	If Stmt <> Undefined Then
		Stmt.Place = Place(Parser, Pos, Line);
	EndIf;
	Return Stmt;
EndFunction // ParseStmt()

Function ParseRaiseStmt(Parser)
	Var Tok, Expr;
	Next(Parser);
	If InitOfExpression.Find(Parser.Tok) <> Undefined Then
		Expr = ParseExpression(Parser);
	EndIf;
	Return RaiseStmt(Expr);
EndFunction // ParseRaiseStmt()

Function ParseExecuteStmt(Parser)
	Var Expr;
	Next(Parser);
	Return ExecuteStmt(ParseExpression(Parser));
EndFunction // ParseExecuteStmt()

Function ParseAssignOrCallStmt(Parser)
	Var Left, Right, Stmt, NewVar;
	Left = ParseDesigExpr(Parser, True, NewVar);
	If Left.Call Then
		Stmt = CallStmt(Left);
	Else
		Expect(Parser, Tokens.Eql);
		Next(Parser);
		Right = ParseExpression(Parser);
		If NewVar <> Undefined Then
			Parser.Vars.Insert(NewVar.Name, NewVar);
			Parser.Scope.Auto.Add(NewVar);
		EndIf;
		Stmt = AssignStmt(Left, Right);
	EndIf;
	Return Stmt;
EndFunction // ParseAssignOrCallStmt()

Function ParseIfStmt(Parser)
	Var Tok, Cond, ThenPart, ElsePart;
	Var ElsIfPart, ElsIfCond, ElsIfThen, Pos, Line;
	Next(Parser);
	Cond = ParseExpression(Parser);
	Expect(Parser, Tokens.Then);
	Next(Parser);
	ThenPart = ParseStatements(Parser);
	Tok = Parser.Tok;
	If Tok = Tokens.ElsIf Then
		ElsIfPart = New Array;
		While Tok = Tokens.ElsIf Do
			Pos = Parser.BegPos;
			Line = Parser.Line;
			Next(Parser);
			ElsIfCond = ParseExpression(Parser);
			Expect(Parser, Tokens.Then);
			Next(Parser);
			ElsIfThen = ParseStatements(Parser);
			ElsIfPart.Add(ElsIfStmt(ElsIfCond, ElsIfThen, Place(Parser, Pos, Line)));
			Tok = Parser.Tok;
		EndDo;
	EndIf;
	If Tok = Tokens.Else Then
		Next(Parser);
		ElsePart = ParseStatements(Parser);
	EndIf;
	Expect(Parser, Tokens.EndIf);
	Next(Parser);
	Return IfStmt(Cond, ThenPart, ElsIfPart, ElsePart);
EndFunction // ParseIfStmt()

Function ParseTryStmt(Parser)
	Var TryPart, ExceptPart;
	Next(Parser);
	TryPart = ParseStatements(Parser);
	Expect(Parser, Tokens.Except);
	Next(Parser);
	ExceptPart = ParseStatements(Parser);
	Expect(Parser, Tokens.EndTry);
	Next(Parser);
	Return TryStmt(TryPart, ExceptPart);
EndFunction // ParseTryStmt()

Function ParseWhileStmt(Parser)
	Var Cond, Statements;
	Next(Parser);
	Cond = ParseExpression(Parser);
	Expect(Parser, Tokens.Do);
	Next(Parser);
	Statements = ParseStatements(Parser);
	Expect(Parser, Tokens.EndDo);
	Next(Parser);
	Return WhileStmt(Cond, Statements);
EndFunction // ParseWhileStmt()

Function ParseForStmt(Parser)
	Var DesigExpr, From, Until, Statements, VarPos, NewVar;
	Expect(Parser, Tokens.Ident);
	VarPos = Parser.BegPos;
	DesigExpr = ParseDesigExpr(Parser, True, NewVar);
	If DesigExpr.Call Then
		Error(Parser, "Expected variable", VarPos, True);
	EndIf;
	Expect(Parser, Tokens.Eql);
	Next(Parser);
	From = ParseExpression(Parser);
	Expect(Parser, Tokens.To);
	Next(Parser);
	Until = ParseExpression(Parser);
	If NewVar <> Undefined Then
		Parser.Vars.Insert(NewVar.Name, NewVar);
		Parser.Scope.Auto.Add(NewVar);
	EndIf;
	Expect(Parser, Tokens.Do);
	Next(Parser);
	Statements = ParseStatements(Parser);
	Expect(Parser, Tokens.EndDo);
	Next(Parser);
	Return ForStmt(DesigExpr, From, Until, Statements);
EndFunction // ParseForStmt()

Function ParseForEachStmt(Parser)
	Var DesigExpr, Left, Right, Collection, Statements, VarPos, NewVar;
	Next(Parser);
	Expect(Parser, Tokens.Ident);
	VarPos = Parser.BegPos;
	DesigExpr = ParseDesigExpr(Parser, True, NewVar);
	If DesigExpr.Call Then
		Error(Parser, "Expected variable", VarPos, True);
	EndIf;
	Expect(Parser, Tokens.In);
	Next(Parser);
	Collection = ParseExpression(Parser);
	If NewVar <> Undefined Then
		Parser.Vars.Insert(NewVar.Name, NewVar);
		Parser.Scope.Auto.Add(NewVar);
	EndIf;
	Expect(Parser, Tokens.Do);
	Next(Parser);
	Statements = ParseStatements(Parser);
	Expect(Parser, Tokens.EndDo);
	Next(Parser);
	Return ForEachStmt(DesigExpr, Collection, Statements);
EndFunction // ParseForEachStmt()

Function ParseGotoStmt(Parser)
	Var Label;
	Next(Parser);
	Expect(Parser, Tokens.Label);
	Label = Parser.Lit;
	Next(Parser);
	Return GotoStmt(Label);
EndFunction // ParseGotoStmt()

Function ParseReturnStmt(Parser)
	Var Expr, Pos, Line;
	Pos = Parser.BegPos;
	Line = Parser.Line;
	Next(Parser);
	If Parser.IsFunc Then
		Expr = ParseExpression(Parser);
	EndIf;
	Return ReturnStmt(Expr, Place(Parser, Pos, Line));
EndFunction // ParseReturnStmt()

Function ParsePrepIfStmt(Parser)
	Var Tok, Cond, ThenPart, ElsePart;
	Var ElsIfPart, ElsIfCond, ElsIfThen, Pos, Line;
	Next(Parser);
	Cond = ParseExpression(Parser); // todo: only logic operators
	Expect(Parser, Tokens.Then);
	Next(Parser);
	ThenPart = ParseStatements(Parser);
	Tok = Parser.Tok;
	If Tok = Tokens._ElsIf Then
		ElsIfPart = New Array;
		While Tok = Tokens._ElsIf Do
			Pos = Parser.BegPos;
			Line = Parser.Line;
			Next(Parser);
			ElsIfCond = ParseExpression(Parser);
			Expect(Parser, Tokens.Then);
			Next(Parser);
			ElsIfThen = ParseStatements(Parser);
			ElsIfPart.Add(PrepElsIfStmt(ElsIfCond, ElsIfThen, Place(Parser, Pos, Line)));
			Tok = Parser.Tok;
		EndDo;
	EndIf;
	If Tok = Tokens._Else Then
		Next(Parser);
		ElsePart = ParseStatements(Parser);
	EndIf;
	Expect(Parser, Tokens._EndIf);
	Parser.Tok = Tokens.Semicolon; // cheat code
	Return PrepIfStmt(Cond, ThenPart, ElsIfPart, ElsePart);
EndFunction // ParsePrepIfStmt()

Function ParsePrepRegionStmt(Parser)
	Var Name, Statements;
	Next(Parser);
	Expect(Parser, Tokens.Ident);
	Name = Parser.Lit;
	Next(Parser);
	Statements = ParseStatements(Parser);
	Expect(Parser, Tokens._EndRegion);
	Parser.Tok = Tokens.Semicolon; // cheat code
	Return PrepRegionStmt(Name, Statements);
EndFunction // ParsePrepRegionStmt()

#EndRegion // ParseStmt

#EndRegion // Parser

#Region Auxiliary

Function Place(Parser, Pos = Undefined, Line = Undefined)
	Var Place, Len;
	If Location Then
		If Pos = Undefined Then
			Len = StrLen(Parser.Lit);
			Pos = Parser.Pos - Len;
		Else
			Len = Parser.EndPos - Pos;
		EndIf;
		If Line = Undefined Then
			Line = Parser.Line;
		EndIf;
		Place = New Structure(
			"Line," // number
			"Pos,"  // number
			"Len"   // number
		, Line, Pos, Len);
		If Debug Then
			Place.Insert("Str", Mid(Parser.Source, Pos, Len));
		EndIf;
	EndIf;
	Return Place;
EndFunction // Place()

Function AsDate(DateLit)
	Var List, Char, Num;
	List = New Array;
	For Num = 1 To StrLen(DateLit) Do
		Char = Mid(DateLit, Num, 1);
		If AlphaDigitMap[Char] = Digit Then
			List.Add(Char);
		EndIf;
	EndDo;
	Return Date(StrConcat(List));
EndFunction // AsDate()

Procedure Expect(Parser, Tok)
	If Parser.Tok <> Tok Then
		Error(Parser, "Expected " + Tok,, True);
	EndIf;
EndProcedure // Expect()

Function StringToken(Lit)
	Var Tok;
	If Left(Lit, 1) = """" Then
		If Right(Lit, 1) = """" Then
			Tok = Tokens.String;
		Else
			Tok = Tokens.StringBeg;
		EndIf;
	Else // |
		If Right(Lit, 1) = """" Then
			Tok = Tokens.StringEnd;
		Else
			Tok = Tokens.StringMid;
		EndIf;
	EndIf;
	Return Tok;
EndFunction // StringToken()

Procedure Error(Parser, Note, Pos = Undefined, Stop = False)
	Var ErrorText;
	If Pos = Undefined Then
		Pos = Min(Parser.Pos - StrLen(Parser.Lit), Parser.Len);
	EndIf;
	ErrorText = StrTemplate("[ Ln: %1; Col: %2 ] %3",
		StrOccurrenceCount(Mid(Parser.Source, 1, Pos), Chars.LF) + 1,
		Pos - StrFind(Parser.Source, Chars.LF, SearchDirection.FromEnd, Pos),
		Note
	);
	If Stop Then
		Raise ErrorText;
	Else
		Message(ErrorText);
	EndIf;
EndProcedure // Error()

#EndRegion // Auxiliary

#Region Visitor

Function Visitor(Hooks) Export
	Var Visitor;

	Visitor = New Structure( // @Class
		"Hooks,"    // structure as map[string] (array)
		"Stack,"    // structure
		"Counters"  // structure as map[string] (number)
	);

	Visitor.Hooks = Hooks;
	Visitor.Stack = New FixedStructure("Outer, Parent", Undefined, Undefined);

	Counters = New Structure;
	Visitor.Counters = Counters;
	For Each Item In Nodes Do
		Counters.Insert(Item.Key, 0);
	EndDo;

	Return Visitor;
EndFunction // Visitor()

Procedure PushInfo(Visitor, Parent)
	Visitor.Stack = New FixedStructure("Outer, Parent", Visitor.Stack, Parent);
	NodeType = Parent.Type;
	Visitor.Counters[NodeType] = Visitor.Counters[NodeType] + 1;
EndProcedure // PushInfo()

Procedure PopInfo(Visitor)
	NodeType = Visitor.Stack.Parent.Type;
	Visitor.Counters[NodeType] = Visitor.Counters[NodeType] - 1;
	Visitor.Stack = Visitor.Stack.Outer;
EndProcedure // PopInfo()

Function Hooks() Export

	Hooks = New Structure(
		"VisitModule,         AfterVisitModule,"
		"VisitDeclarations,   AfterVisitDeclarations,"
		"VisitStatements,     AfterVisitStatements,"
		"VisitDecl,           AfterVisitDecl,"
		"VisitVarModListDecl, AfterVisitVarModListDecl,"
		"VisitVarLocListDecl, AfterVisitVarLocListDecl,"
		"VisitProcDecl,       AfterVisitProcDecl,"
		"VisitFuncDecl,       AfterVisitFuncDecl,"
		"VisitPrepIfDecl,     AfterVisitPrepIfDecl,"
		"VisitPrepElsIfDecl,  AfterVisitPrepElsIfDecl,"
		"VisitPrepRegionDecl, AfterVisitPrepRegionDecl,"
		"VisitExpr,           AfterVisitExpr,"
		"VisitBasicLitExpr,   AfterVisitBasicLitExpr,"
		"VisitDesigExpr,      AfterVisitDesigExpr,"
		"VisitUnaryExpr,      AfterVisitUnaryExpr,"
		"VisitBinaryExpr,     AfterVisitBinaryExpr,"
		"VisitNewExpr,        AfterVisitNewExpr,"
		"VisitTernaryExpr,    AfterVisitTernaryExpr,"
		"VisitParenExpr,      AfterVisitParenExpr,"
		"VisitNotExpr,        AfterVisitNotExpr,"
		"VisitStringExpr,     AfterVisitStringExpr,"
		"VisitStmt,           AfterVisitStmt,"
		"VisitAssignStmt,     AfterVisitAssignStmt,"
		"VisitReturnStmt,     AfterVisitReturnStmt,"
		"VisitBreakStmt,      AfterVisitBreakStmt,"
		"VisitContinueStmt,   AfterVisitContinueStmt,"
		"VisitRaiseStmt,      AfterVisitRaiseStmt,"
		"VisitExecuteStmt,    AfterVisitExecuteStmt,"
		"VisitCallStmt,       AfterVisitCallStmt,"
		"VisitIfStmt,         AfterVisitIfStmt,"
		"VisitElsIfStmt,      AfterVisitElsIfStmt,"
		"VisitPrepIfStmt,     AfterVisitPrepIfStmt,"
		"VisitPrepElsIfStmt,  AfterVisitPrepElsIfStmt,"
		"VisitWhileStmt,      AfterVisitWhileStmt,"
		"VisitPrepRegionStmt, AfterVisitPrepRegionStmt,"
		"VisitForStmt,        AfterVisitForStmt,"
		"VisitForEachStmt,    AfterVisitForEachStmt,"
		"VisitTryStmt,        AfterVisitTryStmt,"
		"VisitGotoStmt,       AfterVisitGotoStmt,"
		"VisitLabelStmt,      AfterVisitLabelStmt"
	);
	For Each Item In Hooks Do
		Hooks[Item.Key] = New Array;
	EndDo;

	Return Hooks;

EndFunction // Hooks()

Procedure VisitModule(Visitor, Module) Export
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitModule Do
		Hook.VisitModule(Module, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, Module);
	VisitDeclarations(Visitor, Module.Decls);
	VisitStatements(Visitor, Module.Body);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitModule Do
		Hook.AfterVisitModule(Module, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitModule()

Procedure VisitDeclarations(Visitor, Declarations)
	Var Decl, Hook;
	For Each Hook In Visitor.Hooks.VisitDeclarations Do
		Hook.VisitDeclarations(Declarations, Visitor.Stack, Visitor.Counters);
	EndDo;
	For Each Decl In Declarations Do
		VisitDecl(Visitor, Decl);
	EndDo;
	For Each Hook In Visitor.Hooks.AfterVisitDeclarations Do
		Hook.AfterVisitDeclarations(Declarations, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitDeclarations()

Procedure VisitStatements(Visitor, Statements)
	Var Stmt, Hook;
	For Each Hook In Visitor.Hooks.VisitStatements Do
		Hook.VisitStatements(Statements, Visitor.Stack, Visitor.Counters);
	EndDo;
	For Each Stmt In Statements Do
		VisitStmt(Visitor, Stmt);
	EndDo;
	For Each Hook In Visitor.Hooks.AfterVisitStatements Do
		Hook.AfterVisitStatements(Statements, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitStatements()

#Region VisitDecl

Procedure VisitDecl(Visitor, Decl)
	Var Type, Hook;
	For Each Hook In Visitor.Hooks.VisitDecl Do
		Hook.VisitDecl(Decl, Visitor.Stack, Visitor.Counters);
	EndDo;
	Type = Decl.Type;
	If Type = Nodes.VarModListDecl Then
		VisitVarModListDecl(Visitor, Decl);
	ElsIf Type = Nodes.VarLocListDecl Then
		VisitVarLocListDecl(Visitor, Decl);
	ElsIf Type = Nodes.ProcDecl Then
		VisitProcDecl(Visitor, Decl);
	ElsIf Type = Nodes.FuncDecl Then
		VisitFuncDecl(Visitor, Decl);
	ElsIf Type = Nodes.PrepIfDecl Then
		VisitPrepIfDecl(Visitor, Decl);
	ElsIf Type = Nodes.PrepElsIfDecl Then
		VisitPrepElsIfDecl(Visitor, Decl);
	ElsIf Type = Nodes.PrepRegionDecl Then
		VisitPrepRegionDecl(Visitor, Decl);
	EndIf;
	For Each Hook In Visitor.Hooks.AfterVisitDecl Do
		Hook.AfterVisitDecl(Decl, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitDecl()

Procedure VisitVarModListDecl(Visitor, VarModListDecl)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitVarModListDecl Do
		Hook.VisitVarModListDecl(VarModListDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
	For Each Hook In Visitor.Hooks.AfterVisitVarModListDecl Do
		Hook.AfterVisitVarModListDecl(VarModListDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitVarModListDecl()

Procedure VisitVarLocListDecl(Visitor, VarLocListDecl)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitVarLocListDecl Do
		Hook.VisitVarLocListDecl(VarLocListDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
	For Each Hook In Visitor.Hooks.AfterVisitVarLocListDecl Do
		Hook.AfterVisitVarLocListDecl(VarLocListDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitVarLocListDecl()

Procedure VisitProcDecl(Visitor, ProcDecl)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitProcDecl Do
		Hook.VisitProcDecl(ProcDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, ProcDecl);
	VisitDeclarations(Visitor, ProcDecl.Decls);
	VisitStatements(Visitor, ProcDecl.Body);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitProcDecl Do
		Hook.AfterVisitProcDecl(ProcDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitProcDecl()

Procedure VisitFuncDecl(Visitor, FuncDecl)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitFuncDecl Do
		Hook.VisitFuncDecl(FuncDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, FuncDecl);
	VisitDeclarations(Visitor, FuncDecl.Decls);
	VisitStatements(Visitor, FuncDecl.Body);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitFuncDecl Do
		Hook.AfterVisitFuncDecl(FuncDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitFuncDecl()

Procedure VisitPrepIfDecl(Visitor, PrepIfDecl)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitPrepIfDecl Do
		Hook.VisitPrepIfDecl(PrepIfDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, PrepIfDecl);
	VisitExpr(Visitor, PrepIfDecl.Cond);
	VisitDeclarations(Visitor, PrepIfDecl.Then);
	If PrepIfDecl.ElsIf <> Undefined Then
		For Each PrepElsIfDecl In PrepIfDecl.ElsIf Do
			VisitPrepElsIfDecl(Visitor, PrepElsIfDecl);
		EndDo;
	EndIf;
	If PrepIfDecl.Else <> Undefined Then
		VisitDeclarations(Visitor, PrepIfDecl.Else);
	EndIf;
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitPrepIfDecl Do
		Hook.AfterVisitPrepIfDecl(PrepIfDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitPrepIfDecl()

Procedure VisitPrepElsIfDecl(Visitor, PrepElsIfDecl)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitPrepElsIfDecl Do
		Hook.VisitPrepElsIfDecl(PrepElsIfDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, PrepElsIfDecl);
	VisitExpr(Visitor, PrepElsIfDecl.Cond);
	VisitDeclarations(Visitor, PrepElsIfDecl.Then);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitPrepElsIfDecl Do
		Hook.AfterVisitPrepElsIfDecl(PrepElsIfDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitPrepElsIfDecl()

Procedure VisitPrepRegionDecl(Visitor, PrepRegionDecl)
	Var Hook, Decl, Stmt;
	For Each Hook In Visitor.Hooks.VisitPrepRegionDecl Do
		Hook.VisitPrepRegionDecl(PrepRegionDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, PrepRegionDecl);
	VisitDeclarations(Visitor, PrepRegionDecl.Decls);
	VisitStatements(Visitor, PrepRegionDecl.Body);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitPrepRegionDecl Do
		Hook.AfterVisitPrepRegionDecl(PrepRegionDecl, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitPrepRegionDecl()

#EndRegion // VisitDecl

#Region VisitExpr

Procedure VisitExpr(Visitor, Expr)
	Var Type, Hook;
	For Each Hook In Visitor.Hooks.VisitBasicLitExpr Do
		Hook.VisitExpr(Expr, Visitor.Stack, Visitor.Counters);
	EndDo;
	Type = Expr.Type;
	If Type = Nodes.BasicLitExpr Then
		VisitBasicLitExpr(Visitor, Expr);
	ElsIf Type = Nodes.DesigExpr Then
		VisitDesigExpr(Visitor, Expr);
	ElsIf Type = Nodes.UnaryExpr Then
		VisitUnaryExpr(Visitor, Expr);
	ElsIf Type = Nodes.BinaryExpr Then
		VisitBinaryExpr(Visitor, Expr);
	ElsIf Type = Nodes.NewExpr Then
		VisitNewExpr(Visitor, Expr);
	ElsIf Type = Nodes.TernaryExpr Then
		VisitTernaryExpr(Visitor, Expr);
	ElsIf Type = Nodes.ParenExpr Then
		VisitParenExpr(Visitor, Expr);
	ElsIf Type = Nodes.NotExpr Then
		VisitNotExpr(Visitor, Expr);
	ElsIf Type = Nodes.StringExpr Then
		VisitStringExpr(Visitor, Expr);
	EndIf;
	For Each Hook In Visitor.Hooks.AfterVisitBasicLitExpr Do
		Hook.AfterVisitExpr(Expr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitExpr()

Procedure VisitBasicLitExpr(Visitor, BasicLitExpr)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitBasicLitExpr Do
		Hook.VisitBasicLitExpr(BasicLitExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
	For Each Hook In Visitor.Hooks.AfterVisitBasicLitExpr Do
		Hook.AfterVisitBasicLitExpr(BasicLitExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitBasicLitExpr()

Procedure VisitDesigExpr(Visitor, DesigExpr)
	Var SelectExpr, Expr, Hook;
	For Each Hook In Visitor.Hooks.VisitDesigExpr Do
		Hook.VisitDesigExpr(DesigExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, DesigExpr);
	For Each SelectExpr In DesigExpr.Select Do
		If SelectExpr.Kind <> SelectKinds.Ident Then
			For Each Expr In SelectExpr.Value Do
				If Expr <> Undefined Then
					VisitExpr(Visitor, Expr);
				EndIf;
			EndDo;
		EndIf;
	EndDo;
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitDesigExpr Do
		Hook.AfterVisitDesigExpr(DesigExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitDesigExpr()

Procedure VisitUnaryExpr(Visitor, UnaryExpr)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitUnaryExpr Do
		Hook.VisitUnaryExpr(UnaryExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, UnaryExpr);
	VisitExpr(Visitor, UnaryExpr.Operand);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitUnaryExpr Do
		Hook.AfterVisitUnaryExpr(UnaryExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitUnaryExpr()

Procedure VisitBinaryExpr(Visitor, BinaryExpr)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitBinaryExpr Do
		Hook.VisitBinaryExpr(BinaryExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, BinaryExpr);
	VisitExpr(Visitor, BinaryExpr.Left);
	VisitExpr(Visitor, BinaryExpr.Right);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitBinaryExpr Do
		Hook.AfterVisitBinaryExpr(BinaryExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitBinaryExpr()

Procedure VisitNewExpr(Visitor, NewExpr)
	Var Expr, Hook;
	For Each Hook In Visitor.Hooks.VisitNewExpr Do
		Hook.VisitNewExpr(NewExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, NewExpr);
	If TypeOf(NewExpr.Constr) = Type("Structure") Then
		VisitDesigExpr(Visitor, NewExpr.Constr);
	Else
		For Each Expr In NewExpr.Constr Do
			VisitExpr(Visitor, Expr);
		EndDo;
	EndIf;
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitNewExpr Do
		Hook.AfterVisitNewExpr(NewExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitNewExpr()

Procedure VisitTernaryExpr(Visitor, TernaryExpr)
	Var SelectExpr, Expr, Hook;
	For Each Hook In Visitor.Hooks.VisitTernaryExpr Do
		Hook.VisitTernaryExpr(TernaryExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, TernaryExpr);
	VisitExpr(Visitor, TernaryExpr.Cond);
	VisitExpr(Visitor, TernaryExpr.Then);
	VisitExpr(Visitor, TernaryExpr.Else);
	For Each SelectExpr In TernaryExpr.Select Do
		If SelectExpr.Kind <> SelectKinds.Ident Then
			For Each Expr In SelectExpr.Value Do
				If Expr <> Undefined Then
					VisitExpr(Visitor, Expr);
				EndIf;
			EndDo;
		EndIf;
	EndDo;
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitTernaryExpr Do
		Hook.AfterVisitTernaryExpr(TernaryExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitTernaryExpr()

Procedure VisitParenExpr(Visitor, ParenExpr)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitParenExpr Do
		Hook.VisitParenExpr(ParenExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, ParenExpr);
	VisitExpr(Visitor, ParenExpr.Expr);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitParenExpr Do
		Hook.AfterVisitParenExpr(ParenExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitParenExpr()

Procedure VisitNotExpr(Visitor, NotExpr)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitNotExpr Do
		Hook.VisitNotExpr(NotExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, NotExpr);
	VisitExpr(Visitor, NotExpr.Expr);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitNotExpr Do
		Hook.AfterVisitNotExpr(NotExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitNotExpr()

Procedure VisitStringExpr(Visitor, StringExpr)
	Var Expr, Hook;
	For Each Hook In Visitor.Hooks.VisitStringExpr Do
		Hook.VisitStringExpr(StringExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, StringExpr);
	For Each Expr In StringExpr.List Do
		VisitBasicLitExpr(Visitor, Expr);
	EndDo;
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitStringExpr Do
		Hook.AfterVisitStringExpr(StringExpr, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitStringExpr()

#EndRegion // VisitExpr

#Region VisitStmt

Procedure VisitStmt(Visitor, Stmt)
	Var Type, Hook;
	For Each Hook In Visitor.Hooks.VisitStmt Do
		Hook.VisitStmt(Stmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	Type = Stmt.Type;
	If Type = Nodes.AssignStmt Then
		VisitAssignStmt(Visitor, Stmt);
	ElsIf Type = Nodes.ReturnStmt Then
		VisitReturnStmt(Visitor, Stmt);
	ElsIf Type = Nodes.BreakStmt Then
		VisitBreakStmt(Visitor, Stmt);
	ElsIf Type = Nodes.ContinueStmt Then
		VisitContinueStmt(Visitor, Stmt);
	ElsIf Type = Nodes.RaiseStmt Then
		VisitRaiseStmt(Visitor, Stmt);
	ElsIf Type = Nodes.ExecuteStmt Then
		VisitExecuteStmt(Visitor, Stmt);
	ElsIf Type = Nodes.CallStmt Then
		VisitCallStmt(Visitor, Stmt);
	ElsIf Type = Nodes.IfStmt Then
		VisitIfStmt(Visitor, Stmt);
	ElsIf Type = Nodes.PrepIfStmt Then
		VisitPrepIfStmt(Visitor, Stmt);
	ElsIf Type = Nodes.WhileStmt Then
		VisitWhileStmt(Visitor, Stmt);
	ElsIf Type = Nodes.PrepRegionStmt Then
		VisitPrepRegionStmt(Visitor, Stmt);
	ElsIf Type = Nodes.ForStmt Then
		VisitForStmt(Visitor, Stmt);
	ElsIf Type = Nodes.ForEachStmt Then
		VisitForEachStmt(Visitor, Stmt);
	ElsIf Type = Nodes.TryStmt Then
		VisitTryStmt(Visitor, Stmt);
	ElsIf Type = Nodes.GotoStmt Then
		VisitGotoStmt(Visitor, Stmt);
	ElsIf Type = Nodes.LabelStmt Then
		VisitLabelStmt(Visitor, Stmt);
	EndIf;
	For Each Hook In Visitor.Hooks.AfterVisitStmt Do
		Hook.AfterVisitStmt(Stmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitStmt()

Procedure VisitAssignStmt(Visitor, AssignStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitAssignStmt Do
		Hook.VisitAssignStmt(AssignStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, AssignStmt);
	VisitDesigExpr(Visitor, AssignStmt.Left);
	VisitExpr(Visitor, AssignStmt.Right);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitAssignStmt Do
		Hook.AfterVisitAssignStmt(AssignStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitAssignStmt()

Procedure VisitReturnStmt(Visitor, ReturnStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitReturnStmt Do
		Hook.VisitReturnStmt(ReturnStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, ReturnStmt);
	If ReturnStmt.Expr <> Undefined Then
		VisitExpr(Visitor, ReturnStmt.Expr);
	EndIf;
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitReturnStmt Do
		Hook.AfterVisitReturnStmt(ReturnStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitReturnStmt()

Procedure VisitBreakStmt(Visitor, BreakStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitBreakStmt Do
		Hook.VisitBreakStmt(BreakStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	For Each Hook In Visitor.Hooks.AfterVisitBreakStmt Do
		Hook.AfterVisitBreakStmt(BreakStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitBreakStmt()

Procedure VisitContinueStmt(Visitor, ContinueStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitContinueStmt Do
		Hook.VisitContinueStmt(ContinueStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	For Each Hook In Visitor.Hooks.AfterVisitContinueStmt Do
		Hook.AfterVisitContinueStmt(ContinueStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitContinueStmt()

Procedure VisitRaiseStmt(Visitor, RaiseStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitRaiseStmt Do
		Hook.VisitRaiseStmt(RaiseStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, RaiseStmt);
	If RaiseStmt.Expr <> Undefined Then
		VisitExpr(Visitor, RaiseStmt.Expr);
	EndIf;
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitRaiseStmt Do
		Hook.AfterVisitRaiseStmt(RaiseStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitRaiseStmt()

Procedure VisitExecuteStmt(Visitor, ExecuteStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitExecuteStmt Do
		Hook.VisitExecuteStmt(ExecuteStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, ExecuteStmt);
	VisitExpr(Visitor, ExecuteStmt.Expr);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitExecuteStmt Do
		Hook.AfterVisitExecuteStmt(ExecuteStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitExecuteStmt()

Procedure VisitCallStmt(Visitor, CallStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitCallStmt Do
		Hook.VisitCallStmt(CallStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, CallStmt);
	VisitDesigExpr(Visitor, CallStmt.Desig);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitCallStmt Do
		Hook.AfterVisitCallStmt(CallStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitCallStmt()

Procedure VisitIfStmt(Visitor, IfStmt)
	Var ElsIfStmt, Hook;
	For Each Hook In Visitor.Hooks.VisitIfStmt Do
		Hook.VisitIfStmt(IfStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, IfStmt);
	VisitExpr(Visitor, IfStmt.Cond);
	VisitStatements(Visitor, IfStmt.Then);
	If IfStmt.ElsIf <> Undefined Then
		For Each ElsIfStmt In IfStmt.ElsIf Do
			VisitElsIfStmt(Visitor, ElsIfStmt);
		EndDo;
	EndIf;
	If IfStmt.Else <> Undefined Then
		VisitStatements(Visitor, IfStmt.Else);
	EndIf;
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitIfStmt Do
		Hook.AfterVisitIfStmt(IfStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitIfStmt()

Procedure VisitElsIfStmt(Visitor, ElsIfStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitElsIfStmt Do
		Hook.VisitElsIfStmt(ElsIfStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, ElsIfStmt);
	VisitExpr(Visitor, ElsIfStmt.Cond);
	VisitStatements(Visitor, ElsIfStmt.Then);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitElsIfStmt Do
		Hook.AfterVisitElsIfStmt(ElsIfStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitElsIfStmt()

Procedure VisitPrepIfStmt(Visitor, PrepIfStmt)
	Var PrepElsIfStmt, Hook;
	For Each Hook In Visitor.Hooks.VisitPrepIfStmt Do
		Hook.VisitPrepIfStmt(PrepIfStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, PrepIfStmt);
	VisitExpr(Visitor, PrepIfStmt.Cond);
	VisitStatements(Visitor, PrepIfStmt.Then);
	If PrepIfStmt.ElsIf <> Undefined Then
		For Each PrepElsIfStmt In PrepIfStmt.ElsIf Do
			VisitPrepElsIfStmt(Visitor, PrepElsIfStmt);
		EndDo;
	EndIf;
	If PrepIfStmt.Else <> Undefined Then
		VisitStatements(Visitor, PrepIfStmt.Else);
	EndIf;
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitPrepIfStmt Do
		Hook.AfterVisitPrepIfStmt(PrepIfStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitPrepIfStmt()

Procedure VisitPrepElsIfStmt(Visitor, PrepElsIfStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitPrepElsIfStmt Do
		Hook.VisitPrepElsIfStmt(PrepElsIfStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, PrepElsIfStmt);
	VisitExpr(Visitor, PrepElsIfStmt.Cond);
	VisitStatements(Visitor, PrepElsIfStmt.Then);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitPrepElsIfStmt Do
		Hook.AfterVisitPrepElsIfStmt(PrepElsIfStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitPrepElsIfStmt()

Procedure VisitWhileStmt(Visitor, WhileStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitWhileStmt Do
		Hook.VisitWhileStmt(WhileStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, WhileStmt);
	VisitExpr(Visitor, WhileStmt.Cond);
	VisitStatements(Visitor, WhileStmt.Body);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitWhileStmt Do
		Hook.AfterVisitWhileStmt(WhileStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitWhileStmt()

Procedure VisitPrepRegionStmt(Visitor, PrepRegionStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitPrepRegionStmt Do
		Hook.VisitPrepRegionStmt(PrepRegionStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, PrepRegionStmt);
	VisitStatements(Visitor, PrepRegionStmt.Body);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitPrepRegionStmt Do
		Hook.AfterVisitPrepRegionStmt(PrepRegionStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitPrepRegionStmt()

Procedure VisitForStmt(Visitor, ForStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitForStmt Do
		Hook.VisitForStmt(ForStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, ForStmt);
	VisitDesigExpr(Visitor, ForStmt.Desig);
	VisitExpr(Visitor, ForStmt.From);
	VisitExpr(Visitor, ForStmt.To);
	VisitStatements(Visitor, ForStmt.Body);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitForStmt Do
		Hook.AfterVisitForStmt(ForStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitForStmt()

Procedure VisitForEachStmt(Visitor, ForEachStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitForEachStmt Do
		Hook.VisitForEachStmt(ForEachStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, ForEachStmt);
	VisitDesigExpr(Visitor, ForEachStmt.Desig);
	VisitExpr(Visitor, ForEachStmt.In);
	VisitStatements(Visitor, ForEachStmt.Body);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitForEachStmt Do
		Hook.AfterVisitForEachStmt(ForEachStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitForEachStmt()

Procedure VisitTryStmt(Visitor, TryStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitTryStmt Do
		Hook.VisitTryStmt(TryStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	PushInfo(Visitor, TryStmt);
	VisitStatements(Visitor, TryStmt.Try);
	VisitStatements(Visitor, TryStmt.Except);
	PopInfo(Visitor);
	For Each Hook In Visitor.Hooks.AfterVisitTryStmt Do
		Hook.AfterVisitTryStmt(TryStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitTryStmt()

Procedure VisitGotoStmt(Visitor, GotoStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitGotoStmt Do
		Hook.VisitGotoStmt(GotoStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	For Each Hook In Visitor.Hooks.AfterVisitGotoStmt Do
		Hook.AfterVisitGotoStmt(GotoStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitGotoStmt()

Procedure VisitLabelStmt(Visitor, LabelStmt)
	Var Hook;
	For Each Hook In Visitor.Hooks.VisitLabelStmt Do
		Hook.VisitLabelStmt(LabelStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
	For Each Hook In Visitor.Hooks.AfterVisitLabelStmt Do
		Hook.AfterVisitLabelStmt(LabelStmt, Visitor.Stack, Visitor.Counters);
	EndDo;
EndProcedure // VisitLabelStmt()

#EndRegion // VisitStmt

#EndRegion // Visitor

Init();
