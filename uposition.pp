unit UPosition;

interface

type
  tposition = class
    x : word;
    y : word;
    procedure set_new(new_x, new_y : word);
    constructor create(new_x : word = 0; new_y : word = 0);
  end;

implementation

procedure tposition.set_new(new_x, new_y : word);
begin
  self.x := new_x;
  self.y := new_y;
end;

constructor tposition.create(new_x : word = 0; new_y : word = 0);
begin
  if (new_x > 0) and (new_y > 0) then self.set_new(new_x, new_y);
end;

end.
