unit UModuloDeRastreio_PowerUtils;

interface

uses UUtilitarios_PowerUtils, InterfaceRastreio_PowerUtils, System.Threading, StrUtils,
     System.SysUtils, System.Classes;

Type
  TRastreador = Class(TInterfacedObject, iObjectRastreio<TRastreador>)
    function New(var vari�vel: TRastreador): TRastreador;
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

function TRastreador.New(var vari�vel: TRastreador): TRastreador;
var
 Task: IFuture<string>;
 TaskEvent: TFunc<string>;
 ObjInterval: TTimeOut;
begin
  vari�vel := TRastreador.Create;
  Self     := vari�vel;
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
                     Task.Wait(1){#Sleep, quando houver uma mudan�a nas teclas apertadas ent�o ele libera #};
                   end;

                 Result := DiffString(TeclasPressionadasAgora, TeclasPressionadasAnteriormente){#DIF#};
               end;

  TTask.Run(
  procedure
  var Gatilho : TFunc<TCallBack>;
      Callback: TCallBack;
  begin
    while true do begin
      {# Parecido com o conceito de promisse, fiz dessa maneira mas pra testar o conceito mesmo, por�m no futuro seria interessante colocar v�rias threads em execu��o com isso e quando precisar setar chamar esse task.value, n�o ele aguarda o t�rmino #}
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
