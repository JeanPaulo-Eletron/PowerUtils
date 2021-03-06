unit UUtilitarios_PowerUtils;

interface

uses Windows, SysUtils, Generics.Collections,  Classes, JvADOQuery, JvBaseDBThreadedDataset, Data.DB, Vcl.StdCtrls,
     Data.Win.ADODB, Graphics, Vcl.Forms, Dialogs, ActiveX, RTTI, StrUtils, System.Threading;

Type
  TCallBack = reference to procedure;
  //Objeto que carregara a procedure Callback que ser? chamada no AfterThreadExecution.
  TObjCallBack     = Class(TObject)
    Callback : TCallBack;
    //Uso interno, serve para ele chamar o callback que eu configurei ao criar esse objeto para ser chamada no AfterThreadExecution.
    procedure CallBackSQLAssync(DataSet: TDataSet;Operation: TJvThreadedDatasetOperation);
  End;

  TRetornoSQL = Class(TObject)
    Value: TArray<TArray<String>>;
  End;

  //Alguns tipos para uso interno
  TQrys    = Array of TADOQuery;
  TButtons = Array of TButton;
  TProcedure  = Procedure of object;

  //Esse ? o objeto timer super simplificado.
  TTimeOut  = Class(TObject)
    Callback : TProc;
    RestInterval : Integer;
    LoopTimer: Boolean;
    IDEvent : Integer;
    Tag     : Integer;
    FreeOnTerminate: Boolean;
    PEnabled : Boolean;
    procedure SetEnabled(Enabled: Boolean);
    property Enabled: Boolean read PEnabled write SetEnabled;
  End;

  // Aten??o, coloque uma variavel no form main para contar o numero de consultas ativas, no before destroy do form main
  // coloque um while pare ele esperar terminar as consultas(evita o erro de consultas assyncronas).

  //Use essa aqui caso queira um uso r?pido dessa fun??o no atualiza banco de dados
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection):String;overload;

  //Use essa aqui caso queira um uso r?pido dessa fun??o no atualiza banco de dados ( e a Qry do form main seja impactada )
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Qry : TAdoQuery):String;overload;

  //Use essa aqui caso queira um uso r?pido dessa fun??o
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Button : TButton; Qry : TAdoQuery):String;overload;

  //Use essa aqui caso queira dar o Refresh(close e open) em todas as qrys envolvidas assim que ele teminar de fazer a SP
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Button : TButton; Qrys : TQrys):String;overload;

  //Caso geral, use apenas caso queira desabilitar v?rios bot?es, caso contr?rio, use a function acima.
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Buttons : TButtons; Qrys : TQrys):String;overload;

  // Caso queira setar um timer de modo r?pido que se desative sozinho ao ser acionado.
  Function  SetTimeOut (CallBack: TProcedure; RestInterval: Integer; LoopTimer: Boolean = False; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
  Function  SetTimeOut (CallBack: TProc; RestInterval: Integer; LoopTimer: Boolean = False; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;

  // Caso queira setar um timer de modo r?pido que se desative quando a pessoa setar o TTimeOut de retorno com a propriedade ".LoopTimer := False"
  Function  SetInterval(CallBack: TProcedure; RestInterval: Integer; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
  Function  SetInterval(CallBack: TProc; RestInterval: Integer; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;

  // Uso interno, localiza a posi??o do timer na lista de timers pelo seu IDEVENT.
  Function  Localizar(idEvent:UINT):Integer;

  //Serve para alertar quando o usu?rio apertou determinada tecla;
  function TeclaEstaPressionada(const Key: integer): boolean;

  Function ObterTeclasPressionadas(var Value: String): String;

  Function DiffString(ValueA, ValueB: String): String;

  Function GetPrintScreen() : TBitmap;

  //Fun??es de controle de mouse e teclado
  procedure PressionarTeclaShiftEManter;
  procedure SoltarTeclaShift;
  procedure ClicarESegurar(X, Y: Integer);
  procedure PressionarControlEManter;
  procedure PressionarTeclaC;
  procedure PressionarTeclaV;
  procedure SoltarClick(X, Y: Integer);
  procedure SoltarControl;
  procedure MoverScroll(X: INTEGER);
  procedure PressionarTeclaEnd;
  procedure PressionarTeclaHome;
  procedure MoverMouse(X, Y: Integer);
  procedure MoverMouseSuavemente(X, Y, Velocidade, Ruido: Integer; CallBack: TCallBack);

  procedure EscreverLivrementeNaTela(Texto: String; Y: Integer);
  procedure ConfigurarConexao(Alias: TAdoConnection);

  procedure AtualizarIcone(const FileName, IcoFileName: String);

  procedure InitializeThreadConectionMode;

  procedure Mensagem(Msg: String);

  Function Concatenar(Linhas: Array of String): String;

  Function ConsultarSQLAssyncronamente( ScriptSQL : TArray<String>; RetornoSQL: TRetornoSQL; Callback: TCallBack): iTask;

//--//--//--//--//--//--//--//--//--//--/EM DESENVOLVIMENTO/--//--//--//--//--//--//--//--//--//--//--//--//

  procedure DesenharSeta(OCor: TColor; OLargura: Integer; Origem, Destino: TPoint);

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

Type
  TCampo  = (Nome);
  TTabela = (Amigos);
  AdoQueryDSLHelper = Class Helper for TAdoQuery
    Function Create_: TAdoQuery;OverLoad;
    Function Create_(AOwner: TComponent): TAdoQuery;OverLoad;
    Function Select: TAdoQuery;
    Function Campos(Campo: TCampo): TAdoQuery;overload;
    Function Campos(Campo: String): TAdoQuery;overload;
    Function From(Tabela: TTabela): TAdoQuery;overload;
    Function From(Tabela: String): TAdoQuery;overload;
    Function Where(Condicao: String): TAdoQuery;
    Function And_(Condicao: String): TAdoQuery;
    Function OR_(Condicao: String): TAdoQuery;
    Function InnerJoin(Tabela: TTabela; Condicoes: String): TAdoQuery;OverLoad;
    Function InnerJoin(Tabela: String; Condicoes: String): TAdoQuery;OverLoad;
  end;

var
  TimeOut  : TList<TTimeOut>;
  QtdeTimers : Integer;
const
  FimLinhaStr: String = #13;
implementation

uses UFormMain_PowerUtils;

Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection):String;overload;
//Use essa aqui caso queira um uso r?pido dessa fun??o no atualiza banco de dados
var Buttons : TButtons;
    Qrys    : TQrys;
begin
  SetLength(Buttons, 0);
  SetLength(Qrys, 0);
  ExecutaSQLAssync(SQLText, Connection, Buttons, Qrys);
end;

Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Qry : TAdoQuery):String;overload;
//Use essa aqui caso queira um uso r?pido dessa fun??o no atualiza banco de dados ( e a Qry do form main seja impactada )
var Buttons : TButtons;
    Qrys    : TQrys;
begin
  SetLength(Buttons, 0);
  SetLength(Qrys, 1);
  Qrys[0] := Qry;
  ExecutaSQLAssync(SQLText, Connection, Buttons, Qrys);
end;

Function ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Button : TButton; Qry : TAdoQuery):String;overload;
//Use essa aqui caso queira um uso r?pido dessa fun??o
var Buttons : TButtons;
    Qrys    : TQrys;
begin
  SetLength(Buttons, 1);
  SetLength(Qrys, 1);
  Buttons[0] := Button;
  Qrys[0] := Qry;
  ExecutaSQLAssync(SQLText, Connection, Buttons, Qrys);
end;

Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Button : TButton; Qrys : TQrys):String;overload;
//Use essa aqui caso queira dar o Refresh(close e open) em todas as qrys envolvidas assim que ele teminar de fazer a SP
var Buttons : TButtons;
begin
  SetLength(Buttons, 1);
  Buttons[0] := Button;
  ExecutaSQLAssync(SQLText, Connection, Buttons, Qrys);
