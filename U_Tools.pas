unit U_Tools;

interface

uses SysUtils, ShlObj, Windows, classes,ShellAPI;

// Wandelt einen maximal 8 Zeichen langen Hex-Wert in einen Integer-Wert um z.B. 6E -->  110
function HexToInt(Value: String):Double;

// Wandelt einen Integer-Wert in eine HexZahl um z.B. 110 --> 6E
function IntToHexB(Value: integer) : string;

// Liefert ein bestimmtes Byte von einem Integer-Wert z.B. Value 32568; Nr 2 --> 127
// Nr:=1: 1..255  * 1 (2^0)  / Nr:=2: 1..255 *256 (2^8)/ Nr:=3: 1..255 * 65536 (2^16)/ Nr:=4: 1..255 * 16777216 (2^24)
function GetByteFromInt(Value: Integer; Nr: Word): byte;

// wandelt einen Integer-Wert in eine Bitfolge um z.B. 2 --> 0010
function Int2Bit(Int: Integer): String;

// wandelt einen Word-Wert in eine Bitfolge um z.B. 2 --> 0010
function Word2Bit(Int: Word): String;

// gibt True zurück wenn in der Zahl 'Value' das Bit 'BitNr' vorhanden ist, ansonsten False
// Beispiel IsBitTrue(34, 2) --> True; (34 ist binär 100010)
function IsBitTrue(Value, BitNr: Integer): Boolean;



(* ------------------ String-Operationen --------------------------- *)

// Sucht vorwärts nach der Position des Teilstrings SubStr im String S zurück sucht ab der Stelle Index
function PosMidStr(SubStr, S: String; Index: Integer): Integer;
// Sucht rückwärts nach der Position des Teilstrings SubStr im String S zurück sucht ab der Stelle Index
function PosMidStrB(SubStr, S: String; Index: Integer): Integer;

// Ermittelt wie oft der Teilstring SubStr im String S vorkommt
function CountStr(SubStr, S: String): Integer;

// Ersetzt den Teilstring OldStr im String S durch den Teilstring NewStr
function ReplaceStr(OldStr, NewStr, S: String): String;
// Ersetzt den Teilstring OldStr im String S durch den Teilstring NewStr ohne Beachtung der Groß-/Kleinschreibung
function ReplaceStrUp(OldStr, NewStr, S: String): String;

function RPos(ss,s:string):integer;

function strtofloatdef(S: String): real;

function timestrtoint(S: String): integer;   // z.B. '01:00:00' -> 3600
function inttotimestr(S: integer): string;   // z.B. 3600-> '01:00:00'

function GetWindowsVersion:string;
function IsWindowsNT:boolean;
function WindowsDirectory:string;
function SystemDirectory:string;

function UserName:string;
function AddBackSlash(PathName:string):string;

//function strtottstrings(separator:char;s:string;strlst:tstrings):integer;
function strtottstrings(separator:char;s:string):tstrings;

(* ------------------ Datei-Funktionen --------------------------- *)
// Liefert über SHBrowseForFolder (Dateiauswahlfenster) das ausgewählte Verzeichnis zurück
function BrowseDirectory(Title: String): String;

function GetFileTypeName(AFileName:String):string;
function GetFileDisplayName(AFileName:String):string;

procedure FileOperation (const source, dest: string; op, flags: Integer);
//var shf: TSHFileOpStruct;

function DateiGroesse(FileName: string): integer;

implementation

(* --------------------- Interne Functionen/Prozeduren ----------------- *)

const max_Int_Bits = 30;   // maximale Bitanzahl - 1
      max_Word_Bits = 15;  // maximale Bitanzahl - 1

var PotAry: array[0..max_Int_Bits] of Integer;  // Array der 2-er Potzenen von 2 hoch 0 (= 1) bis 2 hoch 31 (= 2147483647)
  StrList: TStrings;


Procedure Init;
var i:Integer;
begin
  for i:=0 to max_Int_Bits do
    PotAry[i]:=round(Exp(i * ln(2)));
  StrList := TStringList.Create;
end;

Procedure reInit;
begin
  StrList.free;
end;


(* ------------- Veröffentlichte Functionen/Prozeduren ----------------- *)
function HexToInt(Value: String):Double;
const Hex = '0123456789ABCDEF';         // Hex
var i, l, p: integer;
    j: Double;
begin
  result:=0;
  l:=length(Value);
  
  for i:=l downto 1 do
  begin
    p:=Pos(Value[i], Hex);
    if p > 0 then 
    begin
      j:=l-i;   
      result:=result + (p - 1) * (Exp(j * ln(16)));
    end    
    else
    begin
      Result:=-1;
      break;     
    end;
  end;
  
end;


