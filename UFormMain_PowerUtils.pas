unit UFormMain_PowerUtils;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvFullColorSpaces, JvFullColorCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, UModuloDeRastreio_PowerUtils;

type
  TFormMain = class(TForm)
    ElipseMain: TJvFullColorCircle;
    Panel_Configurações: TPanel;
    BitBtn_Fechar: TBitBtn;
    BitBtnOcultar: TBitBtn;
    Panel_RastreiaInput: TPanel;
    BitBtn1: TBitBtn;
    Panel_InformaçõesAdicionais: TPanel;
    Label1: TLabel;
    PanelConexão: TPanel;
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
  if Panel_InformaçõesAdicionais.Visible
    then begin
      Panel_InformaçõesAdicionais.Hide;
      PanelConexão.Show;
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
      Panel_InformaçõesAdicionais.Show;
      PanelConexão.Hide;
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

  Panel_InformaçõesAdicionais.Top  := 53;
  Panel_InformaçõesAdicionais.Left := 91;

  PanelConexão.Top  := 53;
  PanelConexão.Left := 91;

  BorderStyle := bsNone;
  Regiao      := CreateEllipticRgn(0,0, Width, Height);
  SetWindowRgn(Handle,Regiao,true);

  RastreadorDeInput.New(RastreadorDeInput);

  DefinirGatilhos;
end;

procedure TFormMain.DefinirGatilhos;
begin
  //###### DEFINIÇÃO DOS GATILHOS #######
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
  NovoArq.Add('Usuário         : '+EditUsuario.Text);
  NovoArq.Add('Senha           : '+EditSenha.Text);
  NovoArq.Add('LicencaDataBase : '+EditDataBase.Text);
  NovoArq.Add('O Sistema só irá considerar as 4 primeiras linhas e somente o que estiver após o ":",');
  NovoArq.Add('ele não ira considerar espaços adicionais a direita e esquerda.');

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
