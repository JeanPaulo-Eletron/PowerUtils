unit UModuloDeRastreio_PowerUtils;

interface

uses UUtilitarios_PowerUtils, InterfaceRastreio_PowerUtils, System.Threading, StrUtils,
     System.SysUtils, System.Classes;

Type
  TRastreador = Class(TInterfacedObject, iObjectRastreio<TRastreador>)
    function New(var variável: TRastreador): TRastreador;
     private
    TeclasRastreadas: String;
    GatilhosAtivos: Boolean;
    public
    Gatilhos: Array of TFunc<TCallBack>;
    Active: Boolean;
  end;
implementation

{ TRastreador }

uses UFormMain_PowerUtils;

function TRastreador.New(var variável: TRastreador): TRastreador;
var
 Task: IFuture<string>;
 TaskEvent: TFunc<string>;
 ObjInterval: TTimeOut;
begin
  variável := TRastreador.Create;
  Self     := variável;
  Result   := Self;
  GatilhosAtivos := True;
  Active   := True;

  TaskEvent := function:string
               var TeclasPressionadasAnteriormente, TeclasPressionadasAgora: string;
               begin
                 Result := ''; TeclasPressionadasAgora := '' {# Seta o valor Default #};
                 TeclasPressionadasAnteriormente := ObterTeclasPressionadas(TeclasPressionadasAgora){# Fotografia das teclas apertadas anteriormente #};

                 while TeclasPressionadasAnteriormente = ObterTeclasPressionadas(TeclasPressionadasAgora) {# Fotografia das teclas apertadas agora #}
                   do begin
                     if not Active
                       then Break;
                     Task.Wait(1){#Sleep, quando houver uma mudança nas teclas apertadas então ele libera #};
                   end;

                 Result := DiffString(TeclasPressionadasAgora, TeclasPressionadasAnteriormente){#DIF#};
               end;

  TTask.Run(
  procedure
  var Gatilho : TFunc<TCallBack>;
      Callback: TCallBack;
  begin
    while true do begin
      {# Parecido com o conceito de promisse, fiz dessa maneira mas pra testar o conceito mesmo, porém no futuro seria interessante colocar várias threads em execução com isso e quando precisar setar chamar esse task.value, não ele aguarda o término #}
      Task   := TTask.Future<string>(TaskEvent);
      TeclasRastreadas := Task.Value;
      for Gatilho in Gatilhos do begin
        CallBack := Gatilho();
        if GatilhosAtivos
          then CallBack;
      end;
      if not Active
        then Break;
    end;
    ObjInterval.LoopTimer := False;
  end).Start;

  ObjInterval := SetInterval(
  Procedure
  begin
    if Assigned(Task)
      then FormMain.Panel_RastreiaInput.Caption := RightStr(TeclasRastreadas, 75);
    if not Active
      then ObjInterval.LoopTimer := False;
  end, 100)


end;

end.
