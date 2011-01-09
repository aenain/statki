unit UDateTime;

interface

uses udate, utime, uposition;

type
  tdatetime = class
    public
      date : tdate;
      time : ttime;
      procedure set_current;
      function to_s(with_date : boolean = true; with_time : boolean = true) : string;
      constructor create;
  end;

implementation

procedure tdatetime.set_current;
begin
  self.date.set_current;
  self.time.set_current;
end;

function tdatetime.to_s(with_date : boolean = true; with_time : boolean = true): string; { TODO! dodać opcje zarządzające wypisywaniem, jeśli potrzeba! }
begin
  if (with_date) then to_s := self.date.to_s;
  if (with_date) and (with_time) then to_s := to_s + ' ';
  if (with_time) then to_s := to_s + self.time.to_s;
end;

constructor tdatetime.create;
begin
  self.date := tdate.create;
  self.time := ttime.create;
end;

end.
