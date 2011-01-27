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
      function index(conditions : boolean = false; how_many_days_in_advance : word = 2) : tevents;
      constructor create;
    private
      path : string;
      procedure save(events : tevents); overload;
      procedure save(event : tevent); overload;
  end;
  
procedure insertion_sort(var events : tevents); { sortuje po dacie rozpoczecia wydarzenia rosnąco }

implementation

procedure tfile.add(new_event : tevent);
begin
  self.save(new_event);
end;

procedure tfile.delete(name : string);
var
  events : tevents;
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

  { writeln('Usunieto ', to_remove_count, 'elementów'); }
  self.save(events);
end;

function tfile.index(conditions : boolean = false; how_many_days_in_advance : word = 2) : tevents; { metoda zwraca wszystkie eventy z pliku albo te, które są nadchodzące }
var
  calendar : tcalendar;
  events : tevents;
  size : integer;
  event : tevent;
  row : string;
  current : tdatetime;
  start_of_event : tdatetime; { do obsługi rocznicowych eventów }
  finish_of_event : tdatetime; 

begin
  assign(calendar, self.path);
  reset(calendar);
  size := 0;

  while not (eof(calendar)) do begin
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

    if not (conditions) then begin
      inc(size);
      setlength(events, size);
      events[size-1] := event;

    end else begin
      current := tdatetime.create;
      current.set_current;

      start_of_event := tdatetime.create(event.start);
      finish_of_event := tdatetime.create(event.finish);

      if (event.anniversary) then begin
        start_of_event.date.year := current.date.year;
        finish_of_event.date.year := current.date.year;
      end;

      if ((start_of_event.date.distance_from_now_in_days <= how_many_days_in_advance) and (compare2datetimes(finish_of_event, current) > -1)) then begin
        inc(size);
        setlength(events, size);
        events[size-1] := event;
      end;
    end;
  end;

  close(calendar);
  insertion_sort(events);
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

procedure tfile.save(event : tevent); { w przypadku dodawania nie ma sensu przepisywać całego pliku }
var
  calendar : tcalendar;

begin
  assign(calendar, self.path);
  append(calendar);
  
  writeln(calendar, event.name);
  writeln(calendar, event.all_day);
  writeln(calendar, event.anniversary);
  writeln(calendar, event.start.date.to_s);
  writeln(calendar, event.start.time.to_s);
  writeln(calendar, event.finish.date.to_s);
  writeln(calendar, event.finish.time.to_s);
  
  close(calendar);
end;

procedure insertion_sort(var events : tevents);
var
  i, j : integer;
  key : tevent;

begin
  for i := low(events) + 1 to high(events) do begin
    key := events[i];
    j := i - 1;

    while (j >= 0) and (compare2datetimes(events[j].start, key.start) = 1) do begin
      events[j+1] := events[j];
      dec(j);
    end;

    events[j+1] := key;
  end;
end;

end.


