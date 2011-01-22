unit UOutput;

interface

uses dos, crt, udate, utime, udatetime, uevent, uposition;

const
  default_color = 7; { jasnoszary }
  input_color = 14; { żółty :D }
  number_in_menu_color = 15;
  description_in_menu_color = 7;
  menu_label_color = 7;

type
  toutput = class
    position : tposition;
    top, left : integer;
    procedure print(message : string; increase_left : boolean = true; padding_left : word = 0; padding_top : word = 0; color : word = default_color);
    procedure print_menu_option(number : word; message : string); overload;
    procedure print_menu_option(symbol : char; message : string); overload;
    procedure set_position(x, y : word);
    procedure new_line;
    procedure clear_line;
    procedure reset;
    constructor create(x, y : word);
  end;

implementation

procedure toutput.print(message : string; increase_left : boolean = true; padding_left : word = 0; padding_top : word = 0; color : word = default_color);
begin
  if (padding_left > 0) or (padding_top > 0) then gotoxy(self.position.x + padding_left, self.position.y + padding_top)
  else gotoxy(self.position.x + left, self.position.y + top);

  textcolor(color);
  write(message);
  if (increase_left) then left := left + length(message);
  textcolor(default_color);
end;

procedure toutput.print_menu_option(number : word; message : string);
var
  number_to_s : string;

begin
  str(number, number_to_s);
  self.print(concat(number_to_s, '. '), true, 0, 0, number_in_menu_color);
  self.print(concat(message, ' '), true, 0, 0, description_in_menu_color);
end;

procedure toutput.print_menu_option(symbol : char; message : string);
begin
  self.print(concat(symbol, '. '), true, 0, 0, number_in_menu_color);
  self.print(concat(message, ' '), true, 0, 0, description_in_menu_color);
end;

procedure toutput.new_line;
begin
  inc(self.top);
  self.left := 0;
end;

procedure toutput.clear_line;
begin
  gotoxy(self.position.x + self.left, self.position.y + self.top);
  write('':(80 - self.left - self.position.x));
end;

procedure toutput.reset;
begin
  self.left := 0;
  self.top := 0;
end;

procedure toutput.set_position(x, y : word);
begin
  if (x > 0) and (y > 0) then begin
    self.position.x := x;
    self.position.y := y;
  end;

  self.reset;
  self.clear_line;
end;

constructor toutput.create(x, y : word);
begin
  self.left := 0;
  self.top := 0;
  self.position := tposition.create(x, y);
  self.clear_line;
end;

end.
