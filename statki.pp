program statki;

uses dos, crt;

type
  shot = record { nowy typ do strzelania, y przyjmuje wartosci od A do N-tej litery, x od 1 do N }
    y : char;
    x : integer; 
  end;

  area = array['A'..'J'] of array[1..10] of char; { akwen morski :) }
  areas = array[1..2] of area;
  area_of_weights = array['A'..'J'] of array[1..10] of integer; { wagi na akwenie morskim }
  direction = (pionowo, poziomo); { wybór kierunku, w którym chcemy umieścić statek. Lewy górny róg statku będzie określany }

const
  N = 10; { rozmiar planszy, poki co na sztywno 10 }
  M = 'J'; { największa możliwa wartość współrzędnej na osi pionowej }
  normal_color = 15; { 15 - biały }
  menu_color = 2; { 2 - zielony }
  input_color = 14; { 14 - żółty }
  action_color = 7; { 7 - jasnoszary }
  greeting_color = 14; { 14 - żółty }
  error_color = 4; { 4 - czerwony }
  area_color = 15; { 15 - biały }
  width_between_areas = 10; { ilość spacji między dwoma tabelami }
  ships : array[1..5] of integer = (5,4,3,3,2); { możliwe statki do wyboru }
  win_if = 17; { wygrana, gdy trafi wszystkie statki, inaczej: suma długości statków, poki co na sztywno 17 }
  default_mark = ' '; { znacznik pustego pola na planszy }
  ship_mark = '#'; { znacznik statku na planszy }
  hit_mark = 'X'; { znacznik trafienia na planszy }
  miss_mark = 'O'; { znacznik pudła na planszy }
  weights : array[1..5] of integer = (0,1,2,3,4); { wagi pól, czyli gdzie najlepiej strzelać, 0 - na pewno nie ma statków, im więcej, tym lepiej! }
  initial_max_weight = 2; { maksymalna wartość wagi w tablicy initial_weights }
  initial_weights : area_of_weights = ((1,1,1,1,1,1,1,1,1,1),
                                       (1,2,1,1,2,1,1,1,2,1),
                                       (1,1,2,1,1,1,2,1,1,1),
                                       (1,1,1,1,1,2,1,1,1,1),
                                       (1,1,2,1,2,1,1,2,1,1),
                                       (1,2,1,2,1,2,1,1,1,1),
                                       (1,1,1,1,2,1,2,2,1,1),
                                       (1,1,1,2,1,1,1,1,1,1),
                                       (1,2,1,1,1,2,1,1,2,1),
                                       (1,1,1,1,1,1,1,1,1,1)); { początkowe wagi pól akwenu, czyli gdzie najczęściej są statki }

var
  state : integer; { stan programu: 0 - brak rozgrywki, 1 - gracz vs cpu, 2 - cpu vs cpu }
  target : shot; { miejsce, w ktore chcemy strzelic }
  choice : char; { ostatnio nacisnieŧy klawisz do obslugi menu }
  { tablice z przedrostkiem player1 odnosza sie do pierwszego zawodnika, czy to cpu1 czy playera.
    ships_on_area - plansza widziana przez danego gracza z jego własnymi statkami i strzałami przeciwnika.
    shots_on_area - plansza widziana przez danego gracza z jego własnymi strzałami }
  player1_ships_on_area, player2_ships_on_area, player1_shots_on_area, player2_shots_on_area : area;
  player1_weights, player2_weights : area_of_weights; { akweny z podanymi wagami poszczególnych pól, one będą się zmieniać wraz z postępem rozgrywki }
  player1_max_weight, player2_max_weight : integer; { przechowują maksymalną wartość wagi na akwenie }
  player1_hits, player2_hits : integer; { ilości trafień w statki przeciwników }

{ BLOCK1: PART! funkcje wypisujące różne rzeczy ;) }

{ METHOD: setting_ship_actions - wyswietlanie komunikatow odnosnie ustawiania statkow w zaleznosci od etapu:
                                 wybor wspolrzednych - 1, wybor kierunku - 2
                                 i długości statku (drugi parametr) }
procedure setting_ship_actions(param : integer; length : integer);
begin
  textcolor(action_color);
  if (param = 1) then begin
    writeln('Podaj współrzędne lewego górnego rogu statku o długości ', length);
  end else begin
    writeln('Wybierz kierunek: 1.poziomo; 2.pionowo');
  end;
  textcolor(input_color);
end;

{ METHOD:HELPER: print_head_of_area - wypisuje nagłówek tabeli podaną ilość razy } 
procedure print_head_of_area(how_many_times : integer);
var i, x : integer;

begin
  textcolor(area_color);
  for i := 1 to how_many_times do begin
    write('  |');
    for x := 1 to N do begin
      write(x:2, '|');
    end;
    if (i < how_many_times) then write(' ':width_between_areas);
  end;
  writeln;
  textcolor(normal_color);
end;

{ METHOD:HELPER: print_horizontal_border - wypisuje poziome kreski dla żądanej ilości tabel }
procedure print_horizontal_border(how_many_times : integer);
var i : integer;

begin
  textcolor(area_color);
  for i := 1 to how_many_times do begin
    write('  -------------------------------');
    if (i < how_many_times) then write(' ':width_between_areas);
  end;
  writeln;
  textcolor(normal_color);
end;

{ METHOD:HELPER: print_only_areas - wypisuje całe tablice bez nagłówków }
procedure print_only_areas(how_many_areas : integer; plansze : areas);
var
  y : char;
  x, i : integer;

begin
  textcolor(area_color);
  for y:= 'A' to M do begin
    for i := 1 to how_many_areas do begin
      write(y:2, '|');
      for x := 1 to N do begin
        write(plansze[i][y][x], plansze[i][y][x], '|');
      end;
      if (i < how_many_areas) then write(' ':width_between_areas);
    end;
    writeln;
    print_horizontal_border(how_many_areas);
  end;
  textcolor(normal_color);
end;

{ METHOD: print_area - rysowanie planszy gracza podczas dodawania statków }
procedure print_area(plansza : area);
var plansze : areas;

begin
  plansze[1] := player1_ships_on_area;
  print_head_of_area(1); { nagłówek tabeli } 
  print_horizontal_border(1); { podkreślenie nagłówka tabeli }
  print_only_areas(1, plansze); { zawartość tabeli }
end;

{ METHOD: print_two_areas - rysuje dwie tabele obok siebie }
procedure print_two_areas(plansza1 : area; plansza2 : area);
var plansze : areas;

begin
  plansze[1] := plansza1;
  plansze[2] := plansza2;
  print_head_of_area(2); { wypisuje nagłówki +2+ tabel }
  print_horizontal_border(2); { wypisuje poziome kreski dla +2+ tabel }
  print_only_areas(2, plansze); { wypisuje tylko zawartość tabel + lewą kolumnę z literami }
end;

{ METHOD: error_wrong_place_for_ship - wyświetlenie komunikatu, że statek nie może zostać tam umieszczony }
procedure error_wrong_place_for_ship;
begin
  textcolor(error_color);
  writeln('Statek nie może zostać umieszczony w podanym miejscu.');
  textcolor(normal_color);
end;

{ BLOCK4: funkcje dotyczace strzelania, konwersji stringów na współrzędne itd. }

{ METHOD: string_to_location - konwersja stringa do rekordu typu shot, który odpowiada polu na planszy }
function string_to_location(target : string):shot;
var
  location : shot;
  y : char;
  x : integer;
begin
  y := target[1];
  if (y < 'A') then begin y := 'A' end;
  if (y > M) then begin y := M end;
  delete(target, 1, 1);
  val(target, x);
  if (x < 1) then begin x := 1 end;
  if (x > N) then begin x := N end;
  location.y := y;
  location.x := x;
  string_to_location := location;
end;

{ BLOCK3: funkcje dotyczace rozpoczynania, kontynuowania badz konczenia rozgrywki:
          init_weights, init_areas, init_hits, new_game, next_move, break_game, set_player_ships, place_ship }

