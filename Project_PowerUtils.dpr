program Project_PowerUtils;

uses
  Vcl.Forms,
  UFormMain_PowerUtils in 'UFormMain_PowerUtils.pas' {FormMain},
  UModuloDeRastreio_PowerUtils in 'UModuloDeRastreio_PowerUtils.pas',
  UUtilitarios_PowerUtils in 'UUtilitarios_PowerUtils.pas',
  InterfaceRastreio_PowerUtils in 'InterfaceRastreio_PowerUtils.pas',
  UProceduresDosGatilhos_PowerUtils in 'UProceduresDosGatilhos_PowerUtils.pas',
  UModuloDeSQL_PowerUtils in 'UModuloDeSQL_PowerUtils.pas' {FormSQL},
  HelpersPadrao in 'HelpersPadrao.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