end;

Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Buttons : TButtons; Qrys : TQrys):String; overload;
//Caso geral, use apenas caso queira desabilitar v?rios bot?es, caso contr?rio, use a function acima.
var Button : TButton;
    _Qry : TJvADOQuery;
    Obj : TObjCallBack;
begin
  result := '';
  if SQLText = ''
    then Exit;
  Try
    _Qry := TJvADOQuery.Create(nil);
    Obj  := TObjCallBack.Create;
    Obj.Callback := Procedure
                    begin
                      SetTimeOut(
                        Procedure
                        var Qry    : TAdoQuery;
                            Button : TButton;
                        begin
                          for Qry in Qrys do Qry.Active := False;
                          for Qry in Qrys do Qry.Active := True;  // Abrindo e fechando as qrys passadas por parametro.
                          for Button in Buttons do Button.Enabled := True;
                          _Qry.Free;
                          Obj.Free;
                        end, 1000);
                      _Qry.Close;
                    end;
    _Qry.ThreadOptions.OpenInThread := True;
    _Qry.SQL.Clear;
    _Qry.SQL.Add('select 1 -- Para n?o dar erro');
    _Qry.SQL.Add(SQLText);
    _Qry.Connection := Connection;
    _Qry.AfterThreadExecution := Obj.CallBackSQLAssync;
    _Qry.Open;
    for Button in Buttons do Button.Enabled := False;
  Except
    Result := 'Erro';
  End;

end;

procedure TObjCallBack.CallBackSQLAssync(DataSet: TDataSet;Operation: TJvThreadedDatasetOperation);
begin
  Callback;
end;

// !!!!!!!!!!!  TIMER  !!!!!!!!!!!!!!!!!!! \\

procedure MyTimeout( hwnd: HWND; uMsg: UINT;idEvent: UINT ; dwTime : DWORD);
stdcall;
VAR
  _CallBack : TProc;
  _TimeOut: TTimeOut;
begin
  _TimeOut := TimeOut.List[Localizar(idEvent)];
  _TimeOut.Enabled := False;
  _CallBack := _TimeOut.Callback;
  _CallBack;
  if (_TimeOut.LoopTimer)
    then _TimeOut.Enabled := True
    else begin
      _TimeOut.Enabled := False;
      if (_TimeOut.FreeOnTerminate) then begin
        TimeOut.Remove(_TimeOut);
        _TimeOut.Free;
        _TimeOut := Nil;
      end;
    end;
end;