function IntToHexB(Value : integer) : string;
type
  THexSplit = record
    LoLo : BYTE;    (* 1. 8 Bit *)
    LoHi : BYTE;    (* 2. 8 Bit *)
    HiLo : BYTE;    (* 3. 8 Bit *)
    HiHi : BYTE;    (* 4. 8 Bit *)
  end;
var
  h : PAnsiChar;
  v : THexSplit absolute Value;          (* direkte Zuweisung *)
  s : string[8];                   
begin
  h    := '0123456789ABCDEF';         (* Hex *)
  s    := 'xxxxxxxx';
  s[1] := h[v.HiHi div $10];     (* 1. Stelle *)
  s[2] := h[v.HiHi mod $10];     (* 2. Stelle *)
  s[3] := h[v.HiLo div $10];     (* 3. Stelle *)
  s[4] := h[v.HiLo mod $10];     (* 4. Stelle *)
  s[5] := h[v.LoHi div $10];     (* 5. Stelle *)
  s[6] := h[v.LoHi mod $10];     (* 6. Stelle *)
  s[7] := h[v.LoLo div $10];     (* 7. Stelle *)
  s[8] := h[v.LoLo mod $10];     (* 8. Stelle *)
  result := s;
end;


function GetByteFromInt(Value: Integer; Nr: Word): byte;
type
  TByteSplit = record
    LoLo : BYTE;    (* 1. 8 Bit *)
    LoHi : BYTE;    (* 2. 8 Bit *)
    HiLo : BYTE;    (* 3. 8 Bit *)
    HiHi : BYTE;    (* 4. 8 Bit *)
  end;
var B: TByteSplit absolute value;
begin
  result:=0;
  if (nr < 1) or (nr > 4) then nr:=1;
  case nr of
    1: result:=B.LoLo;
    2: result:=B.LoHi;
    3: result:=B.HiLo;
    4: result:=B.HiHi;
  end; 
end;    

function Int2Bit(Int: Integer): String;
var i, a:Integer;
    s:string;
begin
  a:=Abs(Int);  //positive und negative Zahlen werden gleich behandelt da das 32. Bit das Vorzeichen darstellt
  s:='';
  for i:=max_Int_Bits downto 0 do
    if (a and (PotAry[i]) = PotAry[i]) then s:=s+'1' else s:=s+ '0';

  Result:=s;
end;


function Word2Bit(Int: Word): String;
var i, a:Integer;
    s:string;
begin
  a:=Abs(Int);
  s:='';
  for i:=max_Word_Bits downto 0 do
    if (a and (PotAry[i]) = PotAry[i]) then s:=s+'1' else s:=s+ '0';

  Result:=s;
end;


function IsBitTrue(Value, BitNr: Integer): Boolean;
begin
  if (Value and (PotAry[BitNr]) = PotAry[BitNr]) then Result:= True else Result:=False;
end;


function PosMidStr(SubStr, S: String; Index: Integer): Integer;
var x, y: String;
    i:Integer;
begin
  y:=S;
  if pos(SubStr, y) > 0 then
  begin
    x:=copy(y, 1, Index-1);
    Delete(y, 1, Index-1);
    i:= pos(SubStr, y);
    if i > 0 then
      result:=length(x) + i
    else result:=0;
  end
  else result:=0;
end;

function PosMidStrB(SubStr, S: String; Index: Integer): Integer;
var x,y:string;
    i: integer;
begin
  Result:= -1;
  x:=copy(S, 1, Index);
  y:='';
  for i:=Length(x) downto 1 do
  begin
    y:=x[i] + y;
    if pos(SubStr, y) > 0 then
    begin
      Result:=i;
      break;
    end;  
  end;  
end;  

function CountStr(SubStr, S: String): Integer;
var i, j: Integer;
begin
  j:=0;
  i:=pos(SubStr, s);
  while i > 0 do
  begin
    Delete(s, 1, i);
    inc(j);
    i:=pos(SubStr, s);
  end;
  Result:= j;
end;  

function ReplaceStr(OldStr, NewStr, S: String): String;
var i: Integer;
    l, lnew: Integer;
begin
  l:=Length(OldStr);
  lnew:=Length(NewStr);
  i:= pos(OldStr, S);
  if i > 0 then
  begin
    while i > 0 do
    begin
      Delete(s, i, l);
      Insert(NewStr, S, i);
      i:=PosMidStr(OldStr, S, i + lnew);
    end;
    Result:=S;
  end
  else Result:=S;
end;

function ReplaceStrUp(OldStr, NewStr, S: String): String;
var i: Integer;
    l, lnew: Integer;
    sUp: String;
begin
  sUp:=UpperCase(s);
  OldStr:=UpperCase(OldStr);
  l:=Length(OldStr);
  lnew:=Length(NewStr);
  i:= pos(OldStr, sUp);
  if i > 0 then
  begin
    while i > 0 do
    begin
      Delete(sUp, i, l);
      Insert(NewStr, sUp, i);
      Delete(s, i, l);
      Insert(NewStr, s, i);
      i:=PosMidStr(OldStr, sUp, i + lnew);
    end;
    Result:=S;
  end
  else Result:=S;
