unit UDate;

interface

uses dos, crt;

type
  tdate = class
    public
      year, month, day, wday : word;
      function to_s(with_name_of_month : boolean = false; with_name_of_year : boolean = false; with_name_of_day : boolean = false) : string;
      procedure set_current;
      procedure to_date(const sequence : string); { z wykorzystaniem str postaci [dd.mm.yyyy] }
      procedure calculate_wday; { na podstawie dnia, miesiąca i roku oblicza dzień tygodnia i ustawia wday }

    private
      function name_of_month : string;
      function name_of_day : string;
      function add_0_if_less_than_10(const variable : word) : string;
  end;

implementation

function tdate.to_s(with_name_of_month : boolean = false; with_name_of_year : boolean = false; with_name_of_day : boolean = false) : string;
begin
  to_s := '';

  if (with_name_of_day) then to_s := self.name_of_day + ', ';
  to_s := to_s + self.add_0_if_less_than_10(self.day);

  if (with_name_of_month) then
    to_s := to_s + ' ' + self.name_of_month + ' '
  else
    to_s := to_s + '.' + self.add_0_if_less_than_10(self.month) + '.';

  to_s := to_s + self.add_0_if_less_than_10(self.year);
  if(with_name_of_year) then to_s := to_s + ' r.';
end;

procedure tdate.to_date(const sequence : string);
begin
  val(sequence[1..2], self.day);
  val(sequence[4..5], self.month);
  val(sequence[7..10], self.year);
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

end.