{ METHOD: init_weights - początkowe wypełnienie akwenów wagami - do algorytmu wyboru pól do strzelania }
procedure init_weights;
begin
  if (state = 2) then begin
    player1_weights := initial_weights;
    player1_max_weight := initial_max_weight;
  end;
  player2_weights := initial_weights;
  player2_max_weight := initial_max_weight;
end;

{ METHOD: init_areas - początkowe wypełnie akwenów domyślnym znakiem }
procedure init_areas;
var
  y : char;
  x : integer;

begin
  for y := 'A' to M do begin
    for x := 1 to N do begin
      player1_ships_on_area[y][x] := default_mark;
      player2_ships_on_area[y][x] := default_mark;
      player1_shots_on_area[y][x] := default_mark;
      player2_shots_on_area[y][x] := default_mark;
    end;
  end;
end;

{ METHOD: init_hits - ustawienie ilości trafień we wrogie statki dla obu graczy na zero }
procedure init_heats;
begin
  player1_hits := 0;
  player2_hits := 0;
end;

{ METHOD: place_ship - ustawia statek w wybranym miejscu (wsp + kierunek + długość) i zwraca 1 jeśli sie udało to zrobić lub 0 jeśli nie }
function place_ship(location : shot; kierunek : direction; length : integer; player: integer):integer;
var
  y_start, y_stop, y : char;
  x_start, x_stop, x : integer;

begin
  if(location.y < 'A') or (location.x < 1) then begin { statek zaczyna się poza planszą }
    place_ship := 0;
    exit;
  end;
  if(kierunek = poziomo) then begin { statek ustawiany poziomo }
    if(location.x + length - 1 > N) or (location.y > M) then begin { statek kończy się poza planszą }
      place_ship := 0;
      exit;
    end;
  end else begin
    if(location.x > N) or (chr(ord(location.y) + length - 1) > M) then begin { statek kończy się poza planszą }
      place_ship := 0;
      exit;
    end;
  end;

  { ustawienie prostokąta dookoła statku, który trzeba sprawdzić, czy jest pusty }
  y_start := chr(ord(location.y) - 1); { poprzedni znak }
  x_start := location.x - 1;

  if (kierunek = pionowo) then begin { statek pionowo }
    y_stop := chr(ord(location.y) + length);
    x_stop := location.x + 1;
  end else begin { statek poziomo }
    y_stop := chr(ord(location.y) + 1);
    x_stop := location.x + length;
  end;

  if (y_start < 'A') then y_start := 'A'; { przypadek, gdy statek styka się z górną krawędzią planszy }
  if (x_start < 1) then x_start := 1; { przypadek, gdy statek styka się z lewą krawędzią planszy }
  if (y_stop > M) then y_stop := M; { przypadek, gdy statek styka się z dolną krawędzią planszy }
  if(x_stop > N) then x_stop := N; { przypadek, gdy statek styka się z prawą krawędzia planszy }

  { sprawdzenie, czy wszystkie pola dookoła statku są wolne i czy pola pod statek też są wolne, i jeśli tak, to ich wypełnienie }
  if(player = 1) then begin { ustalenie, na której planszy sprawdzać; pierwszy gracz }
    for y := y_start to y_stop do begin
      for x := x_start to x_stop do begin
        if (player1_ships_on_area[y][x] <> default_mark ) then begin { znak na polu jest różny od domyślnego (oznaczającego pole bez statku) }
          place_ship := 0;
          exit;
        end;
      end;
    end;

    { pola są puste, można umieścić statek }
    if (kierunek = pionowo) then begin
      for y := location.y to chr(ord(location.y) + length - 1) do begin
        player1_ships_on_area[y][location.x] := ship_mark;
      end;
    end else begin
      for x := location.x to (location.x + length - 1) do begin
        player1_ships_on_area[location.y][x] := ship_mark;
      end;
    end;
  end else begin { drugi gracz }
    for y := y_start to y_stop do begin
      for x := x_start to x_stop do begin
        if (player2_ships_on_area[y][x] <> default_mark ) then begin { znak na polu jest różny od domyślnego (oznaczającego pole bez statku) }
          place_ship := 0;
          exit;
        end;
      end;
    end;

    { pola są puste, można umieścić statek }
    if (kierunek = pionowo) then begin
      for y := location.y to chr(ord(location.y) + length - 1) do begin
        player2_ships_on_area[y][location.x] := ship_mark;
      end;
    end else begin
      for x := location.x to (location.x + length - 1) do begin
        player2_ships_on_area[location.y][x] := ship_mark;
      end;
    end;
  end;

  place_ship := 1; { umieszczenie statku powiodło się ;) }