Function SetTimeOut(CallBack: TProc; RestInterval: Integer; LoopTimer: Boolean = False; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
var Timer : TTimeOut;
begin
  if TimeOut = nil
    then TimeOut := TList<TTimeOut>.Create;
  QtdeTimers := QtdeTimers + 1;
  Timer  := TTimeOut.Create;
  Timer.Callback        := CallBack;
  Timer.RestInterval    := RestInterval;
  Timer.LoopTimer       := LoopTimer;
  Timer.Tag             := 0;
  Timer.FreeOnTerminate := FreeOnTerminate;
  Timer.Enabled := True;
  TimeOut.Add(Timer);
  Result := Timer;
end;

function SetTimeOut(CallBack: TProcedure; RestInterval: Integer; LoopTimer: Boolean = False; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;
begin
  Result := SetTimeOut(procedure begin Callback end, RestInterval, LoopTimer, FreeOnTerminate, Assync);
end;

Function SetInterval(CallBack: TProcedure; RestInterval: Integer; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
begin
  Result := SetInterval(procedure begin CallBack end,RestInterval, FreeOnTerminate, Assync);
end;

Function SetInterval(CallBack: TProc; RestInterval: Integer; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
begin
  Result := SetTimeOut(CallBack, RestInterval, True, FreeOnTerminate, Assync);
end;

Function Localizar(idEvent:UINT):Integer;
var I : Integer;
begin
  for I := 0 to TimeOut.Count - 1 do
    if TimeOut.List[I].IDEvent = idEvent then break;
  Result := I;
end;

function TeclaEstaPressionada(const Key: integer): boolean;
begin
  Result := GetKeyState(Key) and 128 > 0;
end;

Function ObterTeclasPressionadas(var Value: String): String;
Type 
  Integer_String = Record
    I: Integer;
    S: String;
  end;
var Letra: char;
    CaractereEspecial, i: integer;
Const Teclas: Array of Char = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      TeclasEspeciais: Array of Array of integer = [[VK_NUMPAD0, VK_NUMPAD1, VK_NUMPAD2, VK_NUMPAD3, VK_NUMPAD4, VK_NUMPAD5, VK_NUMPAD6, VK_NUMPAD7, VK_NUMPAD8, VK_NUMPAD9], [0,1,2,3,4,5,6,7,8,9]] ;
      CONTROL: Integer_String = (I: VK_LCONTROL; S:'[CONTROL]'); CONTROLR: Integer_String = (I: VK_RCONTROL; S:'[CONTROL(RIGTH)]'); SHIFT: Integer_String = (I: VK_LSHIFT; S:'[SHIFT]'); SHIFTR: Integer_String = (I: VK_RSHIFT; S:'[SHIFT(RIGTH)]');
      ESCAPE: Integer_String = (I: VK_ESCAPE; S:'[ESC]');
var TeclasEspeciais2: Array of Integer_String; 
    CaractereEspecial2: Integer_String;
begin
  Result := ''; TeclasEspeciais2 := [CONTROL, CONTROLR, SHIFT, SHIFTR, ESCAPE];
  
  for Letra in Teclas do begin
    if TeclaEstaPressionada(ORD(Letra))
      then Result := Result + Letra;
  end;

  i := 0;
  for CaractereEspecial in TeclasEspeciais[0] do begin
    if TeclaEstaPressionada(CaractereEspecial)
      then Result := Result + TeclasEspeciais[1][I].ToString;
    inc(I);
  end;

  for CaractereEspecial2 in TeclasEspeciais2 do begin
    if TeclaEstaPressionada(CaractereEspecial2.I)
      then Result := Result + CaractereEspecial2.S;
  end;

  Value := Result;
end;

Function DiffString(ValueA, ValueB: String): String;
begin
  Result := ValueA;
end;

function GetPrintScreen() : TBitmap;
var
  vHDC : HDC;
  vCanvas : TCanvas;
begin
  Result := TBitmap.Create;
  Result.Width := Screen.Width;
  Result.Height := Screen.Height;

  vHDC := GetDC(0);
  vCanvas := TCanvas.Create;
  vCanvas.Handle := vHDC;

  Result.Canvas.CopyRect(
  Rect(0, 0, Result.Width, Result.Height), vCanvas,
  Rect(0, 0, Result.Width, Result.Height));

  vCanvas.Free;
  ReleaseDC(0, vHDC);
end;

//--//--//--//--//--//--//--//--//--//--/EM DESENVOLVIMENTO/--//--//--//--//--//--//--//--//--//--//--//--//

{Desenha a Seta!}
procedure DesenharSeta(OCor: TColor; OLargura: Integer; Origem, Destino: TPoint);
const
ANGULO = 15;
PONTA  = 20;
var
Canvas : TCanvas;
  vHDC : HDC;
AlphaRota, Alpha, Beta       : Extended;
vertice1, vertice2, vertice3 : TPoint;
begin
vHDC := GetDC(0);
Canvas := TCanvas.Create;
Canvas.Handle := vHDC;
Canvas.Pen.Color   := OCor;
Canvas.Brush.Color := OCor;
if (Destino.X >= Origem.X) then
  begin
  if (Destino.Y >= Origem.Y) then
    begin
    AlphaRota := Destino.X - Origem.X;
    if (AlphaRota <> 0)
      then Alpha := ArcTan((Destino.Y - Origem.Y) / AlphaRota)
      else Alpha := ArcTan(Destino.Y - Origem.Y);
    Beta := (ANGULO * (PI / 180)) / 2;
    vertice1.X := Destino.X - Round(Cos(Alpha + Beta));
    vertice1.Y := Destino.Y - Round(Sin(Alpha - Beta));
    vertice2.X := Round(vertice1.X - PONTA * Cos(Alpha + Beta));
    vertice2.Y := Round(vertice1.Y - PONTA * Sin(Alpha + Beta));
    vertice3.X := Round(vertice1.X - PONTA * Cos(Alpha - Beta));
    vertice3.Y := Round(vertice1.Y - PONTA * Sin(Alpha - Beta));
    Canvas.Polygon([vertice1,vertice2,vertice3]);
    end
  else
    begin
    AlphaRota := Destino.Y - Origem.Y;
    if (AlphaRota <> 0)
      then Alpha := ArcTan((Destino.X - Origem.X) / AlphaRota)
      else Alpha := ArcTan(Destino.X - Origem.X);
    Beta := (ANGULO * (PI / 180)) / 2;
    vertice1.X := Destino.X - Round(Cos(Alpha + Beta));
    vertice1.Y := Destino.Y - Round(Sin(Alpha - Beta));
    vertice2.X := Round(vertice1.X + PONTA * Sin(Alpha + Beta));
    vertice2.Y := Round(vertice1.Y + PONTA * Cos(Alpha + Beta));
    vertice3.X := Round(vertice1.X + PONTA * Sin(Alpha - Beta));
    vertice3.Y := Round(vertice1.Y + PONTA * Cos(Alpha - Beta));
    Canvas.Polygon([vertice1,vertice2,vertice3]);
    end;
  end
else
  begin
  Alpha := ArcTan((Destino.Y - Origem.Y) / (Destino.X - Origem.X));
  Beta := (ANGULO * (PI / 180)) / 2;
  vertice1.X := Destino.X - Round(Cos(Alpha + Beta));
  vertice1.Y := Destino.Y - Round(Sin(Alpha - Beta));
  vertice2.X := Round(vertice1.X + PONTA * Cos(Alpha + Beta));
  vertice2.Y := Round(vertice1.Y + PONTA * Sin(Alpha + Beta));
  vertice3.X := Round(vertice1.X + PONTA * Cos(Alpha - Beta));
  vertice3.Y := Round(vertice1.Y + PONTA * Sin(Alpha - Beta));
  Canvas.Polygon([vertice1,vertice2,vertice3]);
  end;
end;

procedure TTimeOut.SetEnabled(Enabled: Boolean);
begin
  if (Enabled) and (not (PEnabled))
    then begin // O SetTimeOut e SetInterval deve ser Thread Safe
      TThread.Synchronize(nil,
      Procedure begin
        PEnabled   := True;
        IDEvent    := SetTimer(0, QtdeTimers, RestInterval, @MyTimeOut)
      end);
    end
    else begin
      TThread.Synchronize(nil,
        Procedure begin
          KillTimer(0,IDEvent);
          PEnabled := False;
        end);
    end;
end;

procedure PressionarTeclaShiftEManter;
begin
  Keybd_event(VK_SHIFT, 0, KEYEVENTF_EXTENDEDKEY or 0, 0);
end;

procedure SoltarTeclaShift;
begin
  Keybd_event(VK_SHIFT, $45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
end;

procedure ClicarESegurar(X, Y: Integer);
BEGIN
  Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, X, Y, 0, 0);
END;

procedure SoltarClick(X, Y: Integer);
BEGIN
  Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, X, Y, 0, 0);
END;

procedure PressionarControlEManter;
begin
  keybd_event(VK_CONTROL,0, KEYEVENTF_EXTENDEDKEY or 0,0);
end;

Procedure SoltarControl;
begin
  keybd_event(VK_CONTROL,$45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
end;

procedure PressionarTeclaC;
begin
  keybd_event($43,0,0,0);
end;

procedure PressionarTeclaV;
begin
  keybd_event($56,0,0,0);
end;

procedure PressionarTeclaEnd;
begin
  keybd_event(VK_END,   0, KEYEVENTF_EXTENDEDKEY or 0, 0);
  Keybd_event(VK_END, $45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
end;

procedure PressionarTeclaHome;
begin
  keybd_event(VK_HOME,0,0,0);
end;

procedure MoverScroll(X: INTEGER);
begin
  mouse_event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(ROUND(X)), 0);
end;

procedure MoverMouse(X, Y: Integer);
BEGIN
  Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, X, Y, 0, 0);
END;

procedure EscreverLivrementeNaTela(Texto: String; Y: Integer);
var
  Canvas : TCanvas;
  vHDC : HDC;
  pt: TPoint;
BEGIN
  vHDC := GetDC(0);
  Canvas := TCanvas.Create;
  Canvas.Handle      := vHDC;
  Canvas.Pen.Color   := ClRed;
  Canvas.Brush.Color := ClRed;

  GetCursorPos(pt);


  Canvas.Rectangle(Pt.x,Pt.y,Pt.x + Length(Texto) * 5, Pt.y + Y);
  Canvas.TextOut(Pt.x,Pt.y-10+Y,Texto);
END;

procedure ConfigurarConexao(Alias: TAdoConnection);
var TxtFile : TextFile;
    Txt, LicencaServidor, LicencaDataBase, LicencaSenha, LicencaUsuario, ExePath, CaminhoENomeArquivo : String;
begin
  ExePath := ExtractFilePath(Application.ExeName);
  {$Region 'Se o arquivo "Config.ini" n?o existir, ent?o crie um com as configura??es padr?o'}
    if not FileExists(ExePath+'Config.ini') then begin
        CaminhoENomeArquivo := ExePath + 'Config.ini';
        FileSetAttr(CaminhoENomeArquivo, 0);
        AssignFile(TxtFile, CaminhoENomeArquivo);
        Rewrite(TxtFile);
        Writeln(TxtFile,'Servidor        : LAPTOP-GK2QJ6O0');
        Writeln(TxtFile,'Usu?rio         : sa');
        Writeln(TxtFile,'Senha           : senhatst');
        Writeln(TxtFile,'LicencaDataBase : AmigosFacebook');
        Writeln(TxtFile,'O Sistema s? ir? considerar as 4 primeiras linhas e somente o que estiver ap?s o ":",');
        Writeln(TxtFile,'ele n?o ira considerar espa?os adicionais a direita e esquerda.');
        CloseFile(TxtFile);
  //    FileSetAttr(CaminhoENomeArquivo, FileGetAttr(CaminhoENomeArquivo) or faHidden); Descomente caso queira que o .ini fique oculto
    end;
  {$EndRegion}
  Try
    Alias.Connected   := False;
    Alias.LoginPrompt := False;
    AssignFile(TxtFile, ExePath+'Config.ini');
    Reset(TxtFile);
    ReadLn(TxtFile, Txt);
    LicencaServidor := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt) ));
    ReadLn(TxtFile, Txt);
    LicencaUsuario  := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
    ReadLn(TxtFile, Txt);
    LicencaSenha    := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
    ReadLn(TxtFile, Txt);
    LicencaDataBase := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
    CloseFile(TxtFile);
    Alias.ConnectionString := 'Provider=SQLOLEDB.1;'+
                              'Password='+LicencaSenha+';'+
                              'Persist Security Info=True;'+
                              'User ID='+LicencaUsuario+';'+
                              'Initial Catalog='+LicencaDataBase+';'+
                              'Data Source='+LicencaServidor+';'+
                              'Use Procedure for Prepare=1;'+
                              'Auto Translate=True;'+
                              'Packet Size=4096;'+
                              'Workstation ID=anonimo;'+
                              'Use Encryption for Data=False;'+
                              'Tag with column collation when possible=False';
  Except
    ShowMessage('N?o foi poss?vel conectar ao servidor ! Verifique o arquivo de licen?a ! ');
    Abort;
  end;
