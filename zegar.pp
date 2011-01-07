program zegar;

uses dos, crt, tripleoperator in 'tripleoperator.pp';

type
  date = object { obiekt do obsługi daty }
    year, month, day, wday : word; { wday - day of week (0 - niedziela) }
    function name_of_month:string; { funkcja zwracająca odmienioną nazwę miesiąca, np. "stycznia" }
    function name_of_day:string; { funkcja zwracająca nazwę dnia tygodnia }
    procedure set_current; { pobranie aktualnej daty }
    function to_s:string; { funkcja zwraca datę w postaci łańcucha, np. 23.12.2010 }
  end;

  time = object { obiekt do obsługi czasu }
    hours, minutes, seconds, cs : word; { cs - setne sekundy }
    function to_period:longint; { zwraca, ile upłynęło setnych sekund od początku dnia }
    procedure to_time(period:longint); { ustawia wszystkie zmienne obiektu tak, by reprezentowały daną godzinę z liczby setnych sekundy }
    procedure set_current; { pobranie aktualnego czasu }
    function to_s:string; { funkcja zwraca czas w postaci łańcucha, np: 23:59 }
  end;
  
  datetime = record { rekord do obsługi czasu i daty }
    date : date;
    time : time;
  end;

  position = record { rekord do obsługi położenia, używany do ustawienia kursora przed wypisywaniem na ekran w gotoxy(x,y) }
    x : word;
    y : word;
  end;

  event = record { rekord do obsługi uroczystości }
    name : string; { nazwa eventu, np. "Urodziny cioci Katarzyny" }
    start : datetime; { początek eventu, gdy event całodzienny, to start.time będzie postaci "00:00:00.00" }
    finish : datetime; { koniec eventu, gdy event całodzienny, to finish.time będzie postaci "23:59:59.99" }
    anniversary : boolean; { sprawdzenie, czy event jest rokroczny }
  end;

  events = array of event;

const
{ określenie kolorów używanych do wyświetlania tekstu na ekranie }
  normal_color = 15; { 15 - biały }
  menu_color = 2; { 2 - zielony }
  input_color = 14; { 14 - żółty }
  action_color = 7; { 7 - jasnoszary }
  greeting_color = 14; { 14 - żółty }
  error_color = 4; { 4 - czerwony }
  info_color = 15; { 15 - biały }
  description_color = 7; { 7 - jasnoszary }

var
  data : date;
  czas : time;
  wydarzenie : event;
  wydarzenia : events;
  events_count : integer;
  year, month, day, wday : word; { składniki daty, wday - dzien tygodnia: 0 - niedziela }
  hours, minutes, seconds, cs : word; { składniki czasu, cseconds - setne sekundy }
  period : longint; { liczba reprezentująca czas jako ilość setnych sekundy, które upłynęły od początku dnia }
  stopwatch_position : position; { określenie pozycji stopera }

procedure print_exact_time(time : time);
forward;

procedure print_start_stop_and_difference_time(start, stop, duration : time);
forward;

procedure print_stopwatch(duration : time);
forward;

function day_of_week(date : date):word;
forward;

{ BLOCK3: MODEL PART }

{ METHOD: to_period - wywołana na obiekcie time zwraca ilość setnych sekundy od początku dnia }
function time.to_period:longint;
begin
  to_period := ((self.hours * 60 + self.minutes) * 60 + self.seconds) * 100 + self.cs;
end;

{ METHOD: to_time - wywołana na obiekcie time ustawia wszystkie zmienne (hours, minutes, seconds, cs) tak, by time reprezentował
  czas równy +period+ setnych sekundy od początku dnia }
procedure time.to_time(period : longint);
begin
  self.cs := period mod 100;
  period := period div 100;

  self.seconds := period mod 60;
  period := period div 60;

  self.minutes := period mod 60;
  period := period div 60;

  self.hours := period;
end;

{ METHOD: set_current_time - metoda ustawia aktualny czas jako wartość zmiennej current_time }
procedure time.set_current;
begin
  gettime(self.hours, self.minutes, self.seconds, self.cs);
end;

{ METHOD: to_s - metoda zwraca czas w postaci łańcucha, np. "23:59" }
function time.to_s:string;
var
  str_hours, str_minutes : string;

begin
  str(self.hours, str_hours);
  str(self.minutes, str_minutes);

  if (self.hours < 10) then str_hours := '0' + str_hours;
  if (self.minutes < 10) then str_minutes := '0' + str_minutes;

  to_s := str_hours + ':' + str_minutes;
end;

{ METHOD: name_of_month - wywołana na obiekcie date zwraca odmienioną nazwę miesiąca (np. "stycznia"), która się nadaje do wstawienia między dzień a rok }
function date.name_of_month:string;
var
  { nazwy miesięcy, które trafią między dzień a rok - czyli odmienione }
  names_of_months : array[1..12] of string = ('stycznia', 'lutego', 'marca', 'kwietnia',
                                               'maja', 'czerwca', 'lipca', 'sierpnia',
                                               'września', 'października', 'listopada', 'grudnia');

