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
    procedure FormResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    vrvenda: Double;
    procedure MensagemMemo(sHead, sTitulo, sCorpo : string; iCor : integer; sPeso : double; pausa : Cardinal);
    function lerBalanca(Peso: Double): Boolean;
  public
    { Public declarations }
    BalancaPronta : Boolean;
    PesoAnterior: Double;
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

procedure TfPrinc.MensagemMemo(sHead, sTitulo, sCorpo : string; iCor : integer; sPeso : double; pausa : cardinal);
begin
      mMensagem.Lines.Clear;

      mMensagem.Color := iCor;

      mMensagem.Lines.Add(sHead);
      mMensagem.Lines.Add(sTitulo);
      mMensagem.Lines.Add(sCorpo);

      vrPeso.Caption := Format('%.3f kg', [sPeso]);
      vrProd.Caption := FormatFloat('R$ #,##0.00', sPeso * vrVenda);

      if pausa > 0 then
        Sleep(pausa * 1000);
end;
function TfPrinc.lerBalanca(Peso: Double): Boolean;
begin
    if (Arredondar(Peso,3) = Arredondar(PesoAnterior,3))
    or (Arredondar(Peso,3) = Arredondar(PesoAnterior + 0.002,3))
    or (Arredondar(Peso,3) = Arredondar(PesoAnterior - 0.002,3))
    or (Arredondar(Peso,3) < Arredondar(strToFloat('0,020'),3)) then
      Exit;

    if not BalancaPronta then
      exit
    else
      BalancaPronta := false;

  PesoAnterior := Peso;

  MensagemMemo('Aguarde', 'Lendo balan�a...', ' ', clYellow, 0, 3);

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

  MensagemMemo(' ', 'Leitura conclu�da!', 'Por favor retire seu prato.',
                clLime, peso, 2);

  FACBrBAL.Desativar;
  FACBrBAL.Ativar;
  FACBrBAL.LePeso(2000);
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
    BalancaPronta := True;
    PesoAnterior  := 0.000;

    MensagemMemo(' ', 'Balan�a pronta.', 'Coloque o seu prato!', clLime, 0, 0);
  end

  else if Peso = -9 then
  begin
      Timer1.Enabled := False;
      Timer1.Enabled := True;
  end

  else if Peso > 0 then
    lerBalanca(Peso);
end;

procedure TfPrinc.FormDestroy(Sender: TObject);
begin
  // Desconecta da balan�a e libera o objeto
  FACBrBAL.Desativar;
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

  MensagemMemo('Balan�a pronta.', 'Coloque o seu prato!','', clLime, 0, 0);

  vrPeso.Caption := '0.00 kg';
  vrProd.Caption := 'R$ 0,00';

  Timer1.Enabled := True;
  BalancaPronta := true;
end;

end.
