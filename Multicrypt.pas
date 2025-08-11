unit multicrypt;

interface
uses Classes, SysUtils, Types;

function longcrypt(crypttext,key:string):string;
function longdecrypt(crypttext,key:string):string;
function shortcrypt(crypttext:string;key:longword;encrypt:boolean):string;
function randomencrypt(crypttext,key:string):string;
function randomdecrypt(crypttext,key:string):string;
function twopasscrypt(crypttext:string;Method:boolean;key1:Longint;key2:DWord):string;
function duocrypt(const txt:string;Methode:boolean;schlssl:array of DWord):string;

implementation

var
passwort:string;

function longcrypt(crypttext,key:string):string;
var x,y,lg:integer;
begin
  result:='';
    try
    if length(crypttext) > 0 then begin
    y:=1;
    lg:=length(key);

    for x:=1 to length(crypttext) do begin
      result:=result + formatfloat('000',ord(crypttext[x])
      xor ord(key[y]));
      if y=lg then y:=1
    else inc(y);
    end;
    end;
  except result:='';end;
end;

function longdecrypt(crypttext,key:string):string;
var x,y,lg:integer;
begin
result:='';
try
lg:=length(crypttext);
if (lg > 0) and (lg mod 3 = 0) then begin
y:=1;
while y < lg do begin
result:=result + chr(strtoint(copy(crypttext,y,3)));
inc(y,3);
end;
y:=1;
lg:=length(key);
for x:=1 to length(result) do begin
result[x]:=chr(ord(result[x]) xor ord(key[y]));
if y=lg then y:=1
else inc(y);
end;
end;
except result:='';end;
end;

function shortcrypt(crypttext:string;key:longword;encrypt:boolean):string;
var
x,p,n:Integer;
key1:string;
begin
result:='';
p:=0;
key1:=inttostr(key);
for x:=1 to length(crypttext) do begin
inc(p);
if p > length(key1) then p:=1;
if encrypt then begin
n:=ord(crypttext[x]) + ord(key1[p]);
if n > 255 then n:=n - $E0;
end else begin
n:=ord(crypttext[x]) - ord(key1[p]);
if n < 32 then n:=n + $E0;
end;
result:=result + chr(n);
end;
end;

function randomencrypt(crypttext,key:string):string;
var x,y,lg,n:integer;
begin
result:='';
lg:=length(key);
y:=1;
randomize;
for x:=1 to length(crypttext) do begin
n:=(byte(crypttext[x]) xor byte(key[y])) or
(((random(32) shl 8) and 15872) or 16384);
if lo(n)<32 then n:=n or 384;
if y=lg then y:=1
else inc(y);
result:=result+chr(lo(n))+chr(hi(n));
end;
end;

function randomdecrypt(crypttext,key:string):string;
var x,y,lg,n:integer;
begin
if not odd(length(crypttext)) then begin
result:='';
lg:=length(key);
y:=1;
x:=1;
while x < length(crypttext) do begin
n:=(byte(crypttext[x]) or (byte(crypttext[x+1]) shl 8));
if n and 256 > 0 then n:=n and 127
else n:=n and 255;
result:=result+chr(n xor byte(key[y]));
if y=lg then y:=1
else inc(y);
inc(x,2);
end;
end else result:=crypttext;
end;

function twopasscrypt(crypttext:string;Method:boolean;key1:Longint;key2:DWord):string;
var
x,p,n,lg:Integer;
s:string;
begin
p:=0;
result:='';
randseed:=key1;
s:=inttostr(key2);
lg:=length(s);
for x:=1 to length(crypttext) do begin
inc(p);
if p > length(s) then p:=1;
if Method then begin
n:=ord(crypttext[x]) + ord(s[p]) + random($70 + lg);
if n > 255 then n:=n - $E0;
end else begin
n:=ord(crypttext[x]) - ord(s[p]) - random($70 + lg);
if n < 32 then n:=n + $E0;
end;
result:=result + chr(n);
end;
end;

function
duocrypt(const txt:string;Methode:boolean;schlssl:array of DWord):string;
var
n,h,i,j:integer;
ss:array of string;
lg,zl:array of byte;
begin
result:=txt;
h:=high(schlssl);
setlength(ss,h+1);
setlength(zl,h+1);
setlength(lg,h+1);
for i:=0 to h do begin
ss[i]:=inttostr(schlssl[i]);
lg[i]:=length(ss[i]);
zl[i]:=1;
end;
for i:=1 to length(txt) do begin
n:=byte(txt[i]);
for j:=0 to h do begin
if methode then begin
n:=n + byte(ss[j][zl[j]]) + lg[j];
if n > 255 then n:=n - $E0;
end else begin
n:=n - byte(ss[j][zl[j]]) - lg[j];
if n < 32 then n:=n + $E0;
end;
inc(zl[j]);
if zl[j]>lg[j] then zl[j]:=1;
end;
result[i]:=char(n);
end;
zl:=nil;
lg:=nil;
ss:=nil;
end;


end.