begin
  name_of_month := names_of_months[self.month];
end;

{ METHOD: name_of_day - wywołana na obiekcie date zwraca nazwę dnia tygodnia }
function date.name_of_day:string;
var
  { nazwy dni tygodnia }
  names_of_days : array[0..6] of string = ('niedziela', 'poniedziałek', 'wtorek', 'środa', 'czwartek', 'piątek', 'sobota');

begin
  name_of_day := names_of_days[self.wday];
end;

{ METHOD: set_current_date - metoda ustawia aktualną datę jako wartość zmiennej current_date }
procedure date.set_current;
begin
  getdate(self.year, self.month, self.day, self.wday);
end;

{ METHOD: to_s - metoda zwraca datę w postaci łańcucha, np. "23.12.2010" }
function date.to_s:string;
var
  str_year, str_month, str_day : string;

begin
  str(self.year, str_year);
  str(self.month, str_month);
  str(self.day, str_day);

  if (self.month < 10) then str_month := '0' + str_month;
  if (self.day < 10) then str_day := '0' + str_day;

  to_s := str_day + '.' + str_month + '.' + str_year;
end;

{ BLOCK2: CONTROLLER - blok odpowiedzialny za obliczenia }

{ METHOD: add_zero_if_smaller_than_ten - metoda zwracająca string podany jako argument z dodanym zerem, jeśli wartość stringa była mniejsza niż 10 }
function add_zero_if_smaller_than_ten(str : string):string;
var
  wartosc : word;

begin
  val(str, wartosc);
  if (wartosc < 10) then str := '0' + str;
  add_zero_if_smaller_than_ten := str;
end;

{ METHOD: date_to_readable_form - metoda zwracająca datę w postaci np. "1 stycznia 1970r." }
function date_to_readable_form(date : date):string;
var
  str_day, str_year : string;

begin
  str(date.day, str_day);
  str(date.year, str_year);

  date_to_readable_form := str_day + ' ' + date.name_of_month + ' ' + str_year + 'r.';
end;

{ METHOD: time_to_readable_form - metoda zwracająca czas w postaci np. "00:01:10" lub "00:01:10.99" w zależności od parametru precision:
  false - ograniczenie do sekund; true - dokładny czas (wraz z centysekundami) }
function time_to_readable_form(time : time; precision : boolean):string;
var
  readable, str_hours, str_minutes, str_seconds, str_cs : string;

begin
  str(time.hours, str_hours);
  str(time.minutes, str_minutes);
  str(time.seconds, str_seconds);
  str(time.cs, str_cs);

  readable := add_zero_if_smaller_than_ten(str_hours) + ':';
  readable += add_zero_if_smaller_than_ten(str_minutes) + ':';
  readable += add_zero_if_smaller_than_ten(str_seconds);
  if (precision) then readable += '.' + add_zero_if_smaller_than_ten(str_cs);

  time_to_readable_form := readable;
end;

{ METHOD: string_to_date - metoda zwraca obiekt date na podstawie stringa postaci [dd.mm.yyyy] }
function string_to_date(str : string):date;
begin
  val(str[1..2], day);
  val(str[4..5], month);
  val(str[7..10], year);

  data.year := year;
  data.month := month;
  data.day := day;

  wday := day_of_week(data);
  string_to_date := data;
end;

{ METHOD: string_to_time - metoda zwraca obiekt time na podstawie stringa postaci [hh:mm:ss] }
function string_to_time(str : string):time;
begin
  val(str[1..2], hours);
  val(str[3..4], minutes);

  czas.hours := hours;
  czas.minutes := minutes;
  czas.seconds := 0;
  czas.cs := 0;

  string_to_time := czas;
end;

{ METHOD: stopwatch - metoda obsługująca stoper, czyli liczenie czasu między dwoma punktami }
procedure stopwatch;
var
  start, stop, duration : time;

begin
  clrscr;

  start.set_current;

  repeat
    stop.set_current;
    duration.to_time(stop.to_period - start.to_period);
    print_stopwatch(duration);
    delay(1);
  until keypressed;

  print_start_stop_and_difference_time(start, stop, duration);
end;

{ BLOCK1: VIEW - blok odpowiedzialny za wyświetlanie wyników działania programu }

{ METHOD: greeting - metoda wyświetlająca informację powitalną podczas startu programu }
procedure greeting;
begin
  textcolor(greeting_color);
  writeln('Witaj w iCalendarze :)');
  writeln('Copyright: 2011 Artur Hebda');
  writeln;
  textcolor(normal_color);
end;

{ METHOD: print_current_date - metoda wyświetlająca aktualną datę w normalnej postaci,
  UWAGA! data musi zostać wcześniej ustawiona! }
procedure print_current_date;
var
  data : date;

begin
  textcolor(info_color);
  data.set_current;
  writeln('Dziś jest ', date_to_readable_form(data));
  textcolor(normal_color);
end;

{ METHOD: print_current_date_and_wday - metoda wyświetlająca aktualną datę wraz z dniem tygodnia w normalnej postaci }
procedure print_current_date_and_wday;
var
  data : date;

