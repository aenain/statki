program zegar;

uses dos, crt;

type
  date = record { rekord do obsługi daty }
    year, month, day, wday : word; { wday - day of week (0 - niedziela) }
  end;

  time = record { rekord do obsługi czasu }
    hours, minutes, seconds, cseconds : word; { cseconds - setne sekundy }
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

{ METHOD: parse_date_to_readable_form - metoda zwracająca datę w postaci np "1 stycznia 1970r." }
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

begin
  greeting;
  set_current_date;
  print_current_date_and_wday;
end.
