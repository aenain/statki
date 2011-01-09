unit UMenu;

interface

uses dos, crt, tripleoperator, udate, utime, udatetime, uevent, uposition, uinput, ufile;

type
  tresource = class
    database : tfile;
    procedure add;
    procedure index;
    constructor create;
    {procedure delete;}
  end;

  tmenu = class
    event : tresource;
    constructor create;
  end;
{
  tcalendar = file of tevent;
  tevents = array of tevent;
}
implementation

procedure tresource.add;
var
  a : char;
  event : tevent;
  str_data : string;
  calendar : tcalendar;
  events : tevents;
  i : integer;

begin { TODO! refactor this stuff, especially operations like read and write from/to file! }
  event := tevent.create;
  writeln('Podaj nazwę');
  readln(str_data);
  event.name := str_data;
  writeln('Czy całodzienny? 1. tak, 2. nie');
  a := readkey;
  event.all_day := ifthen(a = '1', true, false);
  writeln('Czy rokroczny? 1. tak, 2. nie');
  a := readkey;
  event.anniversary := ifthen(a = '1', true, false);
  if (event.all_day) then begin
    if (event.anniversary) then writeln('Podaj datę pierwotnego wydarzenia [dd.mm.yyyy]')
    else writeln('Podaj datę [dd.mm.yyyy]');

    readln(str_data);
    event.start.date.to_date(str_data);
    event.finish.date.to_date(str_data);
    event.start.time.to_time(0);
    event.finish.time.to_time(8639999);
  end else begin
    writeln('Podaj datę rozpoczęcią [dd.mm.yyyy]');
    readln(str_data);
    event.start.date.to_date(str_data);
    writeln('Podaj godzinę rozpoczęcia [hh:mm]');
    readln(str_data);
    event.start.time.to_time(str_data);
    writeln('Podaj datę zakończenia [dd.mm.yyyy]');
    readln(str_data);
    event.finish.date.to_date(str_data);
    writeln('Podaj godzinę zakończenia [hh:mm]');
    readln(str_data);
    event.finish.time.to_time(str_data);
  end;

  self.database.add(event);
end;

procedure tresource.index;
var
  events : tevents;
  i : integer;

begin
  events := self.database.index;

  for i := low(events) to high(events) do
    writeln(events[i].to_s);

end;

constructor tresource.create;
begin
  self.database := tfile.create;
end;

constructor tmenu.create;
begin
  self.event := tresource.create;
end;

end.
