unit game;

{$mode objfpc}{$H+}

interface

procedure Start;

implementation

uses
  Door,
  StrUtils, SysUtils;

const
  BOARD_X: Integer = 25;
  BOARD_Y: Integer = 3;

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

  DoorGotoXY(BOARD_X, BOARD_Y + 0);  DoorWrite('|07' + TopLeft + RowLine + #194 + RowLine + #194 + RowLine + #194 + RowLine + TopRight);
  DoorGotoXY(BOARD_X, BOARD_Y + 1);  DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 2);  DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 3);  DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 4);  DoorWrite('|07' + LineLeft + RowLine + #197 + RowLine + #197 + RowLine + #197 + RowLine + LineRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 5);  DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 6);  DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 7);  DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 8);  DoorWrite('|07' + LineLeft + RowLine + #197 + RowLine + #197 + RowLine + #197 + RowLine + LineRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 9);  DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 10); DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 11); DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 12); DoorWrite('|07' + LineLeft + RowLine + #197 + RowLine + #197 + RowLine + #197 + RowLine + LineRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 13); DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 14); DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 15); DoorWrite('|07' + TileLeft + RowTile + TileRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 16); DoorWrite('|07' + BottomLeft + RowLine + #193 + RowLine + #193 + RowLine + #193 + RowLine + BottomRight + '|08' + Shadow);
  DoorGotoXY(BOARD_X, BOARD_Y + 17); DoorWrite(' |08' + StringOfChar(Shadow,  29) + '|07');
end;

procedure DrawScore;
begin
  if (_PointsToAdd > 0) then
  begin
    DoorGotoXY(2, 5);
    DoorWrite('|0A' + AddChar(' ', '+' + IntToStr(_PointsToAdd), 6));

    _Score += _PointsToAdd;
    _PointsToAdd := 0;
  end else
  begin
    DoorGotoXY(2, 5);
    DoorWrite(StringOfChar(' ', 6));
  end;

  DoorGotoXY(2, 2); DoorWrite('|0FScore:');
  DoorGotoXY(2, 3); DoorWrite('|08' + StringOfChar(#196, 6));
  DoorGotoXY(2, 4); DoorWrite('|0F' + AddChar(' ', IntToStr(_Score), 6) + '|07');
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
  S := IntToStr(_Board[Y][X]);
  if (S = '0') then
  begin
    S := '    ';
  end;
  DoorGotoXY((BOARD_X + 2) + ((X - 1) * 7) + ((4 - Length(S)) div 2), (BOARD_Y + 2) + ((Y - 1) * 4));
  DoorWrite('|0F' + S + '|07');
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

            _PointsToAdd += _Board[Y][X];

            Result := true;
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
  _PointsToAdd := 0;

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

            _PointsToAdd += _Board[Y][X];

            Result := true;
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
  _PointsToAdd := 0;

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

            _PointsToAdd += _Board[Y][X];

            Result := true;
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
  _PointsToAdd := 0;

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

            _PointsToAdd += _Board[Y][X];

            Result := true;
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
  _PointsToAdd := 0;

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

