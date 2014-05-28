unit game;

{$mode objfpc}{$H+}

interface

procedure Start;

implementation

uses
  Door, StringUtils,
  Classes, Crt, StrUtils, SysUtils;

const
  BOARD_X: Integer = 25;
  BOARD_Y: Integer = 3;

type
  TDirection = (dirDown, dirLeft, dirRight, dirUp);

var
  _AnsiGameBoard: String;
  _AnsiNewTile: Array[1..4] of String;
  _AnsiTile: Array[0..12] of String;
  _Board: Array[1..4, 1..4] of Integer;
  _PointsToAdd: Integer;
  _Score: Integer;

procedure DrawTile(X, Y: Integer); forward;
procedure DrawTiles; forward;

procedure AddTile;
var
  Line: Integer;
  R: Integer;
  Tile: Integer;
  X, Y: Integer;
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

  // animate "creation" of new tile
  for Tile := 1 to 4 do
  begin
    DoorGotoXY((X - 1) * 19 + 4, (Y - 1) * 6 + 1);
    DoorWrite(_AnsiNewTile[Tile]);
    Delay(100);
  end;

  // Draw the actual tile
  DrawTile(X, Y);
end;

procedure DrawBoard;
begin
  DoorTextBackground(Crt.Blue);
  DoorClrScr;
  DoorWrite(_AnsiGameBoard);
end;

procedure DrawScore;
begin
  if (_PointsToAdd > 0) then
  begin
    _Score += _PointsToAdd;
  end;

  DoorGotoXY(2, 24);
  DoorWrite('|1FScore: ');
  DoorWrite('|1E' + IntToStr(_Score));

  if (_PointsToAdd > 0) then
  begin
    DoorWrite(' |1A' + AddCharR(' ', '+' + IntToStr(_PointsToAdd), 6));
    _PointsToAdd := 0;
  end else
  begin
    DoorWrite(StringOfChar(' ', 6));
  end;
end;

procedure DrawScreen;
begin
  DrawBoard;
  DrawTiles;
  DrawScore;
end;

procedure DrawTile(X, Y: Integer);
var
  Line: Integer;
  Tile: Integer;
begin
  case _Board[Y][X] of
    0: Tile := 0;
    1: Tile := 1;
    2: Tile := 2;
    4: Tile := 3;
    8: Tile := 4;
    16: Tile := 5;
    32: Tile := 6;
    64: Tile := 7;
    128: Tile := 8;
    256: Tile := 9;
    512: Tile := 10;
    1024: Tile := 11;
    2048: Tile := 12;
  end;

  DoorGotoXY((X - 1) * 19 + 4, (Y - 1) * 6 + 1);
  DoorWrite(_AnsiTile[Tile]);
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