end;

{ METHOD: obsługa ustawiania statków gracza }
procedure set_player_ships;
var
  i : integer;
  target : string; { string postaci: A10 }
  wanted_direction : char; { określenie kierunku 1 - poziomo, 2 - pionowo }
  location : shot; { przetworzona wspolrzedna lewego gornego rogu statku }
  kierunek : direction; { określenie kierunku w postaci: poziomo, pionowo - enum }
  placed : integer; { sprawdzenie, czy statek udalo sie umiescic }

begin
  print_area(player1_ships_on_area); { rysowanie planszy gracza }
  for i := 1 to 5 do begin { na sztywno ustawiona ilość statków - 5 }
    placed := 0; { false, nie udalo sie jeszcze umiescic statku }
    repeat { próbuje umieścić statek tak długo, aż mu się uda }
      setting_ship_actions(1, ships[i]); { drugi parametr - długość statku }
      readln(target); { wczytanie współrzędnych }
      location := string_to_location(target); { wybór lokalizacji lewego górnego rogu statku }
      setting_ship_actions(2, 0);
      { wybór kierunku, w którym chcemy umieścić statek. Lewy górny róg statku będzie określany }
      wanted_direction := readkey;
      textcolor(normal_color);
      if (wanted_direction = '1') then begin { ustawienie kierunku }
        kierunek := poziomo;
      end else begin
        kierunek := pionowo;
      end;
      if (place_ship(location, kierunek, ships[i], 1) = 1) then begin { osatni parametr to numer gracza }
        placed := 1; { udało się umieścić statek }
      end else begin
        error_wrong_place_for_ship;
      end;
      print_area(player1_ships_on_area); { wypisanie planszy }
    until(placed = 1);
  end;
end;

{ METHOD: set_cpu_ships - zarzadza ustawianiem statkow dla komputera }
procedure set_cpu_ships(player : integer);
var
  i : integer;
  wanted_direction : integer; { określenie kierunku 1 - poziomo, 2 - pionowo }
  location : shot; { przetworzona wspolrzedna lewego gornego rogu statku }
  kierunek : direction; { określenie kierunku w postaci: poziomo, pionowo - enum }
  placed : integer; { sprawdzenie, czy statek udalo sie umiescic }

begin
  for i := 1 to 5 do begin { na sztywno ustawiona ilość statków - 5 }
    placed := 0; { false, nie udalo sie jeszcze umiescic statku }
    repeat { próbuje umieścić statek tak długo, aż mu się uda }
      { ustawienie pseudolosowo współrzędnych statku }
      location.y := chr(ord('A') + random(ord(M) - ord('A') + 1)); { wybór lokalizacji lewego górnego rogu statku, wartość z 'A'..M }
      location.x := 1 + random(N); { wartość z 1..N }
      { wybór kierunku, w którym zostanie umieszczony statek. Lewy górny róg statku będzie określany }
      wanted_direction := random(2) + 1; { 1 lub 2 }
      if (wanted_direction = 1) then begin { ustawienie kierunku }
        kierunek := poziomo;
      end else begin
        kierunek := pionowo;
      end;
      if (place_ship(location, kierunek, ships[i], player) = 1) then placed := 1; { osatni parametr to numer gracza: 1 lub 2; udało się umieścić statek }
    until(placed = 1);
  end;
end;

procedure new_game; { uniknięcie zapętlenia }
forward;

procedure actions_game; { again }
forward;

{ BLOCK1: PART! }

