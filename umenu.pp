unit UMenu;

interface

uses dos, crt, tripleoperator, udate, utime, udatetime, uevent, uposition, uinput, uoutput, ufile;

type
  tresource = class
    database : tfile;
    position : tposition;
    steps : integer; { ile kroków potrzeba by utworzyć element z resources }
    procedure add(var event : tevent; step : word; sequence : string = '');
    procedure index(conditions : boolean = false; how_many_days_in_advance : word = 2; how_many_can_i_show : word = 100);
    constructor create(x : word = 0; y : word = 0);
    {procedure delete;}
  end;

  tmenu = class
    event : tresource;
    position, menu_position : tposition;
    if_update_menu : boolean;
    end_program_key : char; { znak przerywający działanie programu }
    procedure clear_lines; { czyści ekran w tej części, gdzie mogło sie coś pojawić }
    procedure update_menu(action : word); { wypisuje dolne menu }
    procedure set_position(x, y : word);
    constructor create(x : word = 0; y : word = 0);
  end;
{
  tcalendar = file of tevent;
  tevents = array of tevent;
}
implementation

procedure tresource.add(var event : tevent; step : word; sequence : string = '');
var
  output : toutput;

begin
  output := toutput.create(self.position.x, self.position.y);

  if (step = 1) then begin
    output.print('Nazwa', false);
  end;
  if (step = 2) then begin
    event.name := sequence;
    output.print('Czy całodzienny? [T/n]', false);
  end;
  if (step = 3) then begin
    event.all_day := ifthen(sequence = 'T', true, false);
    output.print('Czy rokroczny? [T/n]', false);
  end;
  if (step = 4) then begin
    event.anniversary := ifthen(sequence = 'T', true, false);

    if (event.all_day) then begin
      if (event.anniversary) then
        output.print('Data pierwotnego wydarzenia [dd.mm.rrrr]', false)
      else
        output.print('Data [dd.mm.rrrr]', false);
      
    end else
      output.print('Data rozpoczęcia [dd.mm.rrrr]', false);

  end;
  if (step = 5) then begin
    event.start.date.to_date(sequence);
    
    if (event.all_day) then begin
      event.finish.date := event.start.date;
      event.start.time.to_time(0);
      event.finish.time.to_time(24 * 3600 * 100 - 1);
      self.database.add(event);
      self.steps := 5;

    end else begin
      output.print('Godzina rozpoczęcia [gg:mm]');
      self.steps := 8;
    end;
  end;
  if (step = 6) then begin
    event.start.time.to_time(sequence);
    output.print('Data zakończenia [dd.mm.rrrr]');
  end;
  if (step = 7) then begin
    event.finish.date.to_date(sequence);
    output.print('Godzina zakończenia [gg:mm]');
  end;
  if (step = 8) then begin
    event.finish.time.to_time(sequence);
    self.database.add(event);
  end;
  
  output.destroy;
end;

procedure tresource.index(conditions : boolean = false; how_many_days_in_advance : word = 2; how_many_can_i_show : word = 100);
var
  events : tevents;
  i, j : integer;
  output : toutput;

begin
  output := toutput.create(self.position.x, self.position.y);
  events := self.database.index(conditions, how_many_days_in_advance);

  j := 0;

  for i := low(events) to high(events) do begin
    output.clear_line;
    output.print(events[i].to_a[0]); { prints it with colors, to make it happy :D }
    output.print(events[i].to_a[1], false, 0, 0, 15);
    output.new_line;

    inc(j);
    if (j > how_many_can_i_show) then break;
  end;
  
  output.destroy;
end;

procedure tmenu.set_position(x, y : word);
begin
  self.position.set_new(x, y);
  self.event.position.set_new(x, y);
end;

procedure tmenu.clear_lines;
var
  output : toutput;
  i : integer;

begin
  output := toutput.create(self.position.x, self.position.y);
  for i := 0 to 12 do begin
    output.clear_line;
    output.new_line;
  end;
  output.destroy;
end;

procedure tmenu.update_menu(action : word);
var
  output : toutput;

begin
  if (self.if_update_menu) then begin
    output := toutput.create(self.menu_position.x, self.menu_position.y);
  
    if (action = 0) then begin // domyślny widok
      output.print('Menu: ', true, 0, 0, 14);
      output.print_menu_option(1, 'Stoper');
      output.print_menu_option(2, 'Wydarzenia');
      output.print_menu_option(3, 'Budzik');
    end;
    if (action = 1) then begin // stoper
      output.print('Menu: ', true, 0, 0, 14);
      output.print_menu_option(1, 'Start'); // stoper run! 
      output.print_menu_option(2, 'Powrót');
    end;
    if (action = 2) then begin
      output.print('Menu: ', true, 0, 0, 14);
      output.print_menu_option(1, 'Zobacz nadchodzące');
      output.print_menu_option(2, 'Dodaj');
      output.print_menu_option(3, 'Powrót');
    end;
    if (action = 11) then begin // runningujący stoper
      output.print('Menu: ', true, 0, 0, 14);
      output.print_menu_option(1, 'Zatrzymaj');
      output.print_menu_option(2, 'Powrót');
    end;
    if (action = 12) then begin // zatrzymany stoper (wyniki)
      output.print('Menu: ', true, 0, 0, 14);
      output.print_menu_option(1, 'Stoper');
      output.print_menu_option(2, 'Powrót');
    end;
    if (action = 21) then begin
      output.print('Menu: ', true, 0, 0, 14);
      output.print_menu_option(1, 'Dodaj');
      output.print_menu_option(2, 'Powrót');
    end;
    if (action = 22) then begin
      output.print('Menu: ', true, 0, 0, 14);
    end;
    
    output.print_menu_option(self.end_program_key, 'Zakończ');
    self.if_update_menu := false;
    output.destroy;
  end;
end;

constructor tresource.create(x : word = 0; y : word = 0);
begin
  self.database := tfile.create;
  self.position := tposition.create(x, y);
  self.steps := 8;
end;

constructor tmenu.create(x : word = 0; y : word = 0);
begin
  self.event := tresource.create(x, y);
  self.position := tposition.create(x, y);
  self.menu_position := tposition.create(x, y);
  self.if_update_menu := true;
end;

end.
