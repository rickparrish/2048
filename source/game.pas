unit game;

{$mode objfpc}{$H+}

interface

procedure Start;

implementation

uses
  Door,
  StrUtils, SysUtils;

var
  _Board: Array[1..4, 1..4] of Integer;
  _PointsToAdd: Integer;
  _Score: Integer;

procedure DrawTile(X, Y: Integer); forward;
procedure DrawTiles; forward;

procedure AddTile;
var
 R, X, Y: Integer;
begin
  // Pick a random location
  repeat
    X := Random(4) + 1;
    Y := Random(4) + 1;
  until (_Board[Y][X] = 0);

  // Pick a random value (90% chance of 2, 10% chance of 4)
  R := Random(10) + 1;
  if (R <= 9) then
  begin
    _Board[Y][X] := 2;
  end else
  begin
    _Board[Y][X] := 4;
  end;

  DrawTile(X, Y);
end;

procedure DrawBoard;
const
  BottomLeft: Char = #192;
  BottomRight: Char = #217;
  LineLeft: Char = #195;
  LineRight: Char = #180;
  Shadow: Char = #219;
  TileLeft: Char = #179;
  TileRight: Char = #179;
  TopLeft: Char = #218;
  TopRight: Char = #191;
var
  RowLine: String;
  RowTile: String;
  Temp: String;
