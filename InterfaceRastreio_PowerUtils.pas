unit InterfaceRastreio_PowerUtils;

interface
uses System.TypInfo;
type
  iObjectRastreio <T> = interface
    ['{5E4479C6-2B55-4D45-9722-4CA0D0E20AEA}']
    function New(var value: T) : T;
  end;

implementation

end.