{ METHOD: choose_location_action - metoda wyświetlająca komunikat tuż przed oddaniem strzału }
procedure choose_location_action;
begin
  textcolor(action_color);
  writeln('Podaj współrzędne, gdzie chcesz strzelić');
  textcolor(normal_color);
end;

{ METHOD: error_dont_shoot_twice_the_same_place - metoda wyświetlająca komunikat o próbie ponownego strzału
                                                  w to samo miejsce. }
procedure error_dont_shoot_twice_the_same_place;
begin
  textcolor(error_color);
  writeln('Już oddałeś strzał w to miejsce. Spróbuj w inne.');
  textcolor(normal_color);
end;

{ METHOD: you_hit_the_ship - metoda wyświetlająca komunikat o trafieniu we wrogi okręt. }
procedure you_hit_the_ship;
begin
  textcolor(greeting_color);
  writeln('Trafiłeś wrogi okręt! Doskonale!');
  textcolor(normal_color);
end;

{ METHOD: you_missed_the_ship - metoda wyświetlająca komunikat w przypadku spudłowania. }
procedure you_missed_the_ship;
begin
  textcolor(greeting_color);
  writeln('Niestety nie trafiłeś w żaden okręt.');
  textcolor(normal_color);
end;

{ METHOD: someone_win_the_game - metoda wyświetlająca komunikat o zwycięstwie jednego z graczy. }
procedure someone_win_the_game(player : integer);
begin
  textcolor(greeting_color);
  if (state = 1) then begin
    if (player = 1) then begin
      writeln('Właśnie zniszczyłeś flotę przeciwnika! Gratulacje!');
    end else begin
      writeln('Niestety Twoja flota została zniszczona.');
    end;
  end else begin
    writeln('Zwyciężył gracz nr ', player);
  end;
  textcolor(normal_color);
end;

{ BLOCK3: PART! }

{ METHOD: shoot_player - metoda strzelająca :) zaznacza trafienie bądź pudło na odpowiednich tablicach obu playerów }
procedure shoot_player;
var
  target : string;
  location : shot;
  hit : integer; { czy został trafiony statek wroga? }
  shooted : integer; { czy udało się oddać strzał? }

