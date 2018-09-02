
AttachScript("..\src\BSLParser\Ext\ObjectModule.bsl", "BSLParser");
AttachScript("..\plugins\DocGen\src\DocGen\Ext\ObjectModule.bsl", "PluginDocGen");

TextReader = New TextReader("..\src\BSLParser\Ext\ObjectModule.bsl");
Source = TextReader.Read();

BSLParser = New BSLParser;
Module = BSLParser.РазобратьМодуль(Source);

PluginDocGen = New PluginDocGen;
BSLParser.Подключить(PluginDocGen);
BSLParser.ПосетитьМодуль(Module);

TextWriter = New TextWriter("..\docs\index.html");
TextWriter.Write(PluginDocGen.Результат());