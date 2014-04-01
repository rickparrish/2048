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

type
  TDirection = (dirDown, dirLeft, dirRight, dirUp);

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

function HandleDownOrUp(Direction: TDirection): Boolean;

  function Combine(YStart, YEnd, YOffset: Integer): Integer;
  var
    X, Y: Integer;
  begin
    Result := 0;

    for X := 1 to 4 do
    begin
      Y := YStart + (YOffset * -1); // Init to 1 off our start since we'll add the offset right away
      repeat
        Y += YOffset;

        if (_Board[Y][X] > 0) then
        begin
          if (_Board[Y][X] = _Board[Y + YOffset][X]) then
          begin
            _Board[Y][X] := _Board[Y][X] * 2;
            _Board[Y + YOffset][X] := 0;

            DrawTile(X, Y);
            DrawTile(X, Y + YOffset);

            Result += _Board[Y][X];
          end;
        end;
      until (Y = YEnd);
    end;
  end;

  function Move(YStart, YEnd, YOffset: Integer): Boolean;
  var
    X, Y, Y2: Integer;
  begin
    Result := false;

    for X := 1 to 4 do
    begin
      Y := YStart + (YOffset * -1); // Init to 1 off our start since we'll add the offset right away
      repeat
        Y += YOffset;

        // Look for open spaces
        if (_Board[Y][X] = 0) then
        begin
          Y2 := Y; // Init to Y since we'll add the offset right away

          repeat
            Y2 += YOffset;

            // Look for a tile to move into the open space
            if (_Board[Y2][X] > 0) then
            begin
              _Board[Y][X] := _Board[Y2][X];
              _Board[Y2][X] := 0;

              DrawTile(X, Y);
              DrawTile(X, Y2);

              Result := true;

              break;
            end;
          until (Y2 = (YEnd + YOffset));
        end;
      until (Y = YEnd);
    end;
  end;

var
  YEnd: Integer;
  YOffset: Integer;
  YStart: Integer;
begin
  if (Direction = dirDown) then
  begin
    YEnd := 2;
    YOffset := -1;
    YStart := 4;
  end else
  if (Direction = dirUp) then
  begin
    YEnd := 3;
    YOffset := +1;
    YStart := 1;
  end;

  Result := Move(YStart, YEnd, YOffset);
  _PointsToAdd := Combine(YStart, YEnd, YOffset);
  if (_PointsToAdd > 0) then
  begin
    Move(YStart, YEnd, YOffset);
    Result := true;
  end;
end;

procedure HandleHelp;
begin
  // TODO
end;

function HandleLeftOrRight(Direction: TDirection): Boolean;

  function Combine(XStart, XEnd, XOffset: Integer): Integer;
  var
    X, Y: Integer;
  begin
    Result := 0;

    for Y := 1 to 4 do
    begin
      X := XStart + (XOffset * -1); // Init to 1 off our start since we'll add the offset right away
      repeat
        X += XOffset;

        if (_Board[Y][X] > 0) then
        begin
          if (_Board[Y][X] = _Board[Y][X + XOffset]) then
          begin
            _Board[Y][X] := _Board[Y][X] * 2;
            _Board[Y][X + XOffset] := 0;

            DrawTile(X, Y);
            DrawTile(X + XOffset, Y);

            Result += _Board[Y][X];
          end;
        end;
      until (X = XEnd);
    end;
  end;

  function Move(XStart, XEnd, XOffset: Integer): Boolean;
  var
    X, X2, Y: Integer;
  begin
    Result := false;

    for Y := 1 to 4 do
    begin
      X := XStart + (XOffset * -1); // Init to 1 off our start since we'll add the offset right away
      repeat
        X += XOffset;

        // Look for open spaces
        if (_Board[Y][X] = 0) then
        begin
          X2 := X; // Init to X since we'll add the offset right away

          repeat
            X2 += XOffset;

            // Look for a tile to move into the open space
            if (_Board[Y][X2] > 0) then
            begin
              _Board[Y][X] := _Board[Y][X2];
              _Board[Y][X2] := 0;

              DrawTile(X, Y);
              DrawTile(X2, Y);

              Result := true;

              break;
            end;
          until (X2 = (XEnd + XOffset));
        end;
      until (X = XEnd);
    end;
  end;

var
  XEnd: Integer;
  XOffset: Integer;
  XStart: Integer;
begin
  if (Direction = dirLeft) then
  begin
    XEnd := 3;
    XOffset := +1;
    XStart := 1;
  end else
  if (Direction = dirRight) then
  begin
    XEnd := 2;
    XOffset := -1;
    XStart := 4;
  end;

  Result := Move(XStart, XEnd, XOffset);
  _PointsToAdd := Combine(XStart, XEnd, XOffset);
  if (_PointsToAdd > 0) then
  begin
    Move(XStart, XEnd, XOffset);
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

    // TODO Handle arrow keys (RMDoor)
    Ch := UpCase(DoorReadKey);
    case Ch of
      'W', 'I', '8':
        Moved := HandleDownOrUp(dirUp);
      'A', 'J', '4':
        Moved := HandleLeftOrRight(dirLeft);
      'S', 'K', '2':
        Moved := HandleDownOrUp(dirDown);
      'D', 'L', '6':
        Moved := HandleLeftOrRight(dirRight);
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

