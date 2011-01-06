program zegar;

uses dos, crt, math;

type
  date = record { rekord do obsługi daty }
    year, month, day, wday : word; { wday - day of week (0 - niedziela) }
  end;

  time = record { rekord do obsługi czasu }
    hours, minutes, seconds, cseconds : word; { cseconds - setne sekundy }
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
  { nazwy miesięcy, które trafią między dzień a rok - czyli odmienione }
  names_of_months : array[1..12] of string = ('stycznia', 'lutego', 'marca', 'kwietnia',
                                               'maja', 'czerwca', 'lipca', 'sierpnia',
                                               'września', 'października', 'listopada', 'grudnia');
  { nazwy dni tygodnia }
  names_of_days : array[0..6] of string = ('niedziela', 'poniedziałek', 'wtorek', 'środa', 'czwartek', 'piątek', 'sobota');

var
  current_date : date; { rekord daty }
  current_time : time; { rekord czasu }
  year, month, day, wday : word; { składniki daty, wday - dzien tygodnia: 0 - niedziela }
  hours, minutes, seconds, cseconds : word; { składniki czasu, cseconds - setne sekundy }
  period : longint;
  stopwatch_position : position; { określenie pozycji stopera }

{ BLOCK2: CONTROLLER - blok odpowiedzialny za obliczenia }

{ METHOD: set_current_date - metoda ustawia aktualną datę jako wartość zmiennej current_date }
procedure set_current_date;
begin
  getdate(year, month, day, wday);
  current_date.year := year;
  current_date.month := month;
  current_date.day := day;
  current_date.wday := wday;
end;

{ METHOD: set_current_time - metoda ustawia aktualny czas jako wartość zmiennej current_time }
procedure set_current_time;
begin
  gettime(hours, minutes, seconds, cseconds);
  current_time.hours := hours;
  current_time.minutes := minutes;
  current_time.seconds := seconds;
  current_time.cseconds := cseconds;
end;

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
  readable : string;
  str_day, str_year : string;

begin
  str(date.day, str_day);
  str(date.year, str_year);
  readable := str_day + ' ' + names_of_months[date.month] + ' ' + str_year + 'r.';

  parse_date_to_readable_form := readable;
end;

{ METHOD: parse_time_to_readable_form - metoda zwracająca czas w postaci np. "00:01:10" lub "00:01:10.99" w zależności od parametru precision:
  false - ograniczenie do sekund; true - dokładny czas (wraz z centysekundami) }
function parse_time_to_readable_form(time : time; precision : boolean):string;
var
  readable : string;
  str_hours, str_minutes, str_seconds, str_cseconds : string;

begin
  str(time.hours, str_hours);
  str(time.minutes, str_minutes);
  str(time.seconds, str_seconds);
  str(time.cseconds, str_cseconds);
  readable := add_zero_if_smaller_than_ten(str_hours) + ':';
  readable += add_zero_if_smaller_than_ten(str_minutes) + ':';
  readable += add_zero_if_smaller_than_ten(str_seconds);
  if (precision) then readable += '.' + add_zero_if_smaller_than_ten(str_cseconds);

  parse_time_to_readable_form := readable;
end;

{ METHOD: parse_time_to_sceconds - metoda zwracająca liczbę centysekund, jakie upłynęły od początku dnia }
function parse_time_to_cseconds(time : time):longint;
var
  time_to_period : longint;

begin
  time_to_period := time.cseconds;
  time_to_period += time.seconds * 100;
  time_to_period += time.minutes * 100 * 60;
  time_to_period += time.hours * 100 * 60 * 60;

  parse_time_to_cseconds := time_to_period;
end;

{ METHOD: parse_cseconds_to_time - metoda zwracająca rekord czasu utworzony z liczby centysekund }
function parse_cseconds_to_time(period : longint):time;
var
  period_to_time : time;

begin
  period_to_time.cseconds := period mod 100;
  period := period div 100;
  period_to_time.seconds := period mod 60;
  period := period div 60;
  period_to_time.minutes := period mod 60;
  period := period div 60;
  period_to_time.hours := period;

  parse_cseconds_to_time := period_to_time;
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
  int_start, period : longint;

begin
  clrscr;

  set_current_time;
  start := current_time;
  int_start := parse_time_to_cseconds(start);

  repeat
    set_current_time;
    period := parse_time_to_cseconds(current_time) - int_start;
    duration := parse_cseconds_to_time(period);
    print_stopwatch(duration);
    delay(1);
  until keypressed;

  stop := current_time;
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
begin
  textcolor(info_color);
  writeln('Dziś jest ', parse_date_to_readable_form(current_date));
  textcolor(normal_color);
end;

{ METHOD: print_current_date_and_wday - metoda wyświetlająca aktualną datę wraz z dniem tygodnia w normalnej postaci,
  UWAGA! data musi zostać wcześniej ustawiona! }
procedure print_current_date_and_wday;
begin
  textcolor(info_color);
  writeln('Dziś jest ', names_of_days[current_date.wday], ' ', parse_date_to_readable_form(current_date));
  textcolor(normal_color);
end;

{ METHOD: print_current_time - metoda wyświetlająca aktualny czas,
  UWAGA! czas musi zostać wcześniej ustawiony! }
procedure print_current_time;
begin
  textcolor(info_color);
  writeln('Godzina: ', parse_time_to_readable_form(current_time, false));
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

begin
  init_positions_of_elements;
  greeting;
  set_current_date;
  print_current_date_and_wday;
  set_current_time;
  print_current_time;
  print_exact_time(current_time);
  stopwatch;
end.