begin
  choose_location_action;
  shooted := 0; { nie został jeszcze oddany strzał w tej turze. }
  repeat { próbuj strzelać, aż strzelisz w pole, w które nie strzelałeś jeszcze }
    readln(target);
    location := string_to_location(target);
    if (player1_shots_on_area <> default_mark) then begin
      error_dont_shoot_twice_the_same_place; { oddano już strzał w to miejsce }
    end else begin
      if (player2_ships_on_area[location.y][location.x] = ship_mark) then begin { trafiono statek }
        player1_shots_on_area[location.y][location.x] := hit_mark; { w tablicy strzałów gracza ustawia znacznik trafienia }
        player2_ships_on_area[location.y][location.x] := hit_mark; { w tablicy statków playera2 ustawia znacznik trafienia }
        you_hit_the_ship;
        inc(player1_hits); { zwiększa ilość trafień gracza }
      end else begin { spudłowano }
        player1_shots_on_area[location.y][location.x] := miss_mark; { w tablicy strzałów gracza ustawia znacznik pudła }
        player2_ships_on_area[location.y[[location.x] := miss_mark; { w tablicy statków playera2 ustawia znacznik pudła }
        you_missed_the_ship;
      end;
      shooted := 1;
    end;
  until(shooted = 1);
end;

{ METHOD: shoot_cpu - metoda, która umożliwia strzelanie komputerowi. Bazuje na wagach podczas wyboru miejsca oddania strzału. }
procedure shoot_cpu(player : integer);
var
  location : shot;
  hit : integer;
  shooted : integer;
  y : char;
  x : integer;

begin
  
end;

{ BLOCK1: PART! }

{ METHOD: actions - wyswietlanie mozliwych akcji w zaleznosci od stanu programu:
                    0 - wyswietla mozliwosc wyboru trybu gry }
procedure actions;
begin
  textcolor(menu_color);
  if (state = 0) then begin
    writeln('1. Gracz vs Komputer');
    writeln('2. Komputer vs Komputer');
    textcolor(input_color);
    choice := readkey;
    case choice of
      '1': state := 1;
      '2': state := 2;
    end;
    new_game;
  end;
  textcolor(normal_color);
end;

{ BLOCK3: PART! }

{ METHOD: next_move - umożliwia graczowi wykonanie ruchu, następnie ruch wykonuje drugi gracz (komputer) i wówczas stan jest pokazywany }
procedure next_move;
var winner : integer;

begin
  if (state = 1) { ruch playera1 }
    shoot_player;
  end else begin
    shoot_cpu(1); { player1 jeśli jest cpu, to wykonuje ruch }
  end;

  shoot_cpu(2); { player2 wykonuje ruch }
  if (state = 1) then begin { rysuje tablice }
    print_two_areas(player1_ships_on_area, player1_shots_on_area);
  end else begin
    print_two_areas(player1_ships_on_area, player2_ships_on_area);
  end;

  if (player1_hits >= win_if) or (player2_hits >= win_if) then begin { sprawdzenie, czy ktoś już wygrał }
    winner := player1_hits >= player2_hits ? 1 : 2; { sprawdzenie, który gracz wygrał }
    someone_win_the_game(winner); { informacja o tym, że ktoś wygrał. parametr - numer gracza, ktory jest zwyciezca }
    state := 0;
    actions_game; { powrót do menu głównego poprzez metodę actions_game, żeby uniknąć niepotrzebnego forwardowania }
  end else begin
    actions_game;
  end;
end;

{ METHOD: first_move - dokładnie to samo co next_move, tylko jeszcze na początku rysuje tabele }
procedure first_move;
begin
  { rysuje tablice }
  if (state = 1) then print_two_areas(player1_ships_on_area, player1_shots_on_area);
  next_move; { następny ruch }
end;

{ BLOCK1: PART! - wypisywanie menu podczas gry }

{ METHOD: menu - wyswietlanie menu w zaleznosci od stanu programu }
procedure menu;
begin
  textcolor(menu_color);
  writeln('1. Nowa gra');
  writeln('0. Zakończ');
  textcolor(normal_color);

  choice := readkey;
  case choice of
    '1': actions;
    '0': halt;
  end;
end;

{ METHOD: actions_game - wyświetla menu podczas trwania rozgrywki }
procedure actions_game;
begin
  textcolor(action_color);
  if (state <> 0) then begin
    if (state = 1) then begin
      writeln('1. Wykonaj ruch');
    end else begin
      writeln('1. Następny ruch');
    end;

    writeln('2. Przerwij rozgrywkę');
    textcolor(input_color);
    choice := readkey;
    case choice of
      '1': first_move;
      '2': begin
        state := 0;
        clrscr;
        menu;
      end;
    end;
  end else begin { przypadek, gdy gra się właśnie skończyła }
    menu;
  end;
  textcolor(normal_color);
end;

{ BLOCK3: PART! - funkcje dotyczace rozpoczynania, kontynuowania badz konczenia rozgrywki:
          init_weights, init_areas, new_game, next_move, break_game, set_player_ships, place_ship }

{ METHOD: new_game - rozpoczecie nowej gry. w zaleznosci od stanu beda rozne opcje }
procedure new_game;
begin
  init_weights;
  init_areas;
  init_hits;
  if (state = 1) then begin
    set_player_ships
  end else begin
    set_cpu_ships(1)
  end; { ustawienie na planszy pierwszego gracza (cpu w tym wypadku) statków }
  set_cpu_ships(2); { ustawienie na planszy drugiego gracza (cpu) statków }
  actions_game;
end;

{ BLOCK1: wypisywanie menu, akcji, powitania }

{ METHOD: powitanie - wyswietlanie powitania po uruchomieniu programu }
procedure powitanie;
begin
  clrscr;
  textcolor(greeting_color);
  writeln('Witaj w grze STATKI');
  writeln('Copyright: 2010 Artur Hebda');
  textcolor(normal_color);
end;

{ BLOCK2: main program }
begin
  randomize; { uruchomienie generatora liczb pseudolosowych }
  state := 0;
  powitanie;
  menu;
end.
