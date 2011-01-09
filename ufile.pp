unit UFile;

interface

uses dos, crt, tripleoperator, udate, utime, udatetime, uevent, uposition, uinput;

type
  //tcalendar = file of tevent;
  tcalendar = text; { w pliku elementowym nie działała alokacja pamięci na obiekty powiązane }
  tevents = array of tevent;

  tfile = class
    public
      procedure add(new_event : tevent);
      procedure delete(name : string);
      function index : tevents;
      constructor create;
    private
      path : string;
      procedure save(events : tevents);
  end;

implementation

procedure tfile.add(new_event : tevent);
var
  events : tevents;
  size : integer;
  event : tevent;

begin
  events := self.index;
  size := length(events);
  setlength(events, size + 1);
  events[size] := new_event;
  self.save(events);
end;

procedure tfile.delete(name : string);
var
  events : tevents;
  event : tevent;
  i, size : integer;
  to_remove_count : integer; { ilość elementów wyszukanych po name, które zostaną usunięte }

begin
  events := self.index;
  size := length(events);
  to_remove_count := 0;

  for i := low(events) to high(events) do begin
    if (events[i].name = name) then begin
      dec(size);
      inc(to_remove_count);
      events[i] := events[size]; { przepisanie na pozycję usuwanego elementu elementu ostatniego }
      setlength(events, size); { usunięcie ostatniego elementu }
    end;
  end;

  writeln('Usunieto ', to_remove_count, 'elementów');
  self.save(events);
end;

function tfile.index : tevents; { metoda zwraca wszystkie eventy z pliku }
var
  calendar : tcalendar;
  events : tevents;
  size : integer;
  event : tevent;
  row : string;

begin
  assign(calendar, self.path);
  reset(calendar);
  size := 0;

  while not (eof(calendar)) do begin
    inc(size);
    setlength(events, size);

    event := tevent.create;

    readln(calendar, event.name);

    readln(calendar, row); { czy event całodniowy? }
    event.all_day := ifthen(row = 'TRUE', true, false);

    readln(calendar, row); { czy event jest rokroczny? }
    event.anniversary := ifthen(row = 'TRUE', true, false);

    readln(calendar, row); { data rozpoczęcia }
    event.start.date.to_date(row);

    readln(calendar, row); { godzina rozpoczęcia }
    event.start.time.to_time(row);

    readln(calendar, row); { data zakończenia }
    event.finish.date.to_date(row);

    readln(calendar, row); { godzina zakończenia }
    event.finish.time.to_time(row);

    events[size-1] := event;
  end;

  close(calendar);
  index := events;
end;

constructor tfile.create;
begin
  self.path := 'events.txt'; { ścieżka do pliku z eventami }
end;

procedure tfile.save(events : tevents);
var
  i : integer;
  calendar : tcalendar;

begin
  assign(calendar, self.path);
  rewrite(calendar);
  
  for i := low(events) to high(events) do begin
    writeln(calendar, events[i].name); { nazwa }
    writeln(calendar, events[i].all_day); { czy całodzienny? }
    writeln(calendar, events[i].anniversary); { czy rokroczny? }
    writeln(calendar, events[i].start.date.to_s); { data rozpoczęcia }
    writeln(calendar, events[i].start.time.to_s); { godzina rozpoczęcia }
    writeln(calendar, events[i].finish.date.to_s); { data zakończenia }
    writeln(calendar, events[i].finish.time.to_s); { godzina zakończenia }
  end;
  
  close(calendar);
end;

end.


