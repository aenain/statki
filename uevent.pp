unit UEvent;

interface

uses dos, crt, udate, utime, udatetime;

type
  tarray = array of string;

  tevent = class
    public
      name : string[50];
      anniversary : boolean;
      all_day : boolean;
      start : tdatetime;
      finish : tdatetime;
      function to_s : string;
      function to_a : tarray;
      function less_than_a_day : boolean;
      constructor create;

    private
      function which_anniversary : integer;
  end;

implementation

function tevent.to_s : string; { TODO! dodać opcje zarządzające wypisywaniem, jeśli potrzeba }
var
  which_anniversary_to_s : string;

begin
  to_s := '';

  if (self.anniversary) and (self.which_anniversary > 0) then begin
    str(which_anniversary, which_anniversary_to_s);
    to_s := which_anniversary_to_s + '. ';
  end;

  to_s := to_s + self.name + ' (';
  if (self.all_day) then begin
    if (self.anniversary) then to_s := to_s + self.start.to_s(true, false, false, true, true)
    else to_s := to_s + self.start.to_s(true, false);
    
  end else begin
    if (self.less_than_a_day) then begin
      if (self.anniversary) then to_s := to_s + self.start.to_s(false, true) + ' - ' + self.finish.to_s(true, true, true, true, true)
      else to_s := to_s + self.start.to_s(false, true) + ' - ' + self.finish.to_s(true, true, true);

    end else begin
      if (self.anniversary) then begin
        to_s := to_s + self.start.to_s(true, true, true, false) + ' - ';
        to_s := to_s + self.finish.to_s(true, true, true, true, true);
      end else begin
        to_s := to_s + self.start.to_s(true, true, true, true) + ' - ';
        to_s := to_s + self.finish.to_s(true, true, true, true);
      end;
    end;
  end;
  to_s := to_s + ')';
end;

function tevent.to_a : tarray;
var
  first_part, second_part : string;
  which_anniversary_to_s, current_year : string;
  splitted_content : tarray;
  current : tdate;

begin
  current := tdate.create;
  current.set_current;
  str(current.year, current_year);

  setlength(splitted_content, 2);
  first_part := '';
  second_part := '';
  which_anniversary_to_s := '';

  if (self.anniversary) and (self.which_anniversary > 0) then begin
    str(self.which_anniversary, which_anniversary_to_s);
    first_part := which_anniversary_to_s + '. ';
  end;

  first_part := first_part + self.name + ' ';
  
  if (self.all_day) then begin
    if (self.anniversary) then second_part := second_part + self.start.to_s(true, false, false, true, true)
    else second_part := second_part + self.start.to_s(true, false);
    
  end else begin
    if (self.less_than_a_day) then begin
      if (self.anniversary) then second_part := second_part + self.start.to_s(false, true) + ' - ' + self.finish.to_s(true, true, true, true, true)
      else second_part := second_part + self.start.to_s(false, true) + ' - ' + self.finish.to_s(true, true, true);

    end else begin
      if (self.anniversary) then begin
        second_part := second_part + self.start.to_s(true, true, true, false) + ' - ';
        second_part := second_part + self.finish.to_s(true, true, true, true, true);

      end else begin
        second_part := second_part + self.start.to_s(true, true, true, true) + ' - ';
        second_part := second_part + self.finish.to_s(true, true, true, true);
      end;
    end;
  end;
  
  current.destroy;
  
  splitted_content[0] := first_part;
  splitted_content[1] := second_part;
  
  to_a := splitted_content; 
end;

function tevent.which_anniversary : integer;
var
  date : tdate;

begin
  date := tdate.create;
  date.set_current;
  which_anniversary := date.year - self.start.date.year;
end;

function tevent.less_than_a_day : boolean; { sprawdzenie, czy event zaczyna się i kończy tego samego dnia }
begin
  if (self.start.date.year = self.finish.date.year) and
     (self.start.date.month = self.finish.date.month) and
     (self.start.date.day = self.finish.date.day) then
    less_than_a_day := true
  else less_than_a_day := false;
end;

constructor tevent.create;
begin
  self.start := tdatetime.create;
  self.finish := tdatetime.create;
  self.anniversary := false; { just in case. }
  self.all_day := false;
  self.name := 'nazwa';
end;

end.