procedure Init;
begin
  _AnsiGameBoard := Base64Decode('G1swbRtbNDQ7MzBtICAg3Nvf39/f39/f39/f39/f29wbWzE7MzdtICAbWzA7NDQ7MzBt3Nvf39/f39/f39/f39/f29wbWzE7MzdtICAbWzA7NDQ7MzBt3Nvf39/f39/f39/f39/f29wbWzE7MzdtICAbWzA7NDQ7MzBt3Nvf39/f39/f39/f39/f29wbWzE7MzdtIBtbMDs0NDszMG0gG1sxOzM3bSAbWzA7NDQ7MzBtIBtbMTszN20gG1swOzQ0OzMwbSDbICAgICAgICAgICAgICAg2xtbMTszN20gIBtbMDs0NDszMG3bICAgICAgICAgICAgICAg2xtbMTszN20gIBtbMDs0NDszMG3bICAgICAgICAgICAgICAg2xtbMTszN20gIBtbMDs0NDszMG3bICAgICAgICAgICAgICAg2xtbMTszN20gG1swOzQ0OzMwbSAbWzE7MzdtIBtbMDs0NDszMG0gG1sxOzM3bSAbWzA7NDQ7MzBtINsgICAgICAgICAgICAgICDbG1sxOzM3bSAgG1swOzQ0OzMwbdsgICAgICAgICAgICAgICDbG1sxOzM3bSAgG1swOzQ0OzMwbdsgICAgICAgICAgICAgICDbG1sxOzM3bSAgG1swOzQ0OzMwbdsgICAgICAgICAgICAgICDbG1sxOzM3bSAbWzA7NDQ7MzBtIBtbMTszN20gG1swOzQ0OzMwbSAbWzE7MzdtIBtbMDs0NDszMG0g2yAgICAgICAgICAgICAgINsbWzE7MzdtICAbWzA7NDQ7MzBt2yAgICAgICAgICAgICAgINsbWzE7MzdtICAbWzA7NDQ7MzBt2yAgICAgICAgICAgICAgINsbWzE7MzdtICAbWzA7NDQ7MzBt2yAgICAgICAgICAgICAgINsbWzE7MzdtIBtbMDs0NDszMG0gG1sxOzM3bSAbWzA7NDQ7MzBtIBtbMTszN20gG1swOzQ0OzMwbSDf29zc3Nzc3Nzc3Nzc3Nzb3xtbMTszN20gIBtbMDs0NDszMG3f29zc3Nzc3Nzc3Nzc3Nzb3xtbMTszN20gIBtbMDs0NDszMG3f29zc3Nzc3Nzc3Nzc3Nzb3xtbMTszN20gIBtbMDs0NDszMG3f29zc3Nzc3Nzc3Nzc3Nzb3xtbMTszN20gG1swOzQ0OzMwbSAbWzE7MzdtIBtbMDs0NDszMG0gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgINzb39/f39/f39/f39/f39vcICDc29/f39/f39/f39/f39/b3CAg3Nvf39/f39/f39/f39/f29wgINzb39/f39/f39/f39/f39vcICAgICAg2yAgICAgICAgICAgICAgINsgINsgICAgICAgICAgICAgICDbICDbICAgICAgICAgICAgICAg2yAg2yAgICAgICAgICAgICAgINsgICAgICDbICAgICAgICAgICAgICAg2yAg2yAgICAgICAgICAgICAgINsgINsgICAgICAgICAgICAgICDbICDbICAgICAgICAgICAgICAg2yAgICAgINsgICAgICAgICAgICAgICDbICDbICAgICAgICAgICAgICAg2yAg2yAgICAgICAgICAgICAgINsgINsgICAgICAgICAgICAgICDbICAgICAg39vc3Nzc3Nzc3Nzc3Nzc298gIN/b3Nzc3Nzc3Nzc3Nzc3NvfICDf29zc3Nzc3Nzc3Nzc3Nzb3yAg39vc3Nzc3Nzc3Nzc3Nzc298gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgINzb39/f39/f39/f39/f39vcICDc29/f39/f39/f39/f39/b3CAg3Nvf39/f39/f39/f39/f29wgINzb39/f39/f39/f39/f39vcICAgICAg2yAgICAgICAgICAgICAgINsgINsgICAgICAgICAgICAgICDbICDbICAgICAgICAgICAgICAg2yAg2yAgICAgICAgICAgICAgINsgICAgICDbICAgICAgICAgICAgICAg2yAg2yAgICAgICAgICAgICAgINsgINsgICAgICAgICAgICAgICDbICDbICAgICAgICAgICAgICAg2yAgICAgINsgICAgICAgICAgICAgICDbICDbICAgICAgICAgICAgICAg2yAg2yAgICAgICAgICAgICAgINsgINsgICAgICAgICAgICAgICDbICAgICAg39vc3Nzc3Nzc3Nzc3Nzc298gIN/b3Nzc3Nzc3Nzc3Nzc3NvfICDf29zc3Nzc3Nzc3Nzc3Nzb3yAg39vc3Nzc3Nzc3Nzc3Nzc298gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgINzb39/f39/f39/f39/f39vcICDc29/f39/f39/f39/f39/b3CAg3Nvf39/f39/f39/f39/f29wgINzb39/f39/f39/f39/f39vcICAgICAg2yAgICAgICAgICAgICAgINsgINsgICAgICAgICAgICAgICDbICDbICAgICAgICAgICAgICAg2yAg2yAgICAgICAgICAgICAgINsgICAgICDbICAgICAgICAgICAgICAg2yAg2yAgICAgICAgICAgICAgINsgINsgICAgICAgICAgICAgICDbICDbICAgICAgICAgICAgICAg2yAgICAgINsgICAgICAgICAgICAgICDbICDbICAgICAgICAgICAgICAg2yAg2yAgICAgICAgICAgICAgINsgINsgICAgICAgICAgICAgICDbICAgICAg39vc3Nzc3Nzc3Nzc3Nzc298gIN/b3Nzc3Nzc3Nzc3Nzc3NvfICDf29zc3Nzc3Nzc3Nzc3Nzb3yAg39vc3Nzc3Nzc3Nzc3Nzc298gICA=');
  _AnsiNewTile[1] := Base64Decode('G1tzG1swbRtbNDQ7MzBt3Nvf39/f39/f39/f39/f29wbWzBtDQobW3UbW0IbWzQ0OzMwbdsgICAgICAgICAgICAgICDbG1swbQ0KG1t1G1syQhtbNDQ7MzBt2yAgICAgIBtbMTs0MG2xsbEbWzA7NDQ7MzBtICAgICAg2xtbMG0NChtbdRtbM0IbWzQ0OzMwbdsgICAgICAgICAgICAgICDbG1swbQ0KG1t1G1s0QhtbNDQ7MzBt39vc3Nzc3Nzc3Nzc3Nzc298bWzBtDQo=');
  _AnsiNewTile[2] := Base64Decode('G1tzG1swbRtbNDQ7MzBt3Nvf39/f39/f39/f39/f29wbWzBtDQobW3UbW0IbWzQ0OzMwbdsgICAgIBtbMTs0MG2ysrKyshtbMDs0NDszMG0gICAgINsbWzBtDQobW3UbWzJCG1s0NDszMG3bICAgICAbWzE7NDBtsrKysrIbWzA7NDQ7MzBtICAgICDbG1swbQ0KG1t1G1szQhtbNDQ7MzBt2yAgICAgICAgICAgICAgINsbWzBtDQobW3UbWzRCG1s0NDszMG3f29zc3Nzc3Nzc3Nzc3Nzb3xtbMG0NCg==');
  _AnsiNewTile[3] := Base64Decode('G1tzG1swbRtbNDQ7MzBt3Nvf39/f39/f39/f39/f29wbWzBtDQobW3UbW0IbWzQ0OzMwbdsgIBtbMTs0N22xsbGxsbGxsbGxsRtbMDs0NDszMG0gINsbWzBtDQobW3UbWzJCG1s0NDszMG3bICAbWzE7NDdtsbGxsbGxsbGxsbEbWzA7NDQ7MzBtICDbG1swbQ0KG1t1G1szQhtbNDQ7MzBt2yAgG1sxOzQ3bbGxsbGxsbGxsbGxG1swOzQ0OzMwbSAg2xtbMG0NChtbdRtbNEIbWzQ0OzMwbd/b3Nzc3Nzc3Nzc3Nzc3NvfG1swbQ0K');
  _AnsiNewTile[4] := Base64Decode('G1tzG1swbRtbMTs0NzszMG0gICAgICAgICAgICAgICAgIBtbMG0NChtbdRtbQhtbMTs0NzszMG0gICAgICAgICAgICAgICAgIBtbMG0NChtbdRtbMkIbWzE7NDc7MzBtICAgICAgICAgICAgICAgICAbWzBtDQobW3UbWzNCG1sxOzQ3OzMwbSAgICAgICAgICAgICAgICAgG1swbQ0KG1t1G1s0QhtbMTs0NzszMG3c3Nzc3Nzc3Nzc3Nzc3Nzc3BtbMG0NCg==');
  _AnsiTile[0] := Base64Decode('G1tzG1s0NDszMG3c29/f39/f39/f39/f39/b3A0KG1t1G1tC2yAgICAgICAgICAgICAgINsNChtbdRtbMkLbICAgICAgICAgICAgICAg2w0KG1t1G1szQtsgICAgICAgICAgICAgICDbDQobW3UbWzRC39vc3Nzc3Nzc3Nzc3Nzc298bWzBtDQo=');
  _AnsiTile[1] := Base64Decode('G1tzG1swbRtbMW3b29vb29vb39/b29vb29vb2w0KG1t1G1tC29vb29vb29sg29vb29vb29sNChtbdRtbMkLb29vb29vb2yDb29vb29vb2w0KG1t1G1szQtvb29vb29vfIN/b29vb29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[2] := Base64Decode('G1tzG1swbRtbMW3b29vb29vb39/b29vb29vb2w0KG1t1G1tC29vb29vb29vbINvb29vb29sNChtbdRtbMkLb29vb29vb39zb29vb29vb2w0KG1t1G1szQtvb29vb29vc39/b29vb29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[3] := Base64Decode('G1tzG1swbRtbMW3b29vb29vb39vb29vb29vb2w0KG1t1G1tC29vb29vb2yDbINvb29vb29sNChtbdRtbMkLb29vb29vb3Nwg29vb29vb2w0KG1t1G1szQtvb29vb29vb2yDb29vb29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[4] := Base64Decode('G1tzG1swbRtbMW3b29vb29vb39/b29vb29vb2w0KG1t1G1tC29vb29vb2yDbINvb29vb29sNChtbdRtbMkLb29vb29vb39zf29vb29vb2w0KG1t1G1szQtvb29vb29vc3yDb29vb29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[5] := Base64Decode('G1tzG1swbRtbMW3b29vb29/f29vb39/b29vb2w0KG1t1G1tC29vb29vbINvbINvc29vb29sNChtbdRtbMkLb29vb29sg29sg3N/b29vb2w0KG1t1G1szQtvb29vb3yDf29zf3Nvb29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[6] := Base64Decode('G1tzG1swbRtbMW3b29vb29/f29vf39vb29vb2w0KG1t1G1tC29vb29vb2yDb29sg29vb29sNChtbdRtbMkLb29vb29vc39vf3Nvb29vb2w0KG1t1G1szQtvb29vb39/c29zf39vb29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[7] := Base64Decode('G1tzG1swbRtbMW3b29vb29vf39vf29vb29vb2w0KG1t1G1tC29vb29sg29zbINsg29vb29sNChtbdRtbMkLb29vb2yDc39vc3CDb29vb2w0KG1t1G1szQtvb29vb3N/c29vbINvb29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[8] := Base64Decode('G1tzG1swbRtbMW3b29vf39vb39/b29/f29vb2w0KG1t1G1tC29vb2yDb29vbINsg2yDb29sNChtbdRtbMkLb29vbINvb39zb29/c39vb2w0KG1t1G1szQtvb298g39vc39/b3N8g29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[9] := Base64Decode('G1tzG1swbRtbMW3b29vf39vb39/b29vf39vb2w0KG1t1G1tC29vb29sg2yDb29sg29zb29sNChtbdRtbMkLb29vf3Nvb29zf2yDc39vb2w0KG1t1G1szQtvb29zf39vf39zb3N/c29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[10] := Base64Decode('G1tzG1swbRtbMW3b29vf39vb39/b29/f29vb2w0KG1t1G1tC29vbINvb29sg29vb2yDb29sNChtbdRtbMkLb29vb3N/b2yDb29/c29vb2w0KG1t1G1szQtvb29/f3NvfIN/b3N/f29vbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[11] := Base64Decode('G1tzG1swbRtbMW3b39/b29vf39vf39vb39vb2w0KG1t1G1tC29sg29sg2yDb29sg2yDbINsNChtbdRtbMkLb2yDb2yDbINvf3Nvb3Nwg2w0KG1t1G1szQtvfIN/bIN/c29zf39vb2yDbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
  _AnsiTile[12] := Base64Decode('G1tzG1swbRtbMW3b39/b29vf39vf29vb39/b2w0KG1t1G1tC29vbINsg2yDbINsg2yDbINsNChtbdRtbMkLb39zb2yDbINvc3CDb39zf2w0KG1t1G1szQtvc39/bIN/c29vbINvc3yDbDQobW3UbWzRCG1s0N23f39/f39/f39/f39/f39/f3xtbMG0=');
end;

procedure NewGame;
var
  X, Y: Integer;
begin
  // Reset score
  _PointsToAdd := 0;
  _Score := 0;

  // Reset board
  for Y := 1 to 4 do
  begin
    for X := 1 to 4 do
    begin
      _Board[Y][X] := 0;
    end;
  end;

  // Draw screen
  DrawScreen;

  // Add initial tiles
  AddTile;
  AddTile;
end;

procedure Start;
var
  Ch: Char;
  Moved: Boolean;
begin
  Init;
  NewGame;

  Ch := #0;
  repeat
    Moved := false;

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

