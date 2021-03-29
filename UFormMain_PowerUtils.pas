unit UFormMain_PowerUtils;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvFullColorSpaces, JvFullColorCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, UModuloDeRastreio_PowerUtils;

type
  TFormMain = class(TForm)
    ElipseMain: TJvFullColorCircle;
    Panel_Configura��es: TPanel;
    BitBtn_Fechar: TBitBtn;
    BitBtnOcultar: TBitBtn;
    Panel_RastreiaInput: TPanel;
    BitBtn1: TBitBtn;
    Panel_Informa��esAdicionais: TPanel;
    Label1: TLabel;
    PanelConex�o: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    EditSenha: TEdit;
    EditDataBase: TEdit;
    Label6: TLabel;
    EditUsuario: TEdit;
    EditServidor: TEdit;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn_FecharClick(Sender: TObject);
    procedure BitBtnOcultarClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditConexaoExit(Sender: TObject);
  private
    procedure DefinirGatilhos;
    { Private declarations }
  public
    { Public declarations }
    RastreadorDeInput: TRastreador;
    PassarSQLParaDelphiAtivo, IgualarDistanciamentoEntreOsIguaisAtivo, VerificarCamposDaTabelaAtivo, InvocarRegionAtivo, IdentarAtivo: Boolean;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses UUtilitarios_PowerUtils, UProceduresDosGatilhos_PowerUtils;

procedure TFormMain.BitBtn_FecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.BitBtn1Click(Sender: TObject);
var
  ExePath, Txt, CaminhoENomeArquivo: String;
  arquivo: TStringList;
begin
  if Panel_Informa��esAdicionais.Visible
    then begin
      Panel_Informa��esAdicionais.Hide;
      PanelConex�o.Show;
      ExePath    := ExtractFilePath(Application.ExeName);
      arquivo := TStringList.Create;
      CaminhoENomeArquivo := ExePath + 'Config.ini';
      arquivo.LoadFromFile(CaminhoENomeArquivo);
      Txt := arquivo.Strings[0];
      EditServidor.Text := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt) ));
      Txt := arquivo.Strings[1];
      EditUsuario.Text  := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
      Txt := arquivo.Strings[2];
      EditSenha.Text    := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
      Txt := arquivo.Strings[3];
      EditDataBase.Text := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
      arquivo.Free;
    end
    else begin
      Panel_Informa��esAdicionais.Show;
      PanelConex�o.Hide;
    end;
end;

procedure TFormMain.BitBtnOcultarClick(Sender: TObject);
begin
  Hide;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RastreadorDeInput.Active := False;
  Action := caFree;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var Regiao:HRGN;
begin
  with Constraints do begin
    Height := MinHeight;
    Width  := MinWidth;
  end;

  ElipseMain.Left := -5;
  ElipseMain.Top  := -8;

  Panel_Informa��esAdicionais.Top  := 53;
  Panel_Informa��esAdicionais.Left := 91;

  PanelConex�o.Top  := 53;
  PanelConex�o.Left := 91;

  BorderStyle := bsNone;
  Regiao      := CreateEllipticRgn(0,0, Width, Height);
  SetWindowRgn(Handle,Regiao,true);

  RastreadorDeInput.New(RastreadorDeInput);

  DefinirGatilhos;
end;

procedure TFormMain.DefinirGatilhos;
begin
  //###### DEFINI��O DOS GATILHOS #######
  RastreadorDeInput.Gatilhos := RastreadorDeInput.Gatilhos +
   [function: TCallBack
    begin
      Result := Procedure Begin End;
      if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD0) or TeclaEstaPressionada(48))
        then Result :=
          Procedure
          Begin
            if Showing
              then hide
              else begin
                Show;
                Application.BringToFront;
                Memo1.SetFocus;
              end;
          end;
    end,
    function: TCallBack
        begin
          Result := Procedure Begin End;
          if  (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD1) or TeclaEstaPressionada(49))
            then TProcedureDosGatilhos.PassarSQLParaDelphi(TRUE);
        end,
    function: TCallBack
        begin
          Result := Procedure Begin End;
          if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD2) or TeclaEstaPressionada(50))
            then TProcedureDosGatilhos.PassarDelphiParaSQL(TRUE);
        end,
    function: TCallBack
        begin
          Result := Procedure Begin End;
          if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD3) or TeclaEstaPressionada(51))
            then TProcedureDosGatilhos.InvocarRegion;
        end,
    function: TCallBack
        begin
          Result := Procedure Begin End;
          if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD4) or TeclaEstaPressionada(52))
            then TProcedureDosGatilhos.IgualarDistanciamentoEntreOsIguais;
        end,
    function: TCallBack
        begin
          Result := Procedure Begin End;
          if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD5) or TeclaEstaPressionada(53))
            then TProcedureDosGatilhos.VerificarCamposDaTabela;
        end,
    function: TCallBack
        begin
          Result := Procedure Begin End;
          if (TeclaEstaPressionada(VK_RCONTROL) or TeclaEstaPressionada(VK_LCONTROL)) and (TeclaEstaPressionada(VK_NUMPAD6) or TeclaEstaPressionada(54))
            then TProcedureDosGatilhos.VerificarProcedimentos;
        end
   ];
end;

procedure TFormMain.EditConexaoExit(Sender: TObject);
var
  CaminhoENomeArquivo, ExePath: String;
  NovoArq: TStringList;
begin
  ExePath    := ExtractFilePath(Application.ExeName);
  CaminhoENomeArquivo := ExePath + 'Config.ini';

  NovoArq := TStringList.Create;
  NovoArq.Add('Servidor        : '+EditServidor.Text);
  NovoArq.Add('Usu�rio         : '+EditUsuario.Text);
  NovoArq.Add('Senha           : '+EditSenha.Text);
  NovoArq.Add('LicencaDataBase : '+EditDataBase.Text);
  NovoArq.Add('O Sistema s� ir� considerar as 4 primeiras linhas e somente o que estiver ap�s o ":",');
  NovoArq.Add('ele n�o ira considerar espa�os adicionais a direita e esquerda.');

  NovoArq.SaveToFile(CaminhoENomeArquivo);

  NovoArq.Free;
end;

procedure TFormMain.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const SC_DRAGMOVE = $F012;
begin
  if Button = mbleft then
  begin
    ReleaseCapture;
    FormMain.Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

end.
