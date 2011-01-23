program ZegarZBudzikiem;

uses dos, crt, tripleoperator, udate, utime, ustopwatch, udatetime, uevent, uposition, uinput, uoutput, umenu, ufile;

const
  end_program_key = '#'; { znak kończący działanie programu }

var
  current : tdatetime;
  input : tinput;
  content : tmenu;
  event : tevent;
  output : toutput;
  stopwatch : tstopwatch;
  action : integer; { flaga w programie }
  step : integer; { flaga w programie - flow dodawania eventu }

begin
  clrscr;
  gotoxy(2,23);
  writeln('iCalendar. Copyright 2011 Artur Hebda');
  input := tinput.create(2,4);
  output := toutput.create(2,2);
  current := tdatetime.create;
  content := tmenu.create;
  stopwatch := tstopwatch.create(2,6);
  
  { pozycja menu }
  content.menu_position.set_new(2, 22);
  
  { znak kończący działanie programu }
  content.end_program_key := end_program_key;

  { data }
  current.set_current;
  output.print('Dziś jest ');
  output.print(current.date.to_s(true,true,true,true));
  output.set_position(63,2);
  
  { godzina }
  output.print(current.time.to_s(true, false, true), false);
  
  action := 0;

  repeat
    { zegar }
    current.time.set_current;
    output.set_position(70, 2);
    output.print(concat('  ',current.time.to_s(true, false)), false);
    gotoxy(input.cursor.x + 1, input.cursor.y);
    delay(10);

    if (action = 0) then begin // tak jak jest na początku
      if(content.if_update_menu) then begin
        content.update_menu(action);
        gotoxy(input.cursor.x + 1, input.cursor.y);
        delay(5);
      end;
      
      if not(input.end_of_reading) then input.reading
      else begin

        case input.sequence[1] of
          '1' : action := 1; // stoper
          '2' : action := 2; // wydarzenia
          '3' : action := 3; // budzik TODO!
        end;

        input.reset;
        content.if_update_menu := true;
      end;
    end;

    if (action = 1) then begin // stoper
      if(content.if_update_menu) then begin
        content.update_menu(action);
        input.reset;
        
        stopwatch.print;
        
        gotoxy(input.cursor.x + 1, input.cursor.y);
        delay(5);
      end;

      if not(input.end_of_reading) then input.reading
      else begin
      
        case input.sequence[1] of
          '1' : action := 11; // run stoper
          '2' : action := 0; // powrót do podstawowego menu
        end;
        
        input.reset;

        content.set_position(2, 6);
        content.clear_lines;

        content.if_update_menu := true;
      end;
    end;
    
    if (action = 2) then begin // wydarzenia
      if(content.if_update_menu) then begin
        content.update_menu(action);
        gotoxy(input.cursor.x + 1, input.cursor.y);
        delay(5);
        input.reset;
      end;
      
      if not (input.end_of_reading) then input.reading
      else begin
      
        case input.sequence[1] of
          '1' : action := 21; // nadchodzące wydarzenia
          '2' : action := 22; // dodaj
          '3' : action := 0; // powrót do podstawowego menu
        end;
      
        input.reset;
        content.if_update_menu := true;
      end;
    end;
    
    if (action = 3) then begin
      // TODO! budzik! { ustawianie + granie + wyłączanie }
    end;
    
    if (action = 11) then begin // running stoper :D
      if (content.if_update_menu) then begin
        content.update_menu(action);
        
        input.sequence := stopwatch.run;
        input.end_of_reading := true;
        
        gotoxy(input.cursor.x + 1, input.cursor.y);
        delay(5);
      end;
      
      if not (input.end_of_reading) then input.reading
      else begin
        
        case input.sequence[1] of
          '1' : action := 12; // wyniki pomiaru
          '2' : action := 0; // powrót
        end;
        
        if (action = 0) then stopwatch.reset;

        input.reset;
        
        content.set_position(2, 6);
        content.clear_lines;

        content.if_update_menu := true;
      end;
    end;
    
    if (action = 12) then begin // wyniki stopera :D
      if (content.if_update_menu) then begin
        content.update_menu(action);
        stopwatch.print;
        gotoxy(input.cursor.x + 1, input.cursor.y);
        delay(5);
        input.reset;
      end;
      
      if not (input.end_of_reading) then input.reading
      else begin
        
        case input.sequence[1] of
          '1' : action := 1; // stoper 
          '2' : action := 0; // powrót
        end;
        
        stopwatch.reset;
        input.reset;

        content.clear_lines;
        content.if_update_menu := true;
      end;
    end;
    
    if (action = 21) then begin // nadchodzące wydarzenia
      if (content.if_update_menu) then begin
        content.update_menu(action);
        content.set_position(2, 6);
        content.event.index(true, 6, 12);
        gotoxy(input.cursor.x + 1, input.cursor.y);
        delay(5);
        input.reset;
      end;
      
      if not (input.end_of_reading) then input.reading
      else begin
        
        case input.sequence[1] of
          '1' : action := 22;
          '2' : action := 0;
        end;
        
        input.reset;
        content.clear_lines;
        content.if_update_menu := true;
      end;
    end;
    
    if (action = 22) then begin // dodawanie eventu
      if (content.if_update_menu) then begin
        content.update_menu(action);
        event := tevent.create;
        step := 1;
        output.set_position(2, 22);
        content.set_position(2, 6);
        content.event.add(event, step);
        gotoxy(input.cursor.x + 1, input.cursor.y);
        delay(5);
        input.reset;
      end;
      
      if (step >= content.event.steps) then begin
        action := 21;
        content.clear_lines;
        content.if_update_menu := true;
        
      end else begin
        if not (input.end_of_reading) then input.reading
        else begin
          inc(step);
          content.event.add(event, step, input.sequence);
          input.reset;
        end;
      end;
    end;
    
  until (input.key = end_program_key);
  
  clrscr;

  {in_future := tdate.create;
  in_future.day := 22;
  in_future.month := 1;
  in_future.year := 2011;
  clrscr;
  output := toutput.create(2, 2);
  number.i := in_future.distance_from_now_in_days;}
  //output.print(number.to_s);

  //stopwatch := tstopwatch.create(2, 4);
  //readln;
  //stopwatch.run;
  //writeln(in_future.distance_from_now_in_days);
{
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
}
  { input := tinput.create(2, 4); }
{  menu := tmenu.create; }
  //menu.event.add;
  //writeln('Nadchodzące wydarzenia');
  //menu.event.index(true, 6);
  { menu.event.index; }
  { database := tfile.create; }
   {database.add(event);}
  { events := database.index; }
{  events := database.index;
  for i := low(events) to high(events) do begin
    writeln(events[i].to_s);
  end; }
  { events := database.index; }
end.
