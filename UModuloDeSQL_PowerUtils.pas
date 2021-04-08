unit UModuloDeSQL_PowerUtils;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,  System.Threading,
  ActiveX, Data.DB, Data.Win.ADODB, Vcl.DBGrids;

type
  TFormSQL = class(TForm)
    Panel_Informa��esAdicionais: TPanel;
    Timer1: TTimer;
    Panel3: TPanel;
    BitBtn_Fechar: TBitBtn;
    BitBtnIniciar: TBitBtn;
    BitBtnOcultar: TBitBtn;
    PanelResultado: TPanel;
    MemoMgsErro: TMemo;
    Panel2: TPanel;
    MemoSQL: TMemo;
    Splitter1: TSplitter;
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn_FecharClick(Sender: TObject);
    procedure BitBtnExecutePauseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    Alias: TADOConnection;
    Consultant: TAdoQuery;
    DS: TDataSource;
    DBGrid: TDBGrid;
  public
    { Public declarations }
  end;

var
  FormSQL: TFormSQL;

implementation

{$R *.dfm}

uses UFormMain_PowerUtils, UUtilitarios_PowerUtils, HelpersPadrao;

procedure TFormSQL.BitBtnExecutePauseClick(Sender: TObject);
var BitBtnExecutePause: Array of TBitBtn;
    Btns:               TBitBtn;
    Thread: iTask;
begin
  BitBtnExecutePause := [BitBtnIniciar, BitBtnOcultar];
  for Btns in BitBtnExecutePause
    do Btns.Visible := Not Btns.Visible;

  MemoMgsErro.Visible    := False;
  Splitter1.Visible      := False;
  PanelResultado.Visible := False;

  if Sender = BitBtnIniciar
    then begin
      BitBtnOcultar.Enabled  := False;
      Thread := TTask.Run(
      procedure
      var ErrorMessage: String;
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
            Alias.Name           := 'BitBtnExecutePauseClickConnection';
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
              SQL.Text      := MemoSQL.Text;
              DS := TDataSource.Create(FormSQL);
              DS.DataSet := Consultant;
              Open;
              PanelResultado.Visible := not IsEmpty;
              {$Region 'Se retornar algo ent�o mostrar'}
              TThread.Synchronize(nil,
              Procedure
              var I: Integer;
              Begin
                DBGrid  := TDBGrid.Create(FormSQL);
                with DBGrid do begin
                  Parent := PanelResultado;
                  Align := alClient;
                  Name := 'BitBtnExecutePauseClickGrid';
                  Visible := True;
                  Left    := 0;
                  Top     := 0;
                  DataSource := DS;
                  I := 0;
                  While I < Consultant.FieldCount do begin
                    Columns.Insert(I);
                    Columns[I].FieldName        := Consultant.Fields[I].FieldName;
                    Columns[I].Title.Caption    := Consultant.Fields[I].FieldName;
                    Columns[I].Title.Alignment  := taCenter;
                    Columns[I].Title.Font.Style := [fsBold];
                    Columns[I].Width:=155;
                    INC(I);
                  end;
                end;
                Application.BringToFront;
                Splitter1.Visible      := True;
              End);
              {$EndRegion}
            end;
          {$EndRegion}
          Finally
            BitBtnOcultar.Enabled   := True;
          End;
        Except on E: Exception do
               begin
                 ErrorMessage := E.Message;
                 TThread.Queue(nil,
                 Procedure
                 begin
                   PanelResultado.Visible := True;
                   MemoMgsErro.Visible    := True;
                   Splitter1.Visible      := True;
                   BitBtnOcultar.Enabled  := True;
                   MemoMgsErro.Text       := ErrorMessage;
                   Mensagem('Ocorreu o seguinte erro durante a execu��o: ' + ErrorMessage + FimLinhaStr +
                            'Do seguinte script:' + FimLinhaStr + MemoSQL.Text);
                 end);
               end;
        End;
      end);
      Thread.Start;
    end
    else begin
      DS.Free;
      Consultant.Free;
      Alias.Free;
      DBGrid.Free;
      PanelResultado.Visible := False;
      BitBtnOcultar.Visible  := False;
    end;
end;

procedure TFormSQL.BitBtn_FecharClick(Sender: TObject);
begin
  FormMain.Close;
end;

procedure TFormSQL.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  DS.Free;
  Consultant.Free;
  Alias.Free;
  DBGrid.Free;
end;

procedure TFormSQL.Timer1Timer(Sender: TObject);
begin
  if Top <> (FormMain.Top + FormMain.Height div 2 + FormMain.Panel_RastreiaInput.Height div 2)
    then Top := FormMain.Top + FormMain.Height div 2 + FormMain.Panel_RastreiaInput.Height div 2;
  if Left <> (FormMain.Left - (Width - FormMain.Width) div 2)
    then Left := FormMain.Left - (Width - FormMain.Width) div 2;
end;

end.