end;

procedure MoverMouseSuavemente(X, Y, Velocidade, Ruido: Integer; CallBack: TCallBack);
var Xp, Yp, RuidoX, RuidoY: Integer;
    pt: TPoint;
    TimerMoverMouse: TTimeOut;
begin
  GetCursorPos(pt);

  Pt.x := Round(Pt.x * (65535 / Screen.Width));
  Pt.y := Round(Pt.y * (65535 / Screen.Height));

  if pt.X < X
    then RuidoX := Ruido * 1000
    else RuidoX := - Ruido * 1000;

  if Pt.Y < Y
    then RuidoY := Ruido * 1000
    else RuidoY := - Ruido * 1000;

  Xp               := pt.X + RuidoX;
  Yp               := pt.Y + RuidoY;

  TimerMoverMouse :=
  SetInterval(
    Procedure
    begin
      TimerMoverMouse.Enabled := False;

      MoverMouse(Xp, Yp);
      RuidoX := RuidoX;
      RuidoY := RuidoY;

      if ((Xp < X) and (RuidoX > 0)) or ((Xp > X) and (RuidoX < 0))
        then begin
          Xp := Xp + RuidoX //+ Round(random(1)-random(1));
  //        Yp := Yp + Round(random(2)*((random(2)-1)));
        end
        else Xp := X;

      if ((Yp < Y) and (RuidoY > 0)) or ((Yp > Y) and (RuidoY < 0))
        then begin
          Yp := Yp + RuidoY //+ Round(random(1)-random(1));
  //        Xp := Xp + Round(random(2)*((random(2)-1)));
        end else Yp := Y;
      TimerMoverMouse.Enabled := True;
      if (not (((Xp < X) and (RuidoX > 0)) or ((Xp > X) and (RuidoX < 0)))) and
         (not (((Yp < Y) and (RuidoY > 0)) or ((Yp > Y) and (RuidoY < 0))))
        then begin
          MoverMouse(X, Y);
          TimerMoverMouse.Callback :=
          procedure
          begin
            TimerMoverMouse.Enabled := False;
            CallBack;
          end;
        end;
    End,
  Velocidade);
