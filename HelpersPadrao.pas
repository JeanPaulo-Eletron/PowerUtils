unit HelpersPadrao;

interface

uses Data.Win.ADODB, Winapi.OleDB, Winapi.ADOInt, System.TypInfo, System.Classes, SysUtils;

Type
  TArrayHelperThread = Record Helper for TArray<TThread>
    public
      Function Push(Value: TThread): TArray<TThread>;
      Function Drop(Value: TThread): TArray<TThread>;
      Function WaitFor: TArray<TThread>;
  End;
implementation

  Function TArrayHelperThread.Push(Value: TThread): TArray<TThread>;
  begin
    Self := Self + [Value];
    Result := Self;
  end;

  Function TArrayHelperThread.Drop(Value: TThread): TArray<TThread>;
  var ArrayThread : TArray<TThread>;
      Thread: TThread;
  begin
    Result := [];
    for Thread in ArrayThread do begin
      if Thread <> Value
        then Result.Push(Thread);
    end;
    Self := Result;
  end;

  Function TArrayHelperThread.WaitFor: TArray<TThread>;
  begin
    while Length(Self) > 0
      do Sleep(100);
  end;
end.
