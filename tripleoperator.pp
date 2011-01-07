unit TripleOperator;

interface

function IfThen(Condition: Boolean; TrueValue, FalseValue: Byte): Byte; overload;
function IfThen(Condition: Boolean; TrueValue, FalseValue: Word): Word; overload;
function IfThen(Condition: Boolean; TrueValue, FalseValue: Integer): Integer; overload;
function IfThen(Condition: Boolean; TrueValue, FalseValue: Single): Single; overload;
function IfThen(Condition: Boolean; TrueValue, FalseValue: Double): Double; overload;
function IfThen(Condition: Boolean; TrueValue, FalseValue: Boolean): Boolean; overload;
function IfThen(Condition: Boolean; const TrueValue: String; const FalseValue: String): String; overload;

implementation

function IfThen(Condition: Boolean; TrueValue, FalseValue: Byte): Byte;
begin
  if Condition then IfThen := TrueValue else IfThen := FalseValue;
end;

function IfThen(Condition: Boolean; TrueValue, FalseValue: Word): Word;
begin
  if Condition then IfThen := TrueValue else IfThen := FalseValue;
end;

function IfThen(Condition: Boolean; TrueValue, FalseValue: Integer): Integer;
begin
  if Condition then IfThen := TrueValue else IfThen := FalseValue;
end;

function IfThen(Condition: Boolean; TrueValue, FalseValue: Single): Single;
begin
  if Condition then IfThen := TrueValue else IfThen := FalseValue;
end;

function IfThen(Condition: Boolean; TrueValue, FalseValue: Double): Double;
begin
  if Condition then IfThen := TrueValue else IfThen := FalseValue;
end;

function IfThen(Condition: Boolean; TrueValue, FalseValue: Boolean): Boolean;
begin
  if Condition then IfThen := TrueValue else IfThen := FalseValue;
end;

function IfThen(Condition: Boolean; const TrueValue: String; const FalseValue: String): String;
begin
  if Condition then IfThen := TrueValue else IfThen := FalseValue;
end;

end.