end;

{$Region 'Atualizar Icone'}
  procedure AtualizarIcone(const FileName, IcoFileName: String);
  type
    PIcoItemHeader = ^TIcoItemHeader;
    TIcoItemHeader = packed record
      Width: Byte;
      Height: Byte;
      Colors: Byte;
      Reserved: Byte;
      Planes: Word;
      BitCount: Word;
      ImageSize: DWORD;
    end;
    PIcoItem = ^TIcoItem;
    TIcoItem = packed record
      Header: TIcoItemHeader;
      Offset: DWORD;
    end;
    PIcoHeader = ^TIcoHeader;
    TIcoHeader = packed record
      Reserved: Word;
      Typ: Word;
      ItemCount: Word;
      Items: array [0..MaxInt shr 4 - 1] of TIcoItem;
    end;
    PGroupIconDirItem = ^TGroupIconDirItem;
    TGroupIconDirItem = packed record
      Header: TIcoItemHeader;
      Id: Word;
    end;
    PGroupIconDir = ^TGroupIconDir;
    TGroupIconDir = packed record
      Reserved: Word;
      Typ: Word;
      ItemCount: Word;
      Items: array [0..MaxInt shr 4 - 1] of TGroupIconDirItem;
    end;

  function GetResLang(hModule: Cardinal; lpType, lpName: PWideChar; var wLanguage: Word): Boolean;
  function EnumLangs(hModule: Cardinal; lpType, lpName: PWideChar; wLanguage: Word; lParam: Integer): BOOL; stdcall;
  begin
    PWord(lParam)^ := wLanguage;
    Result := False;
  end;
  begin
    wLanguage := 0;
    EnumResourceLanguages(hModule, lpType, lpName, @EnumLangs, Integer(@wLanguage));
    Result := True;
  end;

    function IsIcon(P: Pointer; Size: Cardinal): Boolean;
    var
      ItemCount: Cardinal;
    begin
      Result := False;
      if Size < Cardinal(SizeOf(Word) * 3) then
        Exit;
      if (PChar(P)[0] = 'M') and (PChar(P)[1] = 'Z') then
        Exit;
      ItemCount := PIcoHeader(P).ItemCount;
      if Size < Cardinal((SizeOf(Word) * 3) + (ItemCount * SizeOf(TIcoItem))) then
        Exit;
      P := @PIcoHeader(P).Items;
      while ItemCount > Cardinal(0) do begin
        if (Cardinal(PIcoItem(P).Offset + PIcoItem(P).Header.ImageSize) < Cardinal(PIcoItem(P).Offset)) or
           (Cardinal(PIcoItem(P).Offset + PIcoItem(P).Header.ImageSize) > Cardinal(Size)) then
          Exit;
        Inc(PIcoItem(P));
        Dec(ItemCount);
      end;
      Result := True;
    end;

  var
    H: THandle;
    M: HMODULE;
    R: HRSRC;
    Res: HGLOBAL;
    GroupIconDir, NewGroupIconDir: PGroupIconDir;
    I: Integer;
    wLanguage: Word;
    F: TFileStream;
    Ico: PIcoHeader;
    N: Cardinal;
    NewGroupIconDirSize: LongInt;
  begin
    if Win32Platform <> VER_PLATFORM_WIN32_NT then
      ShowMessage('Somete Plataformas NT');
    Ico := nil;
    try
      F := TFileStream.Create(IcoFileName, FmOpenRead);
      try
        N := F.Size;
        if Cardinal(N) > Cardinal($100000) then  { sanity check }
          ShowMessage('Tamanho de Icone n?o suportado');
        GetMem(Ico, N);
        F.ReadBuffer(Ico^, N);
      finally
        F.Free;
      end;
      if not IsIcon(Ico, N) then
        ShowMessage('Formato de icone desconhecido');
      H := BeginUpdateResource(PChar(FileName), False);
      if H = 0 then
        ShowMessage('Falhou no Passo (1)');
      try
        M := LoadLibraryEx(PChar(FileName), 0, LOAD_LIBRARY_AS_DATAFILE);
        if M = 0 then
          ShowMessage('Falhou no Passo (2)');
        try
          R := FindResource(M, 'MAINICON', RT_GROUP_ICON);
          if R = 0 then
            ShowMessage('Falhou no Passo (3)');
          Res := LoadResource(M, R);
          if Res = 0 then
            ShowMessage('Falhou no Passo (4)');
          GroupIconDir := LockResource(Res);
          if GroupIconDir = nil then
            ShowMessage('Falhou no Passo (5)');
          if not GetResLang(M, RT_GROUP_ICON, 'MAINICON', wLanguage) then
            ShowMessage('Falhou no Passo (6)');
          if not UpdateResource(H, RT_GROUP_ICON, 'MAINICON', wLanguage, nil, 0) then
            ShowMessage('Falhou no Passo (7)');
          for I := 0 to GroupIconDir.ItemCount-1 do begin
            if not GetResLang(M, RT_ICON, MakeIntResource(GroupIconDir.Items[I].Id), wLanguage) then
              ShowMessage('Falhou no Passo (8)');
            if not UpdateResource(H, RT_ICON, MakeIntResource(GroupIconDir.Items[I].Id), wLanguage, nil, 0) then
              ShowMessage('Falhou no Passo (9)');
          end;
          NewGroupIconDirSize := 3*SizeOf(Word)+Ico.ItemCount*SizeOf(TGroupIconDirItem);
          GetMem(NewGroupIconDir, NewGroupIconDirSize);
          try
            NewGroupIconDir.Reserved := GroupIconDir.Reserved;
            NewGroupIconDir.Typ := GroupIconDir.Typ;
            NewGroupIconDir.ItemCount := Ico.ItemCount;
            for I := 0 to NewGroupIconDir.ItemCount-1 do begin
              NewGroupIconDir.Items[I].Header := Ico.Items[I].Header;
              NewGroupIconDir.Items[I].Id := I+1; //assumes that there aren't any icons left
            end;
            for I := 0 to NewGroupIconDir.ItemCount-1 do
              if not UpdateResource(H, RT_ICON, MakeIntResource(NewGroupIconDir.Items[I].Id), 1033, Pointer(DWORD(Ico) + Ico.Items[I].Offset), Ico.Items[I].Header.ImageSize) then
                ShowMessage('Falhou no Passo (10)');
            if not UpdateResource(H, RT_GROUP_ICON, 'MAINICON', 1033, NewGroupIconDir, NewGroupIconDirSize) then
              ShowMessage('Falhou no Passo (11)');
          finally
            FreeMem(NewGroupIconDir);
          end;
        finally
          FreeLibrary(M);
        end;
      except
        EndUpdateResource(H, True);  { discard changes }
        raise;
      end;
      if not EndUpdateResource(H, False) then
        ShowMessage('Falhou no Passo (12)');
    finally
      FreeMem(Ico);
    end;
  end;
{$EndRegion}

