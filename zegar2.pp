program ZegarZBudzikiem;

uses dos, crt, tripleoperator, udate, utime, udatetime, uevent, uposition, uinput, umenu, ufile;

var
  datetime : tdatetime;
  a : char;
  i : integer;
  name : string;
  input : tinput;
  event : tevent;
  menu : tmenu;
  database : tfile;
  events : tevents;

procedure write_on(x, y : word; caption : string);
begin
  gotoxy(x, y);
  write(caption);
end;

procedure write_on_and_go_back_to(x, y : word; caption : string; back_to_x : word = 0; back_to_y : word = 0);
begin
  write_on(x, y, caption);
  if (x = 0) or (y = 0) then gotoxy(x, y)
  else gotoxy(back_to_x, back_to_y);
end;

begin
  datetime := tdatetime.create;
  datetime.set_current;
  event := tevent.create;
  event.name := 'Urodziny Mariana';
  event.all_day := true;
  event.anniversary := true;
  event.start.date.to_date('02.01.2011');
  event.finish.date.to_date('02.01.2011');
  event.start.time.to_time(0);
  event.finish.time.to_time(24 * 3600 * 100 - 1);

  { input := tinput.create(2, 4); }
  menu := tmenu.create;
  menu.event.add;
  { menu.event.index; }
  database := tfile.create;
   {database.add(event);}
  { events := database.index; }
  events := database.index;
  for i := low(events) to high(events) do begin
    writeln(events[i].to_s);
  end;
  { events := database.index; }
end.
