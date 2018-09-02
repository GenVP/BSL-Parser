
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	If StrFind(InfoBaseConnectionString(), "File=") = 0 Then
		Message("Only for file bases")
	EndIf;

	Output = "Tree";

EndProcedure // OnCreateAtServer()

&AtClient
Procedure OnOpen(Cancel)
	
	SetVisibilityOfAttributes(ThisObject);
	
EndProcedure // OnOpen()

&AtClient
Procedure Translate(Command)

	Result.Clear();
	ClearMessages();
	TranslateAtServer();

EndProcedure // Translate()

&AtServer
Procedure TranslateAtServer()
	Var Start;

	This = FormAttributeToValue("Object");
	ThisFile = New File(This.UsedFileName);

	BSLParser = ExternalDataProcessors.Create(ThisFile.Path + "BSLParser.epf", False);

	BSLParser.БолтливыйРежим = Verbose;
	BSLParser.ПоложениеУзлаВАСТ = Location;
	BSLParser.Отладка = Debug;

	Start = CurrentUniversalDateInMilliseconds();

	If Output = "NULL" Then

		BSLParser.ParseModule(Source.GetText());
		
	ElsIf Output = "AST" Then

		Parser_Module = BSLParser.ParseModule(Source.GetText());
		JSONWriter = New JSONWriter;
		JSONWriter.SetString(New JSONWriterSettings(, Chars.Tab));
		If ShowComments Then
			Comments = New Map;
			For Each Item In Parser_Module.Comments Do
				Comments[Format(Item.Key, "NZ=0; NG=")] = Item.Значение;
			EndDo;
			Parser_Module.Comments = Comments;
		Else
			Parser_Module.Delete("Comments");
		EndIf;
		WriteJSON(JSONWriter, Parser_Module,, "ConvertJSON", ThisObject);
		Result.SetText(JSONWriter.Close());
		
	ElsIf Output = "Tree" Then

		Parser_Module = BSLParser.РазобратьМодуль(Source.GetText());
		FillTree(Parser_Module);
		
	ElsIf Output = "Plugin" Then
		
		BSLParser.ПоложениеУзлаВАСТ = True;
		
		PluginProcessor = ExternalDataProcessors.Create(PluginPath, False);
		Parser_Module = BSLParser.РазобратьМодуль(Source.GetText());
		BSLParser.Подключить(PluginProcessor);
		BSLParser.ПосетитьМодуль(Parser_Module);
		Result.SetText(PluginProcessor.Результат());
		
	EndIf;

	If Measure Then
		Message(StrTemplate("%1 sec.", (CurrentUniversalDateInMilliseconds() - Start) / 1000));
	EndIf;

EndProcedure // TranslateAtServer()

&AtServer
Function FillTree(Module)
	Var Место;
	TreeItems = Tree.GetItems();
	TreeItems.Clear();
	Row = TreeItems.Add();
	Row.Имя = "Module";
	Row.Тип = Module.Тип;
	Row.Значение = "<...>";
	FillNode(Row, Module);
EndFunction // FillTree() 

&AtServer
Function FillNode(Row, Node)
	Var Место;
	If Node.Property("Место", Место) And ТипЗнч(Место) = Тип("Structure") Then
		Row.НомерСтроки = Место.НомерСтрокиНачала;
		Row.Позиция = Место.Позиция;
		Row.Длина = Место.Длина;
	EndIf;
	TreeItems = Row.GetItems();
	For Each Item In Node Do
		If Item.Key = "Место"
			Or Item.Key = "Тип" Then
			Continue;
		EndIf; 
		If ТипЗнч(Item.Значение) = Тип("Array") Then
			Row = TreeItems.Add();
			Row.Имя = Item.Key;
			Row.Тип = StrTemplate("List (%1)", Item.Значение.Count());
			Row.Значение = "<...>";
			RowItems = Row.GetItems();
			Index = 0;
			For Each Item In Item.Значение Do
				Row = RowItems.Add();
				Index = Index + 1;
				Row.Имя = Index;
				If Item = Undefined Then
					Row.Значение = "Undefined";
				Else
					Item.Property("Тип", Row.Тип);
					Row.Значение = "<...>";
					FillNode(Row, Item);
				EndIf; 
			EndDo;			
		ElsIf ТипЗнч(Item.Значение) = Тип("Structure") Then
			Row = TreeItems.Add();
			Row.Имя = Item.Key;
			Row.Тип = Item.Значение.Тип;
			Row.Значение = "<...>";
			FillNode(Row, Item.Значение);
		Else
			Row = TreeItems.Add();
			Row.Имя = Item.Key;
			Row.Значение = Item.Значение;
			Row.Тип = ТипЗнч(Item.Значение);
		EndIf; 
	EndDo;
EndFunction // FillNode() 

&AtServer
Function ConvertJSON(Property, Значение, Other, Cancel) Export
	If Значение = Null Then
		Return Undefined;
	EndIf;
EndFunction // ConvertJSON()

&AtClientAtServerNoContext
Procedure SetVisibilityOfAttributes(ThisObject, Reason = Undefined)

	Items = ThisObject.Items;

	If Reason = Items.Output Or Reason = Undefined Then

		Items.PluginPath.Visible = (ThisObject.Output = "Plugin");
		Items.Location.Visible = (ThisObject.Output <> "Plugin");
		Items.ShowComments.Visible = (ThisObject.Output = "AST");
		Items.Tree.Visible = (ThisObject.Output = "Tree");
		Items.Result.Visible = (ThisObject.Output <> "Tree");
		
	EndIf;

EndProcedure // SetVisibilityOfAttributes()

&AtClient
Procedure OutputOnChange(Item)

	SetVisibilityOfAttributes(ThisObject, Item);

EndProcedure // OutputOnChange()

&AtClient
Procedure PluginPathStartChoice(Item, ChoiceData, StandardProcessing)

	StandardProcessing = False;
	ChoosePath(Item, ThisObject, FileDialogMode.Open, "(*.epf)|*.epf");

EndProcedure // PluginPathStartChoice()

&AtClient
Procedure ChoosePath(Item, Form, DialogMode = Undefined, Filter = Undefined)

	If DialogMode = Undefined Then
		DialogMode = FileDialogMode.ChooseDirectory;
	EndIf;

	FileOpeningDialog = New FileDialog(DialogMode);
	FileOpeningDialog.Filter = Filter;

	FileOpeningDialog.Show(New NotifyDescription("ChoosePathNotifyChoice", ThisObject));

EndProcedure // ChoosePath()

&AtClient
Procedure ChoosePathNotifyChoice(Result, AdditionalParameters) Export

	If Result <> Undefined Then
		PluginPath = Result[0];
	EndIf;

EndProcedure // ChoosePathNotifyChoice()

&AtClient
Procedure TreeSelection(Item, SelectedRow, Field, StandardProcessing)
	Row = Tree.FindByID(SelectedRow);
	If Row.НомерСтроки > 0 Then
		Items.Source.SetTextSelectionBounds(Row.Позиция, Row.Позиция + Row.Длина);
		CurrentItem = Items.Source;
	EndIf; 
EndProcedure // TreeSelection()