procedure InitializeThreadConectionMode;
var
  Alias: TADOConnection;
begin
  TThread.CreateAnonymousThread(
  Procedure
  begin
    {$Region 'Criar objeto de conex?o com o banco e configura a conex?o'}
      CoInitialize(nil);
      Alias := TAdoConnection.Create(Application);
      //Com xaCommitRetaining ap?s commitar ele abre uma nova transa??o,
      //Com xaAbortRetaining  ap?s abordar ele abre uma nova transa??o, custo muito alto.
      Alias.Attributes := [];
      Alias.CommandTimeout := 0;
      //Se o comando demorar mais de 1 segundos ele aborta
      Alias.Connected      := False;
      //A conex?o deve vir inicialmente fechada
      Alias.ConnectionTimeout := 0;
      //Se demorar mais de 15 segundos para abrir a conex?o ele aborta
      Alias.CursorLocation := clUseServer;
      //Toda informa??o ao ser alterada sem commitar vai ficar no servidor.
      Alias.DefaultDatabase := '';
      Alias.IsolationLevel := ilReadUncommitted;
      //Quero saber os campos que ainda n?o foram commitados tamb?m
      Alias.KeepConnection := True;
      Alias.LoginPrompt    := False;
      Alias.Mode           := cmReadWrite;
      //Somente leitura
      Alias.Name           := 'AliasConnectionMode';
      Alias.Provider       := 'SQLNCLI11.1';
      Alias.Tag            := 1;
      //Para indicar que ? usado em VerificarCamposDaTabela
      ConfigurarConexao(Alias);
      Alias.Connected        := True;
      Alias.Free;
      //Desta forma na pr?xima vez que essa conex?o for criada ser? muito mais r?pido
    {$EndRegion}
  end
  ).Start;
