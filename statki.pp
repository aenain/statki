program statki;

uses dos, crt;

type
  shot = record { nowy typ do strzelania, y przyjmuje wartosci od A do N-tej litery, x od 1 do N }
    y : char;
    x : integer; 
  end;

  area = array['A'..'J'] of array[1..10] of char; { akwen morski :) }

const
  N = 10; { rozmiar planszy, poki co na sztywno 10 }
  normal_color = 15; { 15 - biały }
  menu_color = 2; { 2 - zielony }
  input_color = 14; { 14 - żółty }
  action_color = 7; { 7 - jasnoszary }
  greeting_color = 14; { 14 - żółty }
  ships : array[1..5] of integer = (5,4,3,3,2); { możliwe statki do wyboru }
  win_if = 17; { wygrana, gdy trafi wszystkie statki, inaczej: suma długości statków }

var
  state : integer; { stan programu: 0 - brak rozgrywki, 1 - gracz vs cpu, 2 - cpu vs cpu }
  choice : char; { ostatnio nacisniety klawisz do obslugi menu }
  target : shot; { miejsce, w ktore chcemy strzelic }
  direction : (pionowo, poziomo); { wybór kierunku, w którym chcemy umieścić statek. Lewy górny róg statku będzie określany }
  { tablice z przedrostkiem player1 odnosza sie do pierwszego zawodnika, czy to cpu1 czy playera.
    ships_on_area - plansza widziana przez danego gracza z jego własnymi statkami i strzałami przeciwnika.
    shots_on_area - plansza widziana przez danego gracza z jego własnymi strzałami }
  player1_ships_on_area, player2_ships_on_area, player1_shots_on_area, player2_shots_on_area : area;

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
    case choise of
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
    case choise of
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

{ BLOCK3: funkcje dotyczace rozpoczynania, kontynuowania badz konczenia rozgrywki:
          new_game, next_move, break_game }

{ METHOD: new_game - rozpoczecie nowej gry. w zaleznosci od stanu beda rozne opcje }
procedure new_game;
begin
  
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
  end;  ships : array[1..5] of integer = (5,4,3,3,2); { możliwe statki do wyboru }
end.
