unit UDate;

interface

uses dos, crt;

type
  tlength_of_months = array[1..12] of word;
  tdate = class
    public
      year, month, day, wday : word;
      function to_s(with_year : boolean = true; with_name_of_month : boolean = false; with_name_of_year : boolean = false; with_name_of_day : boolean = false; with_current_year : boolean = false) : string;
      procedure set_current;
      procedure to_date(sequence : string); { z wykorzystaniem str postaci [dd.mm.yyyy] }
      procedure calculate_wday; { na podstawie dnia, miesiąca i roku oblicza dzień tygodnia i ustawia wday }
      function distance_from_now_in_days : integer; { zwraca różnicę pomiędzy datą, na której jest wywoływana }
      constructor create;

    private
      function length_of_months : tlength_of_months;
      function name_of_month : string;
      function name_of_day : string;
      function add_0_if_less_than_10(const variable : word) : string;
  end;

function compare2dates(a, b : tdate) : integer; { like spaceship operator }

implementation

function tdate.to_s(with_year : boolean = true; with_name_of_month : boolean = false; with_name_of_year : boolean = false; with_name_of_day : boolean = false; with_current_year : boolean = false) : string;
var
  current : tdate;

begin
  current := tdate.create;
  current.set_current;
  
  to_s := '';

  if (with_name_of_day) then to_s := self.name_of_day + ', ';
  to_s := to_s + self.add_0_if_less_than_10(self.day);

  if (with_name_of_month) then
    to_s := to_s + ' ' + self.name_of_month
  else
    to_s := to_s + '.' + self.add_0_if_less_than_10(self.month);

  if (with_year) then begin
    if (with_name_of_month) then to_s := to_s + ' '
    else to_s := to_s + '.';

    if(with_current_year) then to_s := to_s + self.add_0_if_less_than_10(current.year)
    else to_s := to_s + self.add_0_if_less_than_10(self.year);

    if(with_name_of_year) then to_s := to_s + ' r.';
  end;
  
  current.destroy;
end;

procedure tdate.to_date(sequence : string);
var
  current : tdate;

begin
  val(sequence[1..2], self.day);
  val(sequence[4..5], self.month);
  val(sequence[7..10], self.year);
  current := tdate.create;
  current.set_current;
  if (self.year < 0) or (self.year > 2099) then self.year := current.year;
  if (self.month < 1) or (self.month > 12) then self.month := current.month;
  if (self.day < 1) or (self.day > self.length_of_months[self.month]) then self.day := current.day;
  self.calculate_wday;
end;

procedure tdate.calculate_wday; { algorytm Zellera }
var
  y, m, d, h, z, j, k, x : word;

begin
  if (self.month < 3) then begin
    m := self.month + 10;
    y := self.year - 1;
  end else begin
    m := self.month - 2;
    y := self.year;
  end;

  d := self.day;
  j := y mod 100; { which year of century }
  k := y div 100; { which century }
  z := (m * 13 - 1) div 5; 
  x := j div 4;
  y := k div 4;
  h := z + x + y + d + j + 5 * k;

  self.wday := h mod 7;
end;

function tdate.name_of_month : string;
const
  names_of_months : array[1..12] of string = ('stycznia', 'lutego', 'marca', 'kwietnia', 'maja', 'czerwca', 'lipca', 'sierpnia', 'września', 'października', 'listopada', 'grudnia');

begin
  name_of_month := names_of_months[self.month];
end;

function tdate.name_of_day : string;
const
  names_of_days : array[0..6] of string = ('niedziela', 'poniedziałek', 'wtorek', 'środa', 'czwartek', 'piątek', 'sobota');

begin
  name_of_day := names_of_days[self.wday];
end;

procedure tdate.set_current;
begin
  getdate(self.year, self.month, self.day, self.wday);
end;

function tdate.add_0_if_less_than_10(const variable : word) : string;
var
  str_variable : string;

begin
  str(variable, str_variable);
  if (variable < 10) then str_variable := '0' + str_variable;
  add_0_if_less_than_10 := str_variable;
end;

function tdate.distance_from_now_in_days : integer;
var
  distance, current : tdate;
  in_days : integer;

begin
  current := tdate.create;
  current.set_current;

  distance := tdate.create;

  if (compare2dates(current, self) <> -1) then begin
    distance.year := self.year;
    distance.month := self.month;
    distance.day := self.day;
    in_days := 0;
    repeat
      inc(distance.day);
      if (distance.day > distance.length_of_months[distance.month]) then begin
        distance.day := 1;
        inc(distance.month);
      end;
      if (distance.month > 12) then begin
        distance.month := 1;
        inc(distance.year);
      end;
      inc(in_days);
    until ((distance.year >= current.year) and (distance.month >= current.month) and (distance.day >= current.day));

  end else begin
    distance.year := current.year;
    distance.month := current.month;
    distance.day := current.day;
    in_days := 0;

    repeat
      inc(distance.day);
      if (distance.day > distance.length_of_months[distance.month]) then begin
        distance.day := 1;
        inc(distance.month);
      end;
      if (distance.month > 12) then begin
        distance.month := 1;
        inc(distance.year);
      end;
      inc(in_days);
    until ((distance.year >= self.year) and (distance.month >= self.month) and (distance.day >= self.day));
  end;
  distance_from_now_in_days := in_days;
end;

function tdate.length_of_months : tlength_of_months;
begin
  length_of_months[1] := 31;
  length_of_months[2] := 28;
  length_of_months[3] := 31;
  length_of_months[4] := 30;
  length_of_months[5] := 31;
  length_of_months[6] := 30;
  length_of_months[7] := 31;
  length_of_months[8] := 31;
  length_of_months[9] := 30;
  length_of_months[10] := 31;
  length_of_months[11] := 30;
  length_of_months[12] := 31;

  if (self.year mod 4 = 0) and (self.year mod 100 <> 0) or (self.year mod 400 = 0) then length_of_months[2] := 29;
end;

constructor tdate.create; { init values }
begin
  self.year := 1970;
  self.month := 1;
  self.day := 1;
  self.calculate_wday;
end;


function compare2dates(a, b : tdate) : integer; { like spaceship operator }
begin
  if (a.year < b.year) then begin compare2dates := -1; exit; end;
  if (a.year > b.year) then begin compare2dates := 1; exit; end;
  { the same year }
  if (a.month < b.month) then begin compare2dates := -1; exit; end;
  if (a.month > b.month) then begin compare2dates := 1; exit; end;
  { the same year and month }
  if (a.day < b.day) then begin compare2dates := -1; exit; end;
  if (a.day > b.day) then begin compare2dates := 1; exit; end;
  { the same date }
  compare2dates := 0;
end;

end.