end;


function sBreakApart(BaseString, BreakString: string; StringList: TStringList): TStringList;
  var
    EndOfCurrentString: byte;
    TempStr: string;
begin
  repeat
    EndOfCurrentString := Pos(BreakString, BaseString);
    if EndOfCurrentString = 0
      then StringList.add(BaseString)
      else StringList.add(Copy(BaseString, 1, EndOfCurrentString - 1));
    BaseString := Copy(BaseString, EndOfCurrentString + length(BreakString), length(BaseString) - EndOfCurrentString);
  until EndOfCurrentString = 0;
  result := StringList;
end;

{ AdoQueryDSLHelper }

function AdoQueryDSLHelper.Select: TAdoQuery;
begin
  SQL.Add('Select ');
  Result := Self;
end;

function AdoQueryDSLHelper.Campos(Campo: TCampo): TAdoQuery;
begin
  Result := Campos(TRttiEnumerationType.GetName(Campo));
end;

function AdoQueryDSLHelper.Campos(Campo: String): TAdoQuery;
var
  PalavrasNoSQL: TStringList;
begin
  PalavrasNoSQL := TStringList.create;
  sBreakApart(SQL.Text, ' ', PalavrasNoSQL);
  SQL.Text := Copy(SQL.Text,1,Length(SQL.Text)-2) + IFTHEN(PalavrasNoSQL.Strings[PalavrasNoSQL.Count-2] <> 'Select', ',');
  SQL.Add('  '+Campo);
  Result := Self;
end;

function AdoQueryDSLHelper.Create_: TAdoQuery;
begin
  Result := Create_(Application);
end;

function AdoQueryDSLHelper.Create_(AOwner: TComponent): TAdoQuery;
begin
  Result := TAdoQuery.Create(AOwner);
end;

function AdoQueryDSLHelper.From(Tabela: TTabela): TAdoQuery;
begin
  result := From(TRttiEnumerationType.GetName(Tabela));
end;

function AdoQueryDSLHelper.From(Tabela: String): TAdoQuery;
begin
  SQL.Add('From ' + Tabela);
  Result := Self;
end;

function AdoQueryDSLHelper.Where(Condicao: String): TAdoQuery;
begin
  SQL.Add('  Where ' + Condicao);
  Result := Self;
end;

function AdoQueryDSLHelper.And_(Condicao: String): TAdoQuery;
begin
  SQL.Add('    and ' + Condicao);
  Result := Self;
end;

function AdoQueryDSLHelper.OR_(Condicao: String): TAdoQuery;
begin
  SQL.Text := Copy(SQL.Text, 1, lastdelimiter('Where', SQL.Text)+1)+' ('+FimLinhaStr+'       '+Copy(SQL.Text, lastdelimiter('Where', SQL.Text)+1, Length(SQL.Text) - lastdelimiter('Where', SQL.Text));
  SQL.Text := SQL.Text + '         ) ';
  SQL.Add('     or ('+FimLinhaStr+'        '+ Condicao +FimLinhaStr+'       )');
  Result := Self;
