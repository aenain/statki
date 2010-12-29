program statki;

uses dos, crt;

type
  shot = record { nowy typ do strzelania, y przyjmuje wartosci od A do N-tej litery, x od 1 do N }
    y : char;
    x : integer; 
  end;

  area = array['A'..'J'] of array[1..10] of char; { akwen morski :) }
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
  ships : array[1..5] of integer = (5,4,3,3,2); { możliwe statki do wyboru }
  win_if = 17; { wygrana, gdy trafi wszystkie statki, inaczej: suma długości statków, poki co na sztywno 17 }
  default_mark = '  '; { znacznik pustego pola na planszy }
  ship_mark = '@'; { znacznik statku na planszy }
  hit_mark = 'x'; { znacznik trafienia na planszy }
  miss_mark = 'o'; { znacznik pudła na planszy }
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
  choice : char; { ostatnio nacisniety klawisz do obslugi menu }
  target : shot; { miejsce, w ktore chcemy strzelic }
  { tablice z przedrostkiem player1 odnosza sie do pierwszego zawodnika, czy to cpu1 czy playera.
    ships_on_area - plansza widziana przez danego gracza z jego własnymi statkami i strzałami przeciwnika.
    shots_on_area - plansza widziana przez danego gracza z jego własnymi strzałami }
  player1_ships_on_area, player2_ships_on_area, player1_shots_on_area, player2_shots_on_area : area;
  player1_weights, player2_weights : area_of_weights; { akweny z podanymi wagami poszczególnych pól, one będą się zmieniać wraz z postępem rozgrywki }
  player1_max_weight, player2_max_weight : integer; { przechowują maksymalną wartość wagi na akwenie }


{ BLOCK1: PART! funkcje wypisujące różne rzeczy ;) }

{ METHOD: setting_ship_actions - wyswietlanie komunikatow odnosnie ustawiania statkow w zaleznosci od etapu:
                                 wybor wspolrzednych - 1, wybor kierunku - 2 }
procedure setting_ship_actions(param : integer);
begin
  textcolor(action_color);
  if (param = 1) then begin
    writeln('Podaj współrzędne lewego górnego rogu statku');
  end else begin
    writeln('Wybierz kierunek, w którym chcesz ustawić statek');
    writeln('1. poziomo');
    writeln('2. pionowo');
  end;
  textcolor(input_color);
end;

{ METHOD: error_wrong_place_for_ship - wyświetlenie komunikatu, że statek nie może zostać tam umieszczony }
procedure error_wrong_place_for_ship;
begin
  textcolor(error_color);
  writeln('Statek nie może zostać umieszczony w podanym miejscu zgodnie z wybranym kierunkiem.');
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
          init_weights, new_game, next_move, break_game, set_ships, place_ship }

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

{ METHOD: place_ship - ustawia statek w wybranym miejscu (wsp + kierunek + długość) i zwraca 1 jeśli sie udało to zrobić lub 0 jeśli nie }
function place_ship(location : shot; kierunek : direction; length : integer):integer;
begin
  place_ship := 1;
end;

procedure set_ships;
var
  i : integer;
  target : string; { string postaci: A10 }
  wanted_direction : char; { określenie kierunku 1 - poziomo, 2 - pionowo }
  location : shot; { przetworzona wspolrzedna lewego gornego rogu statku }
  kierunek : direction; { określenie kierunku w postaci: poziomo, pionowo - enum }
  placed : integer; { sprawdzenie, czy statek udalo sie umiescic }

begin
  for i := 1 to 5 do begin { na sztywno ustawiona ilość statków - 5 }
    placed := 0; { false, nie udalo sie jeszcze umiescic statku }
    repeat { próbuje umieścić statek tak długo, aż mu się uda }
      setting_ship_actions(1);
      readln(target); { wczytanie współrzędnych }
      location := string_to_location(target); { wybór lokalizacji lewego górnego rogu statku }
      setting_ship_actions(2);
      { wybór kierunku, w którym chcemy umieścić statek. Lewy górny róg statku będzie określany }
      wanted_direction := readkey;
      textcolor(normal_color);
      if (wanted_direction = '1') then begin { ustawienie kierunku }
        kierunek := poziomo;
      end else begin
        kierunek := pionowo;
      end;
      if (place_ship(location, kierunek, ships[i]) = 1) then begin
        placed := 1; { udało się umieścić statek }
      end else begin
        error_wrong_place_for_ship;
      end;
    until(placed = 1);
  end;
end;

{ METHOD: new_game - rozpoczecie nowej gry. w zaleznosci od stanu beda rozne opcje }
procedure new_game;
begin
  
end;

procedure next_move;
begin

end;

procedure break_game;
begin

end;

{ BLOCK1: wypisywanie menu, akcji, powitania }

{ METHOD: menu - wyswietlanie menu w zaleznosci od stanu programu }
procedure menu;
begin
  textcolor(menu_color);
  writeln('1. Nowa gra');
  writeln('0. Zakończ');
  textcolor(normal_color);
end;

{ METHOD: actions - wyswietlanie mozliwych akcji w zaleznosci od stanu programu:
                    0 - wyswietla mozliwosc wyboru trybu gry
                    1 - nastepny ruch i przerwanie rozgrywki
                    2 - wykonaj ruch i przerwanie rozgrywki }
procedure actions;
begin
  textcolor(action_color);
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
  end else begin
    if (state = 1) then begin
      writeln('1. Wykonaj ruch');
    end else begin
      writeln('1. Następny ruch');
    end;

    writeln('2. Przerwij rozgrywkę');
    textcolor(input_color);
    choice := readkey;
    case choice of
      '1': next_move;
      '2': break_game;
    end;
  end;
  textcolor(normal_color);
end;

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
  state := 0;
  powitanie;
  menu;
  choice := readkey;
  case choice of
    '1': actions;
    '0': halt;
  end;
end.
