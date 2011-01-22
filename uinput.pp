unit UInput;

interface

uses dos, crt, udate, utime, udatetime, uevent, uposition, uoutput;

type
  tinput = class
    public
      sequence : string;
      key : char; { ostatnio wczytany klawisz }
      { code - kod ascii ostatnio wczytanego znaku }
      index, code, count : byte; { musi być coś innego niż length, bo nadpisuje metodę length, ale count znaczy length ;p }
      position : tposition; { pozycja lewego rogu na ekranie }
      cursor : tposition; { pozycja kursora na ekranie, podczas tworzenia obiektu powinna być równa position! }
      end_of_reading : boolean; { koniec wczytywania }
      procedure reading;
      procedure readchar(letter : char);
      procedure writeout;
      procedure reset;
      function to_date : tdate; { zwraca datę z inputa postaci dd.mm.yyyy }
      function to_time : ttime; { zwraca czas z inputa postaci 23:59 }
      constructor create(x, y : word);

    private
      max_length : byte;
      procedure add_char(letter : char);
      procedure move_cursor_to_left;
      procedure move_cursor_to_right;
      procedure delete_char;
      procedure set_position(x, y : word); { cursora również }
  end;

implementation

procedure tinput.reading;
begin
  textcolor(input_color);
  if not self.end_of_reading then begin
    while keypressed do begin
      self.readchar(readkey);
    end;
  end;
  textcolor(default_color);
end;

procedure tinput.readchar(letter : char);
begin
  self.key := letter;
  self.code := ord(letter);

  case self.code of
    8  : self.delete_char;
    13 : self.end_of_reading := true; { naciśnięcie entera kończy wpisywanie danych }
    75 : self.move_cursor_to_left; { strzałka w lewo }
    77 : self.move_cursor_to_right; { strzałka w prawo }
    else self.add_char(letter);
  end;

  self.writeout;
end;

procedure tinput.add_char(letter : char);
begin
  if (self.count < 255) then begin
    inc(self.index);
    inc(self.count);
    inc(self.cursor.x);
    if (self.count > self.max_length) then self.max_length := self.count;
    self.sequence := self.sequence + letter;
  end;
end;

procedure tinput.move_cursor_to_left;
begin
  if (self.index > 1) then begin
    dec(self.index);
    dec(self.cursor.x);
  end;
end;

procedure tinput.move_cursor_to_right;
begin
  if (self.index < self.count) and (self.count <= 255) then begin
    inc(self.index);
    inc(self.cursor.x);
  end;
end;

procedure tinput.delete_char;
begin
  if (self.index > 1) and (self.count > 0) then begin
    dec(self.index);
    dec(self.count);
    dec(self.cursor.x);
    delete(self.sequence, self.index, 1);
  end;
end;

procedure tinput.set_position(x, y : word);
begin
  self.position.set_new(x, y);
  self.cursor.x := self.position.x + self.index - 1;
  self.cursor.y := self.position.y;
end;

procedure tinput.writeout;
begin
  gotoxy(self.position.x, self.position.y);
  write(self.sequence);
  write('':(self.max_length - self.count));

  gotoxy(self.cursor.x, self.cursor.y);
end;

procedure tinput.reset;
begin
  self.sequence := '';
  self.index := 0;
  self.count := 0;
  gotoxy(self.position.x, self.position.y);
  write('':self.max_length);
  self.max_length := 0;
  self.end_of_reading := false;
  self.set_position(self.position.x, self.position.y);
  self.index := 1;
end;

function tinput.to_date : tdate;
var
  date : tdate;

begin
  date := tdate.create;
  date.to_date(self.sequence);
  to_date := date;
end;

function tinput.to_time : ttime;
var
  time : ttime;

begin
  time := ttime.create;
  time.to_time(self.sequence);
  to_time := time;
end;

constructor tinput.create(x, y : word);
begin
  self.position := tposition.create(x, y);
  self.cursor := tposition.create;
  self.reset;
end;

end.
