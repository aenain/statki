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
  input : tinput;
  calendar : tcalendar;
  events : tevents;
  i : integer;

begin { TODO! refactor this stuff, especially operations like read and write from/to file! }
  input := tinput.create(1,1);
  event := tevent.create;
  writeln('Podaj nazwę');
  readln(input.sequence);
  event.name := input.sequence;
  writeln('Czy całodzienny? 1. tak, 2. nie');
  a := readkey;
  event.all_day := ifthen(a = '1', true, false);
  writeln('Czy rokroczny? 1. tak, 2. nie');
  a := readkey;
  event.anniversary := ifthen(a = '1', true, false);
  if (event.all_day) then begin
    writeln('Podaj datę [dd.mm.yyyy]');
    readln(input.sequence);
    event.start.date := input.to_date;
    event.finish.date := input.to_date;
    event.start.time.to_time(0);
    event.finish.time.to_time(8639999);
  end else begin
    writeln('Podaj datę rozpoczęcią [dd.mm.yyyy]');
    readln(input.sequence);
    event.start.date := input.to_date;
    writeln('Podaj godzinę rozpoczęcia [hh:mm]');
    readln(input.sequence);
    event.start.time := input.to_time;
    writeln('Podaj datę zakończenia [dd.mm.yyyy]');
    readln(input.sequence);
    event.finish.date := input.to_date;
    writeln('Podaj godzinę zakończenia [hh:mm]');
    readln(input.sequence);
    event.finish.time := input.to_time;
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

end.
