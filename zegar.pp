program zegar;

uses dos, crt, math;

type
  date = object { obiekt do obsługi daty }
    year, month, day, wday : word; { wday - day of week (0 - niedziela) }
    function name_of_month:string;
    function name_of_day:string;
    procedure set_current;
  end;

  time = object { obiekt do obsługi czasu }
    hours, minutes, seconds, cs : word; { cs - setne sekundy }
    function to_period:longint; { zwraca, ile upłynęło setnych sekund od początku dnia }
    procedure to_time(period:longint); { ustawia wszystkie zmienne obiektu tak, by reprezentowały daną godzinę z liczby setnych sekundy }
    procedure set_current;
  end;

  position = record { rekord do obsługi położenia, używany do ustawienia kursora przed wypisywaniem na ekran w gotoxy(x,y) }
    x : word;
    y : word;
  end;

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
  data : date; { rekord daty }
  czas : time; { rekord czasu }
  year, month, day, wday : word; { składniki daty, wday - dzien tygodnia: 0 - niedziela }
  hours, minutes, seconds, cseconds : word; { składniki czasu, cseconds - setne sekundy }
  period : longint; { liczba reprezentująca czas jako ilość setnych sekundy, które upłynęły od początku dnia }
  stopwatch_position : position; { określenie pozycji stopera }

{ BLOCK4: SUPPORT - blok odpowiedzialny za pomoc modelowi w obsłudze czasu, daty, plików }

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

{ METHOD: parse_date_to_readable_form - metoda zwracająca datę w postaci np. "1 stycznia 1970r." }
function parse_date_to_readable_form(date : date):string;
var
  str_day, str_year : string;

begin
  str(date.day, str_day);
  str(date.year, str_year);

  parse_date_to_readable_form := str_day + ' ' + date.name_of_month + ' ' + str_year + 'r.';
end;

{ METHOD: parse_time_to_readable_form - metoda zwracająca czas w postaci np. "00:01:10" lub "00:01:10.99" w zależności od parametru precision:
  false - ograniczenie do sekund; true - dokładny czas (wraz z centysekundami) }
function parse_time_to_readable_form(time : time; precision : boolean):string;
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

  parse_time_to_readable_form := readable;
end;

procedure print_exact_time(time : time);
forward;

procedure print_start_stop_and_difference_time(start : time; stop : time; duration : time);
forward;

procedure print_stopwatch(duration : time);
forward;

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
  writeln('Dziś jest ', parse_date_to_readable_form(data));
  textcolor(normal_color);
end;

{ METHOD: print_current_date_and_wday - metoda wyświetlająca aktualną datę wraz z dniem tygodnia w normalnej postaci }
procedure print_current_date_and_wday;
var
  data : date;

begin
  textcolor(info_color);
  data.set_current;
  writeln('Dziś jest ', data.name_of_day, ' ', parse_date_to_readable_form(data));
  textcolor(normal_color);
end;

{ METHOD: print_current_time - metoda wyświetlająca aktualny czas }
procedure print_current_time;
var
  czas : time;

begin
  textcolor(info_color);
  czas.set_current;
  writeln('Godzina: ', parse_time_to_readable_form(czas, false));
  textcolor(normal_color);
end;

{ METHOD: HELPER: print_exact_time - metoda wyświetlająca podany czas jako czas dokładny (z centysekundami) }
procedure print_exact_time(time : time);
begin
  textcolor(info_color);
  writeln(parse_time_to_readable_form(time, true));
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

{ BLOCK 3: MODEL - ustawienia pozycji elementów, ścieżki do pliku z danymi itd. }

{ METHOD: init_positions_of_elements - ustawienie pozycji wszystkich elementów używanych w programie, aby można było wykorzystać gotoxy(x,y) }
procedure init_positions_of_elements;
begin
  { stoper }
  stopwatch_position.x := 3;
  stopwatch_position.y := 2;
end;

procedure get_events_on_today;
begin

end;

begin
  init_positions_of_elements;
  greeting;
  print_current_date_and_wday;
  print_current_time;
  czas.set_current;
  print_exact_time(czas);
  stopwatch;
end.