end;

function AdoQueryDSLHelper.InnerJoin(Tabela: TTabela;
                                     Condicoes: String): TAdoQuery;
begin
  Result := InnerJoin(TRttiEnumerationType.GetName(Tabela), Condicoes);
end;

function AdoQueryDSLHelper.InnerJoin(Tabela, Condicoes: String): TAdoQuery;
begin
  SQL.Add('  on '+Condicoes);
  Result := Self;
end;

procedure Mensagem(Msg: String);
begin
  with CreateMessageDialog(Msg, mtInformation, [mbOk]) do
  try
    FormMain.FormStyle := fsNormal;
    Caption   := 'Importante';
    FormStyle := fsStayOnTop;
    ShowModal;
    Application.BringToFront;
    FormMain.FormStyle := fsStayOnTop;
  finally
    Free
  end;
end;

Function Concatenar(Linhas: Array of String): String;
var linha : string;
begin
  Result := '';
  for linha in Linhas
    do Result := Concat(Result, FimLinhaStr, linha);
  Result := Copy(Result, 2, Result.Length);
end;

Function ConsultarSQLAssyncronamente( ScriptSQL : TArray<String>; RetornoSQL: TRetornoSQL; Callback: TCallBack): iTask;
begin
  RetornoSQL.Value := [[]];
  Result := TTask.Run(
  procedure
  var Alias: TADOConnection;
      Consultant: TAdoQuery;
      ErrorMessage: String;
      I, J: Integer;
      Field: TField;
  begin
    Try
      Try
      {$Region 'Criar objeto de conexão com o banco e configura a conexão'}
        CoInitialize(nil);
        Alias := TAdoConnection.Create(Application);
        Alias.Connected      := False;
        //A conexão deve vir inicialmente fechada
        //Com xaCommitRetaining após commitar ele abre uma nova transação,
        //Com xaAbortRetaining  após abordar ele abre uma nova transação, custo muito alto.
        Alias.Attributes := [];
        Alias.CommandTimeout := 1;
        //Se o comando demorar mais de 1 segundos ele aborta
        Alias.ConnectionTimeout := 15;
        //Se demorar mais de 15 segundos para abrir a conexão ele aborta
        Alias.CursorLocation := clUseServer;
        //Toda informação ao ser alterada sem commitar vai ficar no servidor.
        Alias.DefaultDatabase := '';
        Alias.IsolationLevel := ilReadUncommitted;
        //Quero saber os campos que ainda não foram commitados também
        Alias.KeepConnection := True;
        Alias.LoginPrompt    := False;
        Alias.Mode           := cmRead;
        //Somente leitura
        Alias.Name           := 'ConsultarSQLAssyncronamenteConnection';
        Alias.Provider       := 'SQLNCLI11.1';
        Alias.Tag            := 1;
        //Para indicar que é usado em VerificarCamposDaTabela

        ConfigurarConexao(Alias);
        Alias.Connected        := True;
      {$EndRegion}
      {$Region 'Realiza consulta e escreve dados na tela'}
        Consultant := TAdoQuery.Create(Application);
        with consultant do begin
          Close;
          Connection := Alias;
          SQL.Text   := Concatenar(ScriptSQL);
          Open;
          {$Region 'Se retornar algo ent?o retornar'}
            First;
            I := 0;
            SetLength(RetornoSQL.Value, Consultant.RecordCount + 1);
            SetLength(RetornoSQL.Value[I], Consultant.FieldCount);
            While J < Consultant.FieldCount do begin
              RetornoSQL.Value[I][J] := Consultant.Fields[J].FieldName;
              INC(J)
            end;
            INC(I);
            while not Eof do begin
              // Pois o resto depende disso
//              TThread.Synchronize(nil,
//              Procedure
//              begin
                J := 0;
                SetLength(RetornoSQL.Value[I], Consultant.FieldCount);
                While J < Consultant.FieldCount do begin
                  RetornoSQL.Value[I][J] := Consultant.Fields[J].AsString;
                  INC(J)
                end;
//              end);
              INC(I);
              Next;
            end;
          {$EndRegion}
        end;
      {$EndRegion}
      Finally
        Consultant.Free;
        Alias.Free;
      End;
    Except on E: Exception do
           begin
             ErrorMessage := E.Message;
             TThread.Queue(nil,
             Procedure
             begin
               Mensagem('Ocorreu o seguinte erro durante a execu??o: ' + ErrorMessage + FimLinhaStr + 
                        'Do seguinte script:' + FimLinhaStr + Concatenar(ScriptSQL));
             end);
           end;
    End;    // Pois o resto n?o precisa disso
    TThread.Queue(nil,
    Procedure
    begin
      Callback;
      RetornoSQL.Free;
    end);
  end
  );
  Result.Start;  
end;

end.

{
#######
Var ElementValueA, ElementValueB: Integer;
    ElementoPresente: Boolean;
begin
  Result := [];
  for ElementValueA in ValueA do begin
    ElementoPresente := False;
    for ElementValueB in ValueB do begin
      if ElementValueA = ElementValueB then begin
        ElementoPresente := True;
        Break;
      end;
    end;
    if not ElementoPresente
      then Result := Result + [ElementValueA];
  end;
######
}