end;


(* ------------------ Datei-Funktionen --------------------------- *)
function BrowseDirectory(Title: String): String;
var bi:TBrowseInfo;
    lpBuffer: PChar;
    pidlPrograms,
    pidlBrowse: PItemIDList;
    Path:string;
begin
  // Verzeichniss auswählen
  Result:='';
  if (not SUCCEEDED(SHGEtSpecialFolderLocation(GetActiveWindow, CSIDL_DRIVES, pidlPrograms))) then
    Exit;

  lpBuffer:=StrAlloc(MAX_PATH);
  bi.hwndOwner:=GetActiveWindow;
  bi.pidlRoot:=pidlPrograms;
  bi.pszDisplayName:=lpBuffer;
  bi.lpszTitle:=pChar(Title);
  bi.ulFlags:=BIF_RETURNONLYFSDIRS;
  bi.lpfn:=nil;
  bi.lParam:=0;
  pidlBrowse:=SHBrowseForFolder(bi);
  if (pidlBrowse <> nil) then
    if (SHGetPathFromIDList(pidlBrowse, lpBuffer)) then Path:=lpBuffer;
  StrDispose(lpBuffer);

  if Path <> '' then
    if copy(Path, length(Path), 1) <> '\' then Path:=Path + '\';

  Result:=Path;
end;

function RPos(ss,s:string):integer;      // suche nach 1. auftreten von substring ss im string s von rechts
var i,l : integer;
    ls,ucs,ucss : string;
begin
 ls := '';
 result := 0;
 ucs := upperCase(s);
 ucss := upperCase(ss);
 if pos(ucss,ucs) = 0 then exit;
 l := length(s);
 for i := 0 to l-1 do
 begin
   ls := ucs[l-i] + ls;
   if pos(ucss,ls) > 0 then
   begin
     result := l-i;
     exit;
   end;
 end;
end;


function strtofloatdef(S: String): real;
begin
  try
    if s='' then
      strtofloatdef:=0
    else
      strtofloatdef:=strtofloat(s);
  except
    //rr('strtofloatdef');
    strtofloatdef:=0;
  end;
end;

function timestrtoint(S: String): integer;
var
  dauer,k:integer;
  ti:array [0..3] of string;
begin
  ti[0]:='0';

  k:=PosMidStr('d',s,1);
  if k>0 then begin
    ti[0]:=copy(s,1,k-1);
    delete(s,1,k+1);
  end;
  ti[1]:=copy(s,1,2);
  ti[2]:=copy(s,4,2);
  ti[3]:=copy(s,7,2);

  try
    dauer:=strtoint(ti[3]); // sekunden
    dauer:=dauer+60*strtoint(ti[2]); // minuten
    dauer:=dauer+3600*strtoint(ti[1]); // stunden
    dauer:=dauer+86400*strtoint(ti[0]); // tage
  except
    dauer:=0;
  end;
  timestrtoint:=dauer;
end;

function inttotimestr(S: integer): string;   // z.B. 3600-> '01:00:00'
var
  st:string;
  ti,t:integer;
begin

  try
    st:='';
    if (s > 86400) then begin
      st:=inttostr(s div 86400)+'d ';
    end;
    s:=s mod 86400;

    if (s div 3600) = 0 then
      st:=st+'00:'
    else if (s div 3600) < 10 then
      st:=st+'0'+inttostr(s div 3600)+':'
    else
      st:=st+inttostr(s div 3600)+':';

    ti:=s mod 3600;
    if (ti div 60) = 0 then
      st:=st+'00:'
    else if (ti div 60) < 10 then
      st:=st+'0'+inttostr(ti div 60)+':'
    else
      st:=st+inttostr(ti div 60)+':';

    t:=ti mod 60;
    if t = 0 then
      st:=st+'00'
    else if t < 10 then
      st:=st+'0'+inttostr(t)
    else
      st:=st+inttostr(t);
  except
    st:='00:00:00';
  end;
  inttotimestr:=st;
end;


function GetWindowsVersion:string;
var
  OsVinfo   : TOSVERSIONINFO;
  HilfStr   : array[0..50] of Char;