begin
  textcolor(info_color);
  data.set_current;
  writeln('Dziś jest ', data.name_of_day, ', ', date_to_readable_form(data));
  textcolor(normal_color);
end;

{ METHOD: print_current_time - metoda wyświetlająca aktualny czas }
procedure print_current_time;
var
  czas : time;

begin
  textcolor(info_color);
  czas.set_current;
  writeln('Godzina: ', time_to_readable_form(czas, false));
  textcolor(normal_color);
end;

{ METHOD: HELPER: print_exact_time - metoda wyświetlająca podany czas jako czas dokładny (z centysekundami) }
procedure print_exact_time(time : time);
begin
  textcolor(info_color);
  writeln(time_to_readable_form(time, true));
  textcolor(normal_color);
end;

{ METHOD: print_start_stop_and_difference_time - metoda wyświetlająca wyniki działania stopera }
procedure print_start_stop_and_difference_time(start : time; stop : time; duration : time);
begin
  textcolor(description_color);
  write('Start o godzinie: ');
  print_exact_time(start);
  textcolor(description_color);
  write('Stop o godzinie:  ');
  print_exact_time(stop);
  textcolor(description_color);
  write('Upłynęło:         ');
  print_exact_time(duration);
  textcolor(normal_color);
end;

{ METHOD: print_stopwatch - metoda wyświetlająca stoper w określonym miejscu }
procedure print_stopwatch(duration : time);
begin
  gotoxy(stopwatch_position.x, stopwatch_position.y);
  print_exact_time(duration);
end;

{ METHOD: print_event - metoda wypisująca wydarzenie }
procedure print_event(event : event);
begin
  writeln(event.name);
end;

{ BLOCK 3: MODEL - ustawienia pozycji elementów, ścieżki do pliku z danymi itd. }

{ METHOD: init_positions_of_elements - ustawienie pozycji wszystkich elementów używanych w programie, aby można było wykorzystać gotoxy(x,y) }
procedure init_positions_of_elements;
begin
  { stoper }
  stopwatch_position.x := 3;
  stopwatch_position.y := 2;
end;

{ METHOD: day_of_week - metoda zwracająca numer dnia tygodnia: 0 dla niedzieli, 6 dla soboty na podstawie algorytmu Zellera }
function day_of_week(date : date):word;
var
  y, m, d, h, z, j, k, x : word;

begin
  if (date.month < 3) then begin
    m := date.month + 10;
    y := date.year - 1;
  end else begin
    m := date.month - 2;
    y := date.year;
  end;

  d := date.day;
  j := y mod 100; { which year of century }
  k := y div 100; { which century }
  z := (m * 13 - 1) div 5; 
  x := j div 4;
  y := k div 4;
  h := z + x + y + d + j + 5 * k;

  day_of_week := h mod 7;
end;

{ METHOD: add_event - umożliwia dodanie wydarzenia }
procedure add_event;
var
  name, str_start_date, str_finish_date, str_start_time, str_finish_time : string;
  str_anniversary : char;
  start : datetime;
  finish : datetime;
  anniversary : boolean;

begin
  write('Podaj nazwę wydarzenia: ');
  readln(name);
  write('Podaj datę rozpoczęcia wydarzenia [dd.mm.yyyy]: ');
  readln(str_start_date);
  start.date := string_to_date(str_start_date);
  write('Podaj godzinę rozpoczęcia wydarzenia [hh:mm]: ');
  readln(str_start_time);
  start.time := string_to_time(str_start_time);
  write('Podaj datę zakończenia wydarzenia [dd.mm.yyyy]: ');
  readln(str_finish_date);
  finish.date := string_to_date(str_finish_date);
  write('Podaj godzinę zakończenia wydarzenia [hh:mm]: ');
  readln(str_finish_time);
  finish.time := string_to_time(str_finish_time);
  writeln('Czy to jest rokroczne wydarzenie? 1. Tak, 2. Nie');
  str_anniversary := readkey;
  anniversary := ifthen(str_anniversary = '1', true, false);

  wydarzenie.name := name;
  wydarzenie.start := start;
  wydarzenie.finish := finish;
  wydarzenie.anniversary := anniversary;

  inc(events_count);
  setlength(wydarzenia, events_count);
  wydarzenia[events_count] := wydarzenie; { TODO: dodać zapisywanie do pliku }
end;

{ METHOD: get_events_on_today - z tablicy wydarzeń wybiera te, które dzieją się dzisiaj i je wyświetla. TODO: rozdzielić metodą pobierającą i wyświetlającą }
procedure get_events_on_today;
var
  i : integer;

begin
  data.set_current;
  czas.set_current;
  for i := 0 to events_count do begin
    print_event(wydarzenia[i]); { TODO: dodać warunek, kiedy event jest "dzisiejszym" eventem, dodać pobieranie z pliku <- tylko przy starcie programu }
  end;
end;

begin
  init_positions_of_elements;
  greeting;
  print_current_date_and_wday;
  print_current_time;
  events_count := 0;
  add_event;
  get_events_on_today;
end.
