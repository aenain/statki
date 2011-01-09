unit UFile;

interface

uses dos, crt, tripleoperator, udate, utime, udatetime, uevent, uposition, uinput;

type
  tcalendar = file of tevent;
  tevents = array of tevent;

  tfile = class
    public
      procedure add(event : tevent);
      procedure delete(name : string);
      function index : tevents;
      constructor create;
    private
      path : string;
      procedure save(events : tevents);
  end;

implementation

procedure tfile.add(event : tevent);
var
  events : tevents;
  i : integer;

begin
  events := self.index;
  i := length(events);
  setlength(events, i + 1);
  events[i] := event;
  self.save(events);
end;

procedure tfile.delete(name : string);
var
  events : tevents;
  event : tevent;
  i, j : integer;
  count : integer; { ilość elementów wyszukanych po name, które zostaną usunięte }

begin
  events := self.index;
  count := 0;
  for i := low(events) to high(events) do begin
    if (events[i].name = name) then begin
      j := i;
      inc(count);
    end;
  end;

  if (count = 1) then begin { jeśli znaleziono tylko jeden element, to procedura usuwania }
    events[j] := events[i]; { w miejsce usuwanego elementu jest przypisywany ostatni element, żeby móc zmniejszyć tablicę }
    setlength(events, length(events) - 1);
    self.save(events);
  end;
end;

function tfile.index : tevents;
var
  calendar : tcalendar;
  events : tevents;
  i : integer;
  event : tevent;

begin
  assign(calendar, self.path);
  reset(calendar);

  i := 0;
  while not (eof(calendar)) do begin
    inc(i);
    setlength(events, i);
    read(calendar, events[i-1]); { TODO! z tym przypisywaniem to jakaś lipa... }
  end;

  close(calendar);
  index := events;
end;

constructor tfile.create;
begin
  self.path := 'events.dat'; { ścieżka do pliku z eventami }
end;

procedure tfile.save(events : tevents);
var
  i : integer;
  calendar : tcalendar;

begin
  assign(calendar, self.path);
  rewrite(calendar);
  
  for i := 0 to length(events) - 1 do begin
    write(calendar, events[i]);
  end;
  
  close(calendar);
end;

end.


