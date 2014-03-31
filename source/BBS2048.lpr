program BBS2048;

{$mode objfpc}{$h+}

uses
  Game,
  Door,
  SysUtils;

begin
  { add your program here }
  try
    try
      Randomize;
      DoorStartUp;
      Game.Start;
    except
      on E: Exception do
      begin
        // TODO Log to file as well as to screen that an abnormal exit occurred
        DoorClrScr;
        DoorWriteLn;
        DoorWriteLn('Unhandled exception:');
        DoorWriteLn;
        DoorWriteLn(E.ToString);
        DoorWriteLn;
        DoorWrite('Hit a key to quit');
        DoorReadKey;
      end;
    end;
  finally
    DoorShutDown;
  end;
end.

