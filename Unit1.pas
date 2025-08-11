unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Multicrypt, Clipbrd, ComCtrls, ExtCtrls, XPMan,
  U_Tools, Spin;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Memo2: TMemo;
    Button5: TButton;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    SpinEdit5: TSpinEdit;
    SpinEdit6: TSpinEdit;
    SpinEdit7: TSpinEdit;
    SpinEdit8: TSpinEdit;
    Label2: TLabel;
    RadioGroup1: TRadioGroup;
    Clear: TButton;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Memo2Change(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.RadioButton5Click(Sender: TObject);
begin
  SpinEdit1.Enabled:=False;
end;

procedure TForm1.RadioButton4Click(Sender: TObject);
begin
  SpinEdit1.Enabled:=False;
end;

procedure TForm1.RadioButton3Click(Sender: TObject);
begin
  SpinEdit1.Enabled:=True
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  SpinEdit1.Enabled:=True;
end;

procedure TForm1.RadioButton2Click(Sender: TObject);
begin
  SpinEdit1.Enabled:=False
end;

procedure TForm1.ClearClick(Sender: TObject);
begin
  Memo1.Clear;
  StatusBar1.Panels[1].Text := IntToStr(Memo1.Lines.Count);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  StatusBar1.Panels[1].Text := IntToStr(Memo1.Lines.Count);
end;

procedure TForm1.Memo2Change(Sender: TObject);
begin
  StatusBar1.Panels[1].Text := IntToStr(Memo1.Lines.Count);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then  begin
  Memo1.Lines.LoadFromFile(OpenDialog1.FileName);
  StatusBar1.Panels[1].Text := IntToStr(Memo1.Lines.Count);
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
const
  UTF8BOM: array[0..2] of Byte = ($EF, $BB, $BF);

var
  text : TStringList;
  UTF8Str: UTF8String;
  FS: TFileStream;
begin
    try
      text := TStringList.Create;
      text.Text := (Memo1.Text);

      case RadioGroup1.ItemIndex of
      0 : text.SaveToFile(ExtractFilePath(Application.ExeName) + 'text.txt', TEncoding.ASCII);
      1 : text.SaveToFile(ExtractFilePath(Application.ExeName) + 'text.txt', TEncoding.ANSI);
      2 : text.SaveToFile(ExtractFilePath(Application.ExeName) + 'text.txt', TEncoding.UTF7);
      3 : text.SaveToFile(ExtractFilePath(Application.ExeName) + 'text.txt', TEncoding.UTF8);
      4 : text.SaveToFile(ExtractFilePath(Application.ExeName) + 'text.txt', TEncoding.BigEndianUnicode);
      5 : text.SaveToFile(ExtractFilePath(Application.ExeName) + 'text.txt', TEncoding.Unicode);
      6 : begin
            UTF8Str := UTF8Encode(Memo1.Text);
            FS := TFileStream.Create(ExtractFilePath(Application.ExeName) + 'text.txt', fmCreate);
            try
              FS.WriteBuffer(UTF8BOM[0], SizeOf(UTF8BOM));
              FS.WriteBuffer(PAnsiChar(UTF8Str)^, Length(UTF8Str));
            finally
            FS.Free;
          end;
          end;
      7 : text.SaveToFile(ExtractFilePath(Application.ExeName) + 'text.txt', TEncoding.Default);
      end;

      Memo1.Clear;
      Memo1.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'text.txt');
    finally
    text.Free;
    end;

    Memo1.Lines.Delete(0);

  if RadioButton1.Checked then begin
     Memo2.Text:=longcrypt(Memo1.Text,IntToStr(SpinEdit1.Value));
     end;
  if RadioButton2.Checked then begin
     Memo2.Text:=shortcrypt(Memo1.Text, SpinEdit1.Value, True);
     end;
  if RadioButton3.Checked then begin
     Memo2.Text:=randomencrypt(Memo1.Text, IntToStr(SpinEdit1.Value));
     end;
  if RadioButton4.Checked then begin
     Memo2.Text:=twopasscrypt(Memo1.Text, True, SpinEdit3.Value, SpinEdit4.Value);
     end;
  if RadioButton5.Checked then begin
     Memo2.Text:=duocrypt(Memo1.Text, True, [SpinEdit5.Value, SpinEdit6.Value, SpinEdit7.Value, SpinEdit8.Value])
     end;

  StatusBar1.Panels[3].Text := IntToStr(Memo2.Lines.Count);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if RadioButton1.Checked then begin
     Memo1.Text:=longdecrypt(Memo2.Text, IntToStr(SpinEdit1.Value)); end;
  if RadioButton2.Checked then
     Memo1.Text:=shortcrypt(Memo2.Text, SpinEdit1.Value, false);
  if RadioButton3.Checked then
     Memo1.Text:=randomdecrypt(Memo2.Text, IntToStr(SpinEdit1.Value));
  if RadioButton4.Checked then
     Memo1.Text:=twopasscrypt(Memo2.Text, false, SpinEdit3.Value, SpinEdit4.Value);
  if RadioButton5.Checked then
     Memo1.Text:=duocrypt(Memo2.Text, false, [SpinEdit5.Value, SpinEdit6.Value, SpinEdit7.Value, SpinEdit8.Value])
end;

end.
