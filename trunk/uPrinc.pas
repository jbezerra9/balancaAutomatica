unit uPrinc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.ExtCtrls,
  ACBrBase, ACBrBAL, Vcl.StdCtrls, Data.DB, Data.FMTBcd, Data.SqlExpr,
  Datasnap.DBClient, RLReport;

type
  TfPrinc = class(TForm)
    pnlTitulo: TPanel;
    Image1: TImage;
    pnlPeso: TPanel;
    FACBrBAL: TACBrBAL;
    mMensagem: TMemo;
    lbBBifood: TLabel;
    sqlcon: TSQLQuery;
    Label1: TLabel;
    Label2: TLabel;
    vrProd: TLabel;
    vrPeso: TLabel;
    cdsProd: TClientDataSet;
    cdsProdDescricao: TStringField;
    cdsProdqtd: TFloatField;
    cdsProdVrTotal: TCurrencyField;
    cdsProdUN: TStringField;
    cdsProdVrVenda: TCurrencyField;
    dsProd: TDataSource;
    cdsProdComanda: TStringField;
    sqlcon2: TSQLQuery;
    Timer1: TTimer;
    procedure FormDestroy(Sender: TObject);
    procedure FACBrBALLePeso(Peso: Double; Resposta: AnsiString);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    vrvenda: Double;
    bBalancaPronta: Boolean;
    function lerBalanca(Peso: Double): Boolean;
  public
    { Public declarations }
    peso1: Double;
  end;

var
  fPrinc: TfPrinc;
  codUsuario: Integer;
  nomUsuario, sUserFunc, codCaixa, datasenha: String;
  sAcessoUsuario: String;
  sAcessoSenha: String;
  sCodProd: String;

implementation

{$R *.dfm}

uses uFuncoes, uModulo, Utransacao, uMensagem, upesqcad, urelPagamento,
  uselecionaprod;

function TfPrinc.lerBalanca(Peso: Double): Boolean;
begin
  if not bBalancaPronta then
    Exit
  else
    bBalancaPronta := False;

  { if peso1 = peso then
    exit
    else
    peso1 := peso;
  }
  if Peso < strToFloat('0,020') then
    Exit;

  mMensagem.Lines.Clear;
  mMensagem.Color := clYellow;
  mMensagem.Lines.Add('');
  mMensagem.Lines.Add('Lendo balan�a...');

  sleep(3000);

  { if peso1 <> peso then
    begin
    mMensagem.Lines.Clear;
    mMensagem.Lines.Add(' ');
    mMensagem.Lines.Add('Erro na leitura. ');
    mMensagem.Lines.Add('Retire o prato e coloque na balan�a');
    mMensagem.Lines.Add(' ');
    mMensagem.Color    := clRed;

    pnlPeso.Caption    := '0.000 KG';
    vrProd.Caption     := 'R$ 0,00';
    exit;
    end; }

  mMensagem.Lines.Clear;
  mMensagem.Color := clLime;
  mMensagem.Lines.Add(' ');
  mMensagem.Lines.Add('Leitura conclu�da!');
  mMensagem.Lines.Add('Por favor retire seu prato.');
  // mMensagem.Lines.Add(' ');

  vrPeso.Caption := Format('%.3f kg', [Peso]);
  vrProd.Caption := FormatCurr('R$ #,##0.00', vrvenda * Peso);

  sqlcon.Close;
  sqlcon.SQL.Text := 'select tbprod.descricao, tbprod.pvendaa, ' +
    '(tbprod.pVendaa * ' + Trocavirgula(Peso) + ') as vrTotal,  ' +
    'tbunmed.descricao as un ' + 'from tbprod ' +
    'left join tbunmed on tbunmed.codigo = tbprod.unmed ' +
    'where tbprod.codigo = ' + sCodProd;
  sqlcon.Open;

  sqlcon2.Close;
  sqlcon2.SQL.Text := 'select max(tbcomanda.comanda) as comanda from tbcomanda';
  sqlcon2.Open;

  if sqlcon.IsEmpty then
    Exit;

  cdsProd.EmptyDataSet;

  cdsProd.Insert;
  cdsProdDescricao.AsString := sqlcon.FieldByName('descricao').AsString;
  cdsProdqtd.AsFloat := Peso;
  cdsProdComanda.AsString := IntToStr(sqlcon2.FieldByName('comanda')
    .AsInteger + 1);
  cdsProdVrVenda.AsCurrency := sqlcon.FieldByName('pVendaa').AsCurrency;
  cdsProdVrTotal.AsCurrency := sqlcon.FieldByName('vrTotal').AsCurrency;
  cdsProdUN.AsString := sqlcon.FieldByName('un').AsString;
  cdsProd.Post;

  try
    application.CreateForm(Tfrelpagamento, frelpagamento);
    frelpagamento.rlNomeEmp.Lines.Add(IfThen(dm.tbempEMPRESA.AsString = '',
      dm.tbempNOME.AsString, dm.tbempEMPRESA.AsString));
    frelpagamento.rlComanda2.Caption := 'Comanda: ' + cdsProdComanda.AsString;
    frelpagamento.Imprimir;
  finally
    freeAndNil(frelpagamento);
  end;

  sleep(2000);
end;

procedure TfPrinc.Timer1Timer(Sender: TObject);
begin
  FACBrBAL.Ativar;
  FACBrBAL.LePeso(2000);
  FACBrBAL.Desativar;
end;

procedure TfPrinc.FACBrBALLePeso(Peso: Double; Resposta: AnsiString);
begin
  if Peso = 0.000 then
  begin
    bBalancaPronta := True;

    mMensagem.Lines.Clear;
    mMensagem.Lines.Add(' ');
    mMensagem.Lines.Add('Balan�a pronta.');
    mMensagem.Lines.Add('Coloque o seu prato!');
    mMensagem.Color := clLime;

    vrPeso.Caption := '0.000 KG';
    vrProd.Caption := 'R$ 0,00';

    peso1 := 0;
  end
  else if Peso > 0 then
    lerBalanca(Peso);
end;

procedure TfPrinc.FormCreate(Sender: TObject);
begin
  FACBrBAL.Ativar;
  bBalancaPronta := True;
end;

procedure TfPrinc.FormDestroy(Sender: TObject);
begin
  // Desconecta da balan�a e libera o objeto
  FACBrBAL.Desativar;
  FACBrBAL.Free;
  dm.tbemp.Close;
end;

procedure TfPrinc.FormResize(Sender: TObject);
begin
  pnlTitulo.Width := fPrinc.Width;
end;

procedure TfPrinc.FormShow(Sender: TObject);
var
  SQL: string;
begin
  sCodProd := dm.sCodProd;

  cdsProd.CreateDataSet;
  dm.tbemp.Open;

  sqlcon.Close;
  sqlcon.SQL.Text := ' select pvendaa from tbprod where codigo = ' +
    quotedStr(sCodProd);
  sqlcon.Open;

  if sqlcon.IsEmpty then
  begin
    application.Messagebox('Produto invalido!', 'Aten�ao', mb_iconexclamation);
    Close;
  end;

  vrvenda := sqlcon.FieldByName('pvendaa').AsFloat;

  mMensagem.Lines.Clear;
  // mMensagem.Lines.Add(' ');
  mMensagem.Lines.Add('Balan�a pronta.');
  mMensagem.Lines.Add('Coloque o seu prato!');
  mMensagem.Color := clLime;

  vrPeso.Caption := '0.000 KG';
  vrProd.Caption := 'R$ 0,00';
end;

end.
