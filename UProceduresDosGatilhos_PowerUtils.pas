unit UProceduresDosGatilhos_PowerUtils;

interface

{$Region 'uses'}
  uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms,  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, JvExComCtrls, JvComCtrls,
    Vcl.Clipbrd, Data.DB, Data.Win.ADODB, ActiveX, Vcl.Grids, Vcl.DBGrids;
{$EndRegion}

Type
  TProcedureDosGatilhos = Class
  public
    class procedure IgualarDistanciamentoEntreOsIguais;
    class procedure PassarDelphiParaSQL(ChamadaPeloTeclado: Boolean = false);
    class procedure PassarSQLParaDelphi(ChamadaPeloTeclado: Boolean = false);
    class procedure VerificarCamposDaTabela;
    class procedure VerificarProcedimentos;
    class procedure InvocarRegion;
  End;

implementation

uses UFormMain_PowerUtils, UUtilitarios_PowerUtils;

class procedure TProcedureDosGatilhos.VerificarProcedimentos;
var
  Thread: TThread;
  Texto: String;
  Alias:      TADOConnection;
  Consultant: TADOQuery;
  Form: TForm;
  DS: TDataSource;
begin
  {$Region 'Verificar se já está ativo'}
    if FormMain.VerificarCamposDaTabelaAtivo
      then Exit;
    FormMain.VerificarCamposDaTabelaAtivo := True;
  {$EndRegion}

  {$Region 'Control + C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}
  SetTimeOut(
  Procedure
  Begin
    Texto       := Clipboard.AsText;
    Thread := TThread.CreateAnonymousThread(
    Procedure
    Begin
      TRY
        {$Region 'Criar objeto de conexão com o banco e configura a conexão'}
          Thread.Synchronize(Thread,
          Procedure
          Begin
            Form := Tform.Create(FormMain);
            Form.Width  := 500;
            Form.Height := 250;
            Form.Show;
            Form.BorderStyle := bsSizeable;
          End);
          coInitialize(nil);
          Alias := TAdoConnection.Create(Form);
          Alias.Attributes := [];
          Alias.CommandTimeout := 1;;
          //Com xaCommitRetaining após commitar ele abre uma nova transação,
          //Com xaAbortRetaining  após abordar ele abre uma nova transação, custo muito alto.
          //Se o comando demorar mais de 1 segundos ele aborta
          Alias.Connected      := False;
          //A conexão deve vir inicialmente fechada
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
          Alias.Name           := 'VerificarProcedimentosConnection';
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
            SQL.Text := 'SELECT '+FimLinhaStr+
                        'case type when ''P'' then ''Stored procedure'' '+FimLinhaStr+
                        'when ''FN'' then ''Function'' '+FimLinhaStr+
                        'when ''TF'' then ''Function'' '+FimLinhaStr+
                        'when ''TR'' then ''Trigger'' '+FimLinhaStr+
                        'when ''V'' then ''View'' '+FimLinhaStr+
                        'else ''Outros Objetos'' '+FimLinhaStr+
                        'end as Procedimento,'+FimLinhaStr+
                        'B.name Nome_Do_Procedimento, A.Text Conteudo '+FimLinhaStr+
                        'FROM syscomments A (nolock)'+FimLinhaStr+
                        'JOIN sysobjects B (nolock) on A.Id = B.Id'+FimLinhaStr+
                        'WHERE A.Text like ''%'+Texto+'%''';
            DS := TDataSource.Create(Form);
            DS.DataSet := Consultant;
            Open;
            Thread.Synchronize(Thread,
            Procedure
            var DBGrid: TDBGrid;
            Begin
              DBGrid  := TDBGrid.Create(Form);
              with DBGrid do begin
                Parent := Form;
                Align := alClient;
                Name := 'Grid';
                Visible := True;
                Left    := 0;
                Top     := 0;
                DataSource := DS;
                Columns.Insert(0);
                Columns[0].FieldName:='Procedimento';
                Columns[0].Title.Caption:='Procedimento';
                Columns[0].Title.Alignment := taCenter;
                Columns[0].Title.Font.Style := [fsBold];
                Columns[0].Width:=155;
                Columns.Insert(1);
                Columns[1].FieldName:='Nome_Do_Procedimento';
                Columns[1].Title.Caption:='Nome';
                Columns[1].Title.Alignment := taCenter;
                Columns[1].Title.Font.Style := [fsBold];
                Columns[1].Width:=200;
                Columns.Insert(2);
                Columns[2].FieldName:='Conteudo';
                Columns[2].Title.Caption:='Conteudo';
                Columns[2].Title.Alignment := taCenter;
                Columns[2].Title.Font.Style := [fsBold];
                Columns[2].Width:=65;
              end;
              Application.BringToFront;
            End);
          end;
        {$EndRegion}
      FINALLY
        {$Region 'Setar TimeOut para reabilitar uso da funcionalidade'}
          SetTimeOut(
            Procedure
            begin
              FormMain.VerificarCamposDaTabelaAtivo := False;
            End,
          1000);
        {$EndRegion}
      END;
    End);
    Thread.Start;
  end,
  100);
end;

class procedure TProcedureDosGatilhos.VerificarCamposDaTabela;
{$Region 'var ...'}
  var
    Texto: string;
{$EndRegion}
begin
  {$Region 'Verificar se já está ativo'}
    if FormMain.VerificarCamposDaTabelaAtivo
      then Exit;
    FormMain.VerificarCamposDaTabelaAtivo := True;
  {$EndRegion}

  {$Region 'Control + C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}

  {$Region 'Realiza consulta para trazer dados da tabela ou campo informado'}
    SetTimeOut(
      Procedure
      {$Region 'Var ...'}
        var Alias:      TADOConnection;
            Consultant: TADOQuery;
            Canvas : TCanvas;
            vHDC : HDC;
            pt: TPoint;
            X: Integer;
            TamanhoMaxString: integer;
            SELECT_: String;
            TABELAOUCAMPOOUPROCEDIMENTOS: String;
            Thread: TThread;
      {$EndRegion}
      begin
        {$Region 'Cria Thread para realizar a consulta para caso ela for muito grande não fique aparente ao usuário(não usei os eventos da AdoQuery pois daria mais trabalho de vincular.'}
          Thread := TThread.CreateAnonymousThread(
          procedure
          {$Region '...'}
            label FimWith;
          {$EndRegion}
          begin
            TRY
              Texto       := Clipboard.AsText;

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
                Alias.Name           := 'VerificarCamposDaTabelaConnection';
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
                  TABELAOUCAMPOOUPROCEDIMENTOS := 'TABELA';
                  {$Region 'Montar SELECT'}
                    SELECT_        := 'Select'+FimLinhaStr+
                                      'object_name(object_id) as Tabela,'+FimLinhaStr+
                                      '  sc.name as Campo,'+FimLinhaStr+
                                      '  st.name as Tipo,'+FimLinhaStr+
                                      '  sc.max_length as tamanho,'+FimLinhaStr+
                                      '  case sc.is_nullable when 0 then ''NÃO'' else ''SIM'' end as PermiteNulo'+FimLinhaStr+
                                      'From'+FimLinhaStr+
                                      '  sys.columns sc'+FimLinhaStr+
                                      'Inner Join'+FimLinhaStr+
                                      '  sys.types st On st.system_type_id = sc.system_type_id and st.user_type_id = sc.user_type_id'+FimLinhaStr+
                                      'where sc.name like @pesquisaCampo and ( (object_name(object_id) = @pesquisaTabela) or (object_name(object_id) like (@pesquisaTabela+''_'')))'+FimLinhaStr+
                                      'order by sc.is_nullable, sc.name';
                  {$EndRegion}

                  {$Region 'Colocar SELECT NA QUERY'}
                    SQL.Text      := 'declare @pesquisaCampo varchar(100)'+FimLinhaStr+
                                     'declare @pesquisaTabela varchar(100)'+FimLinhaStr+
                                     'set @pesquisaCampo  = ''%'''+FimLinhaStr+
                                     'set @pesquisaTabela = '''+Texto+''''+FimLinhaStr+
                                     ''+FimLinhaStr+
                                     SELECT_;
                  {$EndRegion}

                  Open;
                  {$Region 'Se n�o retornar nada, tentar fazer o mesmo considerando ele como campo ao inv�s de tabela'}
                    if IsEmpty then begin
                      TABELAOUCAMPOOUPROCEDIMENTOS := 'CAMPO';
                      SQL.Text      := 'declare @pesquisaCampo varchar(100)'+FimLinhaStr+
                                       'declare @pesquisaTabela varchar(100)'+FimLinhaStr+
                                       'set @pesquisaTabela = ''%'''+FimLinhaStr+
                                       'set @pesquisaCampo  = '''+Texto+''''+FimLinhaStr+
                                       ''+FimLinhaStr+
                                       SELECT_;
                      Open;
                      {$Region 'Se vazio ir ao fim do with'}
                        if IsEmpty then begin
                          goto FimWith;
                          //Aten��o use goto com responsabilidade, ele aumenta a complexidade do c�digo muito f�cilmente,
                          //use o m�nimo poss�vel e de prefer�ncia simulando um break (indo para baixo);
                        end;
                      {$EndRegion}
                    end;
                  {$EndRegion}


                  {$Region 'Configura canvas'}
                    vHDC := GetDC(0);
                    Canvas := TCanvas.Create;
                    Canvas.Handle      := vHDC;
                    Canvas.Pen.Color   := ClRed;
                    Canvas.Brush.Color := ClRed;
                    GetCursorPos(pt);
                  {$EndRegion}
                  {$Region 'Ir ao primeiro registro retornado pela consulta'}
                    First;
                  {$EndRegion}

                  {$Region 'Localiza tamanho máximo das strings retornadas, para que com isso seja possivel definir o tamanho do retangulo'}
                    TamanhoMaxString := Length(FieldByName('Tabela').AsString);
                    while not eof do begin
                      if Length(FieldByName('Campo').AsString) > TamanhoMaxString
                        then TamanhoMaxString := Length(FieldByName('Campo').AsString);
                      Next;
                    end;
                  {$EndRegion}

                  {$Region 'Ir ao primeiro registro retornado pela consulta'}
                    First;
                  {$EndRegion}

                  {$Region 'Desenha o retangulo na tela'}
                    X := 1;
                    Canvas.Rectangle(Pt.x,Pt.y,Pt.x + ((TamanhoMaxString + 15) * 5), Pt.y + 10 + (52*RecordCount));
                  {$EndRegion}

                  {$Region 'Escreve dados das tabelas/campos na tela'}
                    {$Region 'Escreve dados sobre a Tabela ou Campo base da consulta'}
                      if TABELAOUCAMPOOUPROCEDIMENTOS = 'TABELA'
                        then Canvas.TextOut(Pt.x,Pt.y,              'TABELA:        ' + FieldByName('Tabela').AsString)
                        else Canvas.TextOut(Pt.x,Pt.y,              'CAMPO:         ' + FieldByName('Campo').AsString);
                    {$EndRegion}
                    while not eof do begin
                      {$Region 'Escreve os dados'}
                        if TABELAOUCAMPOOUPROCEDIMENTOS = 'TABELA'
                          then Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'CAMPO:         ' + FieldByName('Campo').AsString)
                          else Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'TABELA:        ' + FieldByName('Tabela').AsString);
                        Inc(X);
                        Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'TIPO:         ' + FieldByName('Tipo').AsString);
                        Inc(X);
                        Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'TAMANHO:      ' + FieldByName('tamanho').AsString);
                        Inc(X);
                        Canvas.TextOut(Pt.x,Pt.y + (13 * X), 'PERMITE NULO: ' + FieldByName('PermiteNulo').AsString);
                        INC(X);
                      {$EndRegion}

                      {$Region 'Vai ao próximo registro'}
                        Next;
                      {$EndRegion}
                    end;
                  {$EndRegion}

                  FimWith:
                  {$Region 'Libera objeto Query da memória'}
                    Free;
                  {$EndRegion}
                end;
              {$EndRegion}

              {$Region 'Libera objeto de conexão da memória'}
                Alias.Free;
              {$EndRegion}
            FINALLY
              Thread.Synchronize(Thread,
              procedure begin
                {$Region 'Setar TimeOut para reabilitar uso da funcionalidade'}
                  SetTimeOut(
                    Procedure
                    begin
                      FormMain.VerificarCamposDaTabelaAtivo := False;
                    End,
                  1000);
                {$EndRegion}
              end);
            END;

          end
          );
          Thread.Start;
        {$EndRegion}
      End,
    100);
  {$EndRegion}
end;

class procedure TProcedureDosGatilhos.IgualarDistanciamentoEntreOsIguais;
begin
  {$Region 'Verificar se j� est� ativo'}
    if FormMain.IgualarDistanciamentoEntreOsIguaisAtivo
      then Exit;
    FormMain.IgualarDistanciamentoEntreOsIguaisAtivo := True;
  {$EndRegion}

  {$Region 'Control + C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}

  {$Region 'Transformar o texto e dar control V'}
    SetTimeOut(
      Procedure
      var Texto, TextoFinal, TextoParcial: String;
          QtdeMaxDeCaracteresAteODoisPontosIgual, CharCountDaLinha:  integer;
          Char_:  Char;
          I, DepoisDo13: Integer;
          EncontrouDuploPonto: Boolean;
          TextoParcialAteODuploPonto: String;
          TextoParcialDepoisDoDuploPonto: String;
          EncontrouOperadorIgualNaLinha: Boolean;
          EncontrouEspaço: Boolean;
          NroEspacos: Integer;
      begin
        Texto       := Clipboard.AsText;
        TextoFinal  := '';

        {$Region 'Igualar altura dos ":="'}
          {$Region 'Remover espaços desnecessários'}
            TextoFinal := '';
            NroEspacos := 0;
            for char_ in Texto do begin
                if (char_ = ' ')
                  then begin
                    EncontrouEspaço            := True;
                    Inc(NroEspacos);
                  end
                  else
                if (char_ = ':') and (not EncontrouDuploPonto)
                  then begin
                    EncontrouDuploPonto            := True;
                  end
                  else
                if (char_ = '=') and (EncontrouDuploPonto)
                  then begin
                    EncontrouDuploPonto               := False;
                    EncontrouEspaço                   := False;
                    NroEspacos := 0;
                    TextoFinal := TextoFinal + ' :=';
                  end
                  else
                if EncontrouEspaço
                  then begin
                    if EncontrouDuploPonto
                      then TextoFinal := TextoFinal + ':';
                    for I := 1 to NroEspacos
                      do TextoFinal   := TextoFinal + ' ';
                    TextoFinal        := TextoFinal + Char_;
                    NroEspacos        := 0;
                    EncontrouEspaço   := False;
                  end
                  else begin
                    EncontrouDuploPonto := False;
                    TextoFinal          := TextoFinal + Char_;
                  end;
            end;
            Texto := TextoFinal;
          {$EndRegion}

          CharCountDaLinha := 1;
          QtdeMaxDeCaracteresAteODoisPontosIgual := 0;

          {$Region 'Verificar quantos char possui o operador de receber mais afastado'}
            for char_ in Texto do begin
              if (char_ = #13)
                then begin
                  CharCountDaLinha := 1;
                  EncontrouDuploPonto   := False;
                  EncontrouOperadorIgualNaLinha := False;
                end
                else
              if (char_ = ':') and (not EncontrouDuploPonto)
                then begin
                  EncontrouDuploPonto            := True;
                end
                else
              if (char_ = '=') and (EncontrouDuploPonto) and (not EncontrouOperadorIgualNaLinha)
                then begin
                  if CharCountDaLinha > QtdeMaxDeCaracteresAteODoisPontosIgual
                    then QtdeMaxDeCaracteresAteODoisPontosIgual := CharCountDaLinha;
                  CharCountDaLinha     := CharCountDaLinha + 1;
                  EncontrouDuploPonto            := False;
                  EncontrouOperadorIgualNaLinha     := True;
                end
                else CharCountDaLinha  := CharCountDaLinha + 1;
            end;
          {$EndRegion}

          {$Region 'Igualando igual'}
            EncontrouOperadorIgualNaLinha := False;
            EncontrouDuploPonto           := False;
            Texto        := Texto + #13;
            TextoParcial := Texto;
            TextoFinal   := '';
            for char_ in Texto do begin
               if (char_ = #13)
                  then begin
                    if POS(#10, TextoParcial) > 1
                      then TextoFinal             := TextoFinal + Copy(TextoParcial, 1, POS(#10, TextoParcial)) //Texto Final Recebe a linha
                      else TextoFinal             := TextoFinal + Copy(TextoParcial, 1, POS(#13, TextoParcial)); //Texto Final Recebe a linha
                    if POS(#10, TextoParcial) > 1
                      then TextoParcial           := Copy(TextoParcial, POS(#10, TextoParcial) + 1, length(TextoParcial))//Texto Parcial Remove a linha
                      else TextoParcial           := Copy(TextoParcial, POS(#13, TextoParcial) + 1, length(TextoParcial));//Texto Parcial Remove a linha
                    EncontrouDuploPonto           := False;
                    EncontrouOperadorIgualNaLinha := False;
                  end
                  else
                if (char_ = ':') and (not EncontrouDuploPonto)
                  then begin
                    EncontrouDuploPonto            := True;
                  end
                  else
                if (char_ = '=') and (EncontrouDuploPonto) and (not EncontrouOperadorIgualNaLinha)
                  then begin
                    EncontrouDuploPonto               := False;
                    EncontrouOperadorIgualNaLinha     := True;
                    if pos('for', TextoParcial) = 0 then begin
                      TextoParcialAteODuploPonto      := Copy(TextoParcial, 1, POS(':=', TextoParcial)-1);
                      TextoParcialDepoisDoDuploPonto  := Copy(TextoParcial, POS(':=', TextoParcial)+2, Length(TextoParcial));
                    TextoParcial                    := TextoParcialAteODuploPonto;
                      for I := 1 to (QtdeMaxDeCaracteresAteODoisPontosIgual - length(TextoParcialAteODuploPonto) - 2)
                      do TextoParcial                 := TextoParcial + ' ';
                    TextoParcial                     := TextoParcial + ':=';
                    TextoParcial                     := TextoParcial + TextoParcialDepoisDoDuploPonto;
                  end
                  end
                  else EncontrouDuploPonto            := False;
            end;
          {$EndRegion}

          TextoFinal     := Copy(TextoFinal,1,Length(TextoFinal)-1);
          Texto          := TextoFinal;
        {$EndRegion}

        ClipBoard.AsText := TextoFinal;

        {$Region 'Control + V'}
          SetTimeOut(
            Procedure
            begin
              PressionarControlEManter;
              PressionarTeclaV;
              SoltarControl;
            End,
          100);
        {$EndRegion}
      End,
    100);
  {$EndRegion}

  {$Region 'Setar TimeOut para reabilitar uso da funcionalidade'}
    SetTimeOut(
      Procedure
      begin
        FormMain.IgualarDistanciamentoEntreOsIguaisAtivo := False;
      End,
    1000);
  {$EndRegion}
end;

class procedure TProcedureDosGatilhos.PassarDelphiParaSQL(ChamadaPeloTeclado: Boolean = False);
{$Region 'var ...'}
  var
    Linha, Linha_, Texto, TextoFinal: String;
    char_: char;
    consecutivo: Boolean;
    Strings: TStrings;
{$EndRegion}
begin
  {$Region 'Verificar se funcionalidade ja não foi chamada'}
    if FormMain.PassarSQLParaDelphiAtivo
      then Exit;
    FormMain.PassarSQLParaDelphiAtivo   := True;
  {$EndRegion}

  {$Region 'Control C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}

  {$Region 'Passa o delphi para SQL'}
    SetTimeOut(
      Procedure
      var char_: char;
          Linha_: String;
      begin
        Texto              := Clipboard.AsText;
      TextoFinal         := '';

        consecutivo        := True;
      for char_ in Texto do begin
          if (char_ = '''') and (not Consecutivo)
            then begin
              TextoFinal   := TextoFinal + '''';
            consecutivo  := True;
          end
            else
          if (char_ = '''') and (Consecutivo)
            then begin
              consecutivo  := False;
          end
            else
          if char_ = #10
            then begin
              consecutivo  := True;
          end
            else
          if char_ = #13
            then begin
              TextoFinal   := Copy(TRIM(TextoFinal),1,Length(TRIM(TextoFinal))-14) +FimLinhaStr;
            consecutivo  := false;
          end
            else begin
              TextoFinal   := TextoFinal + char_;
            consecutivo  := False;
          end
        end;

        ClipBoard.AsText   := TextoFinal;

        SetTimeOut(
          Procedure
          begin
            PressionarControlEManter;
            PressionarTeclaV;
            SoltarControl;
          End,
        100);
      End,
    100);
  {$EndRegion}

  {$Region 'Seta timer para reabilitar uso da funcionalidade'}
    SetTimeOut(
      Procedure
      begin
        FormMain.PassarSQLParaDelphiAtivo := False;
      End,
    2000);
  {$EndRegion}

end;

class procedure TProcedureDosGatilhos.PassarSQLParaDelphi(ChamadaPeloTeclado: Boolean = False);
{$Region 'var ...'}
  var
    Linha, Linha_, Texto, Texto_: String;
    char_: char;
{$EndRegion}
begin
  {$Region 'Verifica se funcionalidade já não foi chamada para evitar reuso'}
    if FormMain.PassarSQLParaDelphiAtivo
      then Exit;
    FormMain.PassarSQLParaDelphiAtivo := True;
  {$EndRegion}

  {$Region 'Control C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}

  {$Region 'Passa o SQL para Delphi'}
    SetTimeOut(
      Procedure
      var char_: char;
      begin
        Texto             := ClipBoard.AsText;
        Texto_            := '''';
      for char_ in Texto do begin
          if char_ = ''''
            then Texto_   := Texto_ + ''''''
          else
          if char_ = #13
            then Texto_   := Texto_ + ''',' + #13
          else
          if char_ = #10
            then Texto_   := Texto_ + #10 + ''''
          else Texto_   := Texto_ + char_;
      end;
        ClipBoard.AsText  := Texto_ + '''' + #13;
        SetTimeOut(
          Procedure
          begin
            PressionarControlEManter;
            PressionarTeclaV;
            SoltarControl;
          End,
        100);
      End,
    100);
  {$EndRegion}

  {$Region 'Reabilita funcionalidade'}
    SetTimeOut(
      Procedure
      begin
        FormMain.PassarSQLParaDelphiAtivo := False;
      End,
    1000);
  {$EndRegion}
end;

class procedure TProcedureDosGatilhos.InvocarRegion;
{$Region 'var ...'}
  var Texto, TextoFinal, identamento : String;
      EncontrouTexto: Boolean;
{$EndRegion}
begin
  {$Region 'Verifica se essa funcionalidade já está ativa, ela não pode ser chamada várias vezes seguida'}
    if FormMain.InvocarRegionAtivo
      then Exit;
    FormMain.InvocarRegionAtivo := True;
  {$EndRegion}

  {$Region 'Control C'}
    PressionarControlEManter;
    PressionarTeclaC;
    SoltarControl;
  {$EndRegion}

  {$Region 'Coloca a region'}
    SetTimeOut(
      Procedure
      var i : integer;
          Char_ : Char;
      begin
        Texto       := Clipboard.AsText;
        TextoFinal  := '';
        for i := 1 to Length(Texto)-Length(Trim(Texto))-2
          do identamento  := identamento + ' ';
        Texto       := identamento + '{$Region ''Procedimentos''}'+FimLinhaStr
                                   +    Texto+FimLinhaStr+
                       identamento + '{$EndRegion}';

        EncontrouTexto         := False;
      for char_ in Texto do begin
          if (char_ <> ' ') and not (EncontrouTexto)
            then begin
              TextoFinal       := TextoFinal + '  ' + char_;
            EncontrouTexto   := True;
          end
            else
          if char_ = #10
            then begin
              TextoFinal     := TextoFinal + char_;
            EncontrouTexto := False;
          end
          else TextoFinal  := TextoFinal + char_;
      end;
        ClipBoard.AsText     := TextoFinal;

      SetTimeOut(
          Procedure
          begin
            PressionarControlEManter;
            PressionarTeclaV;
            SoltarControl;
          End,
        100);
      End,
    100);
  {$EndRegion}

  {$Region 'Reabilita o uso da funcionalidade'}
    SetTimeOut(
      Procedure
      begin
        FormMain.InvocarRegionAtivo := False;
      End,
    1000);
  {$EndRegion}
end;

end.