begin
ZeroMemory(@OsVinfo,sizeOf(OsVinfo));
OsVinfo.dwOSVersionInfoSize := sizeof(TOSVERSIONINFO);
if GetVersionEx(OsVinfo) then begin
 if OsVinfo.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
  begin
   if (OsVinfo.dwMajorVersion = 4) and
    (OsVinfo.dwMinorVersion > 0) then
     StrFmt(HilfStr,'Windows 98 - Version %d.%.2d.%d',
            [OsVinfo.dwMajorVersion, OsVinfo.dwMinorVersion,
             OsVinfo.dwBuildNumber AND $FFFF])
   else
     StrFmt(HilfStr,'Windows 95 - Version %d.%d Build %d',
            [OsVinfo.dwMajorVersion, OsVinfo.dwMinorVersion,
             OsVinfo.dwBuildNumber AND $FFFF]);
 end;
 if OsVinfo.dwPlatformId = VER_PLATFORM_WIN32_NT then
   StrFmt(HilfStr,'Windows NT Version %d.%.2d.%d',
          [OsVinfo.dwMajorVersion, OsVinfo.dwMinorVersion,
           OsVinfo.dwBuildNumber AND $FFFF]);
end
else
  StrCopy(HilfStr,'Fehler bei GetversionEx()!');
Result:=string(HilfStr);
end;

function UserName:string;
var UName : PChar;
    USize : DWord;
begin
  USize:=100;
  UName:=StrAlloc(USize);
  try
    GetUserName(UName,USize);
    Result:=string(UName);
  finally
    StrDispose(UName);
  end;
end; {UserName}

function strtottstrings(separator:char;s:string):tstrings;
var
  k,k1:integer;
begin
  if length(s)>1 then begin
    strlist.Clear;
    k:=PosMidStr(separator,s,1);
    while k>0 do begin
      strlist.add(copy(s,1,k-1));
      delete(s,1,k);
      k:=PosMidStr(separator,s,1);
      if k=0 then
        strlist.add(s);
    end;
    strtottstrings:=strlist;
  end;
end;

function WindowsDirectory:string;
var WinDir : PChar;
begin
  WinDir:=StrAlloc(Max_Path);
  try
    GetWindowsDirectory(WinDir,Max_Path);
    Result:=AddBackSlash(String(WinDir));
  finally
    StrDispose(WinDir);
  end;
end; {WindowsDirectory}

function AddBackSlash(PathName:string):string;
begin
  if (length(PathName)>0) and (PathName[length(PathName)]<>'\') then
    Result:=PathName+'\'
  else
    Result:=PathName;
end; {AddBackSlash}

function GetFileTypeName(AFileName : String) : string;
var FileInfo : TSHFileInfo;
     Flags : Integer;
     Name : array[0..255] of Char;
     Res : DWord;
begin
  Flags := SHGFI_TYPENAME;
  StrPCopy(Name,AFileName);
  Res := SHGetFileInfo(Name,0,FileInfo,SizeOf(FileInfo),Flags);
//  Result := Chr(Hi(LoWord(Res))) = 'E';
  GetFileTypeName:=fileinfo.szTypeName;
end;

function GetFileDisplayName(AFileName : String) : string;
var FileInfo : TSHFileInfo;
     Flags : Integer;
     Name : array[0..255] of Char;
     Res : DWord;
begin
  Flags := SHGFI_DISPLAYNAME;
  StrPCopy(Name,AFileName);
  Res := SHGetFileInfo(Name,0,FileInfo,SizeOf(FileInfo),Flags);
  GetFileDisplayName:=fileinfo.szDisplayName;
end;

function DateiGroesse(FileName: string): integer;
var
  FHandle:Thandle;
begin
  FHandle:=FileOpen(PChar(FileName),fmopenwrite);
  Result:=GetFileSize(FHandle,nil);
  FileClose(FHandle);
end;

function IsWindowsNT:boolean;
var
  OsVinfo   : TOSVERSIONINFO;
begin
  ZeroMemory(@OsVinfo,sizeOf(OsVinfo));
  OsVinfo.dwOSVersionInfoSize := sizeof(TOSVERSIONINFO);
  if GetVersionEx(OsVinfo) then
    Result:=OsVinfo.dwPlatformId = VER_PLATFORM_WIN32_NT
  else
    Result:=false;
end; {IsWindowsNT}

function SystemDirectory:string;
var SysDir : PChar;
begin
  SysDir:=StrAlloc(Max_Path);
  try
    GetSystemDirectory(SysDir,Max_Path);
    Result:=AddBackSlash(String(SysDir))
  finally
    StrDispose(SysDir);
  end;
end; {SystemDirectory}


procedure FileOperation (const source, dest: string; op, flags: Integer); var shf: TSHFileOpStruct;
     s1, s2: string;
begin
  FillChar (shf, SizeOf (shf), #0);
  s1:= source + #0#0;
  s2:= dest + #0#0;
  shf.Wnd:=    0;
  shf.wFunc:=  op;
  shf.pFrom:=  PCHAR (s1);
  shf.pTo:=    PCHAR (s2);
  shf.fFlags:= flags;
  SHFileOperation (shf);
end (*FileOperation*);


(* ------------------------- Initialisierungen ------------------------- *)

initialization
Init;


finalization
reInit;

end.
