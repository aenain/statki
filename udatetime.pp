unit UDateTime;

interface

uses udate, utime, uposition;

type
  tdatetime = class
    public
      date : tdate;
      time : ttime;
      procedure set_current;
      function to_s(with_date : boolean = true; with_time : boolean = true; time_should_be_first : boolean = false; with_year : boolean = true; with_current_year : boolean = false) : string;
      constructor create;
  end;

function compare2datetimes(a, b : tdatetime) : integer; { spaceship operator }

implementation

procedure tdatetime.set_current;
begin
  self.date.set_current;
  self.time.set_current;
end;

function tdatetime.to_s(with_date : boolean = true; with_time : boolean = true; time_should_be_first : boolean = false; with_year : boolean = true; with_current_year : boolean = false): string; { TODO! dodać opcje zarządzające wypisywaniem, jeśli potrzeba! }
begin
  to_s := '';
  if (time_should_be_first) then begin
    if (with_time) then to_s := to_s + self.time.to_s;
    if (with_date) and (with_time) then to_s := to_s + ' ';
    if (with_date) then to_s := to_s + self.date.to_s(with_year, false, false, false, with_current_year);
  end else begin
    if (with_date) then to_s := to_s + self.date.to_s(with_year, false, false, false, with_current_year);
    if (with_date) and (with_time) then to_s := to_s + ' ';
    if (with_time) then to_s := to_s + self.time.to_s;
  end;
end;

constructor tdatetime.create;
begin
  self.date := tdate.create;
  self.time := ttime.create;
end;

function compare2datetimes(a, b : tdatetime) : integer;
var
  comparison : integer;

begin
  comparison := compare2dates(a.date, b.date);
  if (comparison <> 0) then compare2datetimes := comparison
  else compare2datetimes := compare2hours(a.time, b.time);
end;

end.
