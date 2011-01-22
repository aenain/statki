unit UStopwatch;

interface

uses dos, crt, udate, utime, udatetime, uposition, uoutput;

type
  tstopwatch = class
    public
      start, stop, duration : ttime;
      position : tposition;
      running, finished : boolean;
      output : toutput;
      procedure print;
      function run : char; { starts counting and also print stopwatch, returns char which interrupt counting }
      procedure stop_counting; { stop counting, print results }
      procedure reset; { you can use stopwatch again :) }
      constructor create(x : word = 0; y : word = 0);
  end;


implementation

function tstopwatch.run : char;
var
  current : ttime;
  stopped_by : char;  

begin
  current := ttime.create;
  self.start.set_current;
  self.running := true;

  repeat
    current.set_current;
    self.duration.to_time(current.to_period - self.start.to_period);
    self.print;
    delay(5);
  until keypressed;
  stopped_by := readkey;

  self.stop_counting;
  
  run := stopped_by;
end;

procedure tstopwatch.print;
begin
  output.reset;

  if (running) then output.print(self.duration.to_s(true, true), false)
  else begin
    if (finished) then begin
      output.print('Start:    ');
      output.print(self.start.to_s(true, true));

      output.new_line;
      output.print('Stop:     ');
      output.print(self.stop.to_s(true, true));
      
      output.new_line;
      output.print('Duration: ');
      output.print(self.duration.to_s(true, true));

    end else output.print(self.duration.to_s(true, true), false);
  end;
end;

procedure tstopwatch.stop_counting;
begin
  self.stop.set_current;
  self.running := false;
  self.finished := true;
  self.print;
end;

procedure tstopwatch.reset;
begin
  self.duration.hours := 0;
  self.duration.minutes := 0;
  self.duration.seconds := 0;
  self.duration.cs := 0;
  self.running := false;
  self.finished := false;
end;

constructor tstopwatch.create(x : word = 0; y : word = 0);
begin
  self.start := ttime.create;
  self.stop := ttime.create;
  self.duration := ttime.create;
  self.position := tposition.create(x, y);
  self.output := toutput.create(self.position.x, self.position.y);
  self.reset;
end;

end.
