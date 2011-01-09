unit UEvent;

interface

uses dos, crt, udate, utime, udatetime;

type
  tevent = class
    public
      name : string[50];
      anniversary : boolean;
      all_day : boolean;
      start : tdatetime;
      finish : tdatetime;
      function to_s : string;
      function less_than_a_day : boolean;
      constructor create;

    private
      function which_anniversary : integer;
  end;

implementation

function tevent.to_s : string; { TODO! dodać opcje zarządzające wypisywaniem, jeśli potrzeba }
var
  which_anniversary_to_s : string;

begin
  to_s := '';

  if (self.anniversary) and (self.which_anniversary > 0) then begin
    str(which_anniversary, which_anniversary_to_s);
    to_s := which_anniversary_to_s + '. ';
  end;

  to_s := to_s + self.name + ' ';
  if (self.all_day) then
    to_s := to_s + self.start.to_s(true, false)
  else begin
    if (self.less_than_a_day) then
      to_s := self.start.to_s(false, true) + ' - ' + self.finish.to_s
    else begin
      to_s := 'początek: ' + self.start.to_s;
      to_s := 'koniec: ' + self.finish.to_s;
    end;
  end;
end;

function tevent.which_anniversary : integer;
var
  date : tdate;

begin
  date := tdate.create;
  date.set_current;
  which_anniversary := date.year - self.start.date.year; 
end;

function tevent.less_than_a_day : boolean; { sprawdzenie, czy event zaczyna się i kończy tego samego dnia }
begin
  if (self.start.date.year = self.finish.date.year) and
     (self.start.date.month = self.finish.date.month) and
     (self.start.date.day = self.finish.date.day) then
    less_than_a_day := true
  else less_than_a_day := false;
end;

constructor tevent.create;
begin
  self.start := tdatetime.create;
  self.finish := tdatetime.create;
  self.anniversary := false; { just in case. }
  self.all_day := false;
  self.name := 'nazwa';
end;

end.
