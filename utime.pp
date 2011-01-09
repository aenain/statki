unit UTime;

interface

uses dos, crt;

type
  ttime = class
    public
      hours, minutes, seconds, cs : word;
      function to_s(with_seconds : boolean = false; with_cs : boolean = false; with_prepend_text : boolean = false) : string;
      procedure to_time(period : longint); overload;
      procedure to_time(sequence : string); overload;
      function to_period : longint; { TODO! napisać metodę zamieniająca time na longint (ilość centysekund, które upłynęły od początku dnia }
      procedure set_current;
      constructor create;

    private
      function add_0_if_less_than_10(const variable : word) : string;
  end;

implementation

function ttime.to_s(with_seconds : boolean = false; with_cs : boolean = false; with_prepend_text : boolean = false) : string;
begin
  to_s := '';

  if (with_prepend_text) then to_s := 'Godzina: ';
  to_s := to_s + self.add_0_if_less_than_10(self.hours) + ':' + self.add_0_if_less_than_10(self.minutes);
  if (with_seconds) then to_s := to_s + ':' + add_0_if_less_than_10(self.seconds);
  if (with_cs) then to_s := to_s + '.' + add_0_if_less_than_10(self.cs);
end;

procedure ttime.to_time(period : longint);
begin
  self.cs := period mod 100;
  period := period div 100;

  self.seconds := period mod 60;
  period := period div 60;

  self.minutes := period mod 60;
  period := period div 60;

  self.hours := period;
end;

procedure ttime.to_time(sequence : string);
begin
  val(sequence[1..2], self.hours);
  val(sequence[4..5], self.minutes);
  if (length(sequence) >= 8) then begin
    val(sequence[7..8], self.seconds);
    if (length(sequence) >= 11) then
      val(sequence[10..11], self.cs);

  end;
end;

function ttime.to_period : longint;
begin
  to_period := ((self.hours * 60 + self.minutes) * 60 + self.seconds) * 100 + self.cs;
end;

procedure ttime.set_current;
begin
  gettime(self.hours, self.minutes, self.seconds, self.cs);
end;

function ttime.add_0_if_less_than_10(const variable : word) : string;
var
  str_variable : string;

begin
  str(variable, str_variable);
  if (variable < 10) then str_variable := '0' + str_variable;
  add_0_if_less_than_10 := str_variable;
end;

constructor ttime.create; { init values }
begin
  self.hours := 0;
  self.minutes := 0;
  self.seconds := 0;
  self.cs := 0;
end;

end.