begin
  RowLine := StringOfChar(#196, 6);
  Temp := StringOfChar(' ', 6);
  RowTile := Temp + #179 + Temp + #179 + Temp + #179 + Temp;

  // TODO Make pretty, also base position of constants instead of hardcoded "magic" values
  DoorGotoXY(25, 3);  DoorWrite(TopLeft + RowLine + #194 + RowLine + #194 + RowLine + #194 + RowLine + TopRight);
  DoorGotoXY(25, 4);  DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 5);  DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 6);  DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 7);  DoorWrite(LineLeft + RowLine + #197 + RowLine + #197 + RowLine + #197 + RowLine + LineRight + Shadow);
  DoorGotoXY(25, 8);  DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 9);  DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 10); DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 11); DoorWrite(LineLeft + RowLine + #197 + RowLine + #197 + RowLine + #197 + RowLine + LineRight + Shadow);
  DoorGotoXY(25, 12); DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 13); DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 14); DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 15); DoorWrite(LineLeft + RowLine + #197 + RowLine + #197 + RowLine + #197 + RowLine + LineRight + Shadow);
  DoorGotoXY(25, 16); DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 17); DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 18); DoorWrite(TileLeft + RowTile + TileRight + Shadow);
  DoorGotoXY(25, 19); DoorWrite(BottomLeft + RowLine + #193 + RowLine + #193 + RowLine + #193 + RowLine + BottomRight + Shadow);
  DoorGotoXY(25, 20); DoorWrite(' ' + StringOfChar(Shadow,  29));
end;

procedure DrawScore;
begin
  if (_PointsToAdd > 0) then
  begin
    DoorGotoXY(2, 5);
    DoorWrite(AddChar(' ', '+' + IntToStr(_PointsToAdd), 6));

    _Score += _PointsToAdd;
    _PointsToAdd := 0;
  end;

  DoorGotoXY(2, 2); DoorWrite('Score:');
  DoorGotoXY(2, 3); DoorWrite('------');
  DoorGotoXY(2, 4); DoorWrite(AddChar(' ', IntToStr(_Score), 6));
end;

procedure DrawScreen;
begin
  DoorClrScr;
  DrawBoard;
  DrawTiles;
  DrawScore;
end;

procedure DrawTile(X, Y: Integer);
var
  S: String;
begin
  // TODO Colour, also maybe remove all those "magic" numbers
  S := IntToStr(_Board[Y][X]);
  if (S = '0') then
  begin
    S := '    ';
  end;
  DoorGotoXY(27 + ((X - 1) * 7) + ((4 - Length(S)) div 2), 5 + ((Y - 1) * 4));
  DoorWrite(S);
end;

procedure DrawTiles;
var
  X, Y: Integer;
begin
  for Y := 1 to 4 do
  begin
    for X := 1 to 4 do
    begin
      if (_Board[Y][X] > 0) then
      begin
        DrawTile(X, Y);
      end;
    end;
  end;
end;

function HandleDown: Boolean;

  function Combine: Boolean;
  var
    X, Y: Integer;
  begin
    Result := false;

    for X := 1 to 4 do
    begin
      for Y := 4 downto 2 do
      begin
        if (_Board[Y][X] > 0) then
        begin
          if (_Board[Y][X] = _Board[Y - 1][X]) then
          begin
            _Board[Y][X] := _Board[Y][X] * 2;
            _Board[Y - 1][X] := 0;

            DrawTile(X, Y);
            DrawTile(X, Y - 1);

            _PointsToAdd := _Board[Y][X];

            Result := true;

            break;
          end;
        end;
      end;
    end;
  end;

  function Move: Boolean;
  var
    X, Y, Y2: Integer;
  begin
    Result := false;

    for X := 1 to 4 do
    begin
      for Y := 4 downto 2 do
      begin
        if (_Board[Y][X] = 0) then
        begin
          for Y2 := Y - 1 downto 1 do
          begin
            if (_Board[Y2][X] > 0) then
            begin
              _Board[Y][X] := _Board[Y2][X];
              _Board[Y2][X] := 0;

              DrawTile(X, Y);
              DrawTile(X, Y2);

              Result := true;

              break;
            end;
          end;
        end;
      end;
    end;
  end;

begin
  Result := Move;
  if (Combine) then
  begin
    Move;
    Result := true;
  end;
end;

procedure HandleHelp;
begin
  // TODO
end;

function HandleLeft: Boolean;

  function Combine: Boolean;
  var
    X, Y: Integer;
  begin
    Result := false;

    for Y := 1 to 4 do
    begin
      for X := 1 to 3 do
      begin
        if (_Board[Y][X] > 0) then
        begin
          if (_Board[Y][X] = _Board[Y][X + 1]) then
          begin
            _Board[Y][X] := _Board[Y][X] * 2;
            _Board[Y][X + 1] := 0;

            DrawTile(X, Y);
            DrawTile(X + 1, Y);

            _PointsToAdd := _Board[Y][X];

            Result := true;

            break;
          end;
        end;
      end;
    end;
  end;

  function Move: Boolean;
  var
    X, X2, Y: Integer;
  begin
    Result := false;

    for Y := 1 to 4 do
    begin
      for X := 1 to 3 do
      begin
        if (_Board[Y][X] = 0) then
        begin
          for X2 := X + 1 to 4 do
          begin
            if (_Board[Y][X2] > 0) then
            begin
              _Board[Y][X] := _Board[Y][X2];
              _Board[Y][X2] := 0;

              DrawTile(X, Y);
              DrawTile(X2, Y);

              Result := true;

              break;
            end;
          end;
        end;
      end;
    end;
  end;

begin
  Result := Move;
  if (Combine) then
  begin
    Move;
    Result := true;
  end;
end;

function HandleRight: Boolean;

  function Combine: Boolean;
  var
    X, Y: Integer;
  begin
    Result := false;

    for Y := 1 to 4 do
    begin
      for X := 4 downto 2 do
      begin
        if (_Board[Y][X] > 0) then
        begin
          if (_Board[Y][X] = _Board[Y][X - 1]) then
          begin
            _Board[Y][X] := _Board[Y][X] * 2;
            _Board[Y][X - 1] := 0;

            DrawTile(X, Y);
            DrawTile(X - 1, Y);

            _PointsToAdd := _Board[Y][X];

            Result := true;

            break;
          end;
        end;
      end;
    end;
  end;

  function Move: Boolean;
  var
    X, X2, Y: Integer;
  begin
    Result := false;

    for Y := 1 to 4 do
    begin
      for X := 4 downto 2 do
      begin
        if (_Board[Y][X] = 0) then
        begin
          for X2 := X - 1 downto 1 do
          begin
            if (_Board[Y][X2] > 0) then
            begin
              _Board[Y][X] := _Board[Y][X2];
              _Board[Y][X2] := 0;

              DrawTile(X, Y);
              DrawTile(X2, Y);

              Result := true;

              break;
            end;
          end;
        end;
      end;
    end;
  end;

begin
  Result := Move;
  if (Combine) then
  begin
    Move;
    Result := true;
  end;
end;

function HandleUp: Boolean;

function Combine: Boolean;
  var
    X, Y: Integer;
  begin
    Result := false;

    for X := 1 to 4 do
    begin
      for Y := 1 to 3 do
      begin
        if (_Board[Y][X] > 0) then
        begin
          if (_Board[Y][X] = _Board[Y + 1][X]) then
          begin
            _Board[Y][X] := _Board[Y][X] * 2;
            _Board[Y + 1][X] := 0;

            DrawTile(X, Y);
            DrawTile(X, Y + 1);

            _PointsToAdd := _Board[Y][X];

            Result := true;

            break;
          end;
        end;
      end;
    end;
  end;

  function Move: Boolean;
  var
    X, Y, Y2: Integer;
  begin
    Result := false;

    for X := 1 to 4 do
    begin
      for Y := 1 to 3 do
      begin
        if (_Board[Y][X] = 0) then
        begin
          for Y2 := Y + 1 to 4 do
          begin
            if (_Board[Y2][X] > 0) then
            begin
              _Board[Y][X] := _Board[Y2][X];
              _Board[Y2][X] := 0;

              DrawTile(X, Y);
              DrawTile(X, Y2);

              Result := true;

              break;
            end;
          end;
        end;
      end;
    end;
  end;

begin
  Result := Move;
  if (Combine) then
  begin
    Move;
    Result := true;
  end;
end;

procedure NewGame;
var
  X, Y: Integer;
begin
  // Reset score
  _PointsToAdd := 0;
  _Score := 0;

  // Reset board and add start tiles
  for Y := 1 to 4 do
  begin
    for X := 1 to 4 do
    begin
      _Board[Y][X] := 0;
    end;
  end;
  AddTile;
  AddTile;

  // Draw screen
  DrawScreen;
end;

procedure Start;
var
  Ch: Char;
  Moved: Boolean;
begin
  NewGame;

  Ch := #0;
  repeat
    Moved := false;
    DoorGotoXY(1, 1);

    Ch := UpCase(DoorReadKey);
    case Ch of
      'W', 'I', '8':
        Moved := HandleUp;
      'A', 'J', '4':
        Moved := HandleLeft;
      'S', 'K', '2':
        Moved := HandleDown;
      'D', 'L', '6':
        Moved := HandleRight;
      'H', '?':
        HandleHelp;
    end;

    if (Moved) then
    begin
      // TODO Check for won/loss
      DrawScore;
      AddTile;
    end;
  until Ch = 'Q';
end;

end.

