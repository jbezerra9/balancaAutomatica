unit uPrinc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.ExtCtrls,
  ACBrBase, ACBrBAL, Vcl.StdCtrls, Data.DB, Data.FMTBcd, Data.SqlExpr,
  Datasnap.DBClient, RLReport, Vcl.Buttons, ACBrDeviceSerial, Datasnap.Provider;

Const
  InputBoxMessage = WM_USER + 200;

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
    dsComandaItem: TDataSource;
    Timer1: TTimer;
    btSair: TSpeedButton;
    sdsComandaItem: TSQLDataSet;
    sdsComandaItemCOMANDA: TIntegerField;
    sdsComandaItemCODPROD: TStringField;
    sdsComandaItemCODPROD_2: TStringField;
    sdsComandaItemDESCRICAO: TStringField;
    sdsComandaItemQTD: TFloatField;
    sdsComandaItemVR_UNIT: TFloatField;
    sdsComandaItemFUNCIONARIO: TStringField;
    sdsComandaItemID_INGRE: TIntegerField;
    sdsComandaItemSEQ_ITEM: TIntegerField;
    sdsComandaItemDATA: TDateField;
    sdsComandaItemHORA: TTimeField;
    sdsComandaItemCOMANDA_ANTERIOR: TIntegerField;
    sdsComandaItemSEQ_PESO: TIntegerField;
    sdsComandaItemVIAGEM: TStringField;
    sdsComandaItemTAXAATENDIMENTO: TStringField;
    sdsComandaItemPROD_PAI: TIntegerField;
    sdsComandaItemID_PIZZA: TIntegerField;
    sdsComandaItemIDTRANSACAO_EASYCHOPP: TStringField;
    dspComandaItem: TDataSetProvider;
    cdsComandaItem: TClientDataSet;
    cdsComandaItemCOMANDA: TIntegerField;
    cdsComandaItemCODPROD: TStringField;
    cdsComandaItemCODPROD_2: TStringField;
    cdsComandaItemDESCRICAO: TStringField;
    cdsComandaItemQTD: TFloatField;
    cdsComandaItemVR_UNIT: TFloatField;
    cdsComandaItemFUNCIONARIO: TStringField;
    cdsComandaItemID_INGRE: TIntegerField;
    cdsComandaItemSEQ_ITEM: TIntegerField;
    cdsComandaItemDATA: TDateField;
    cdsComandaItemHORA: TTimeField;
    cdsComandaItemCOMANDA_ANTERIOR: TIntegerField;
    cdsComandaItemSEQ_PESO: TIntegerField;
    cdsComandaItemVIAGEM: TStringField;
    cdsComandaItemTAXAATENDIMENTO: TStringField;
    cdsComandaItemPROD_PAI: TIntegerField;
    cdsComandaItemID_PIZZA: TIntegerField;
    cdsComandaItemIDTRANSACAO_EASYCHOPP: TStringField;
    procedure FormDestroy(Sender: TObject);
    procedure FACBrBALLePeso(Peso: Double; Resposta: AnsiString);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    vrvenda: Double;
    BalancaPronta, passouLimite : Boolean;
    sCodProd, sCodProdSub, comandaInicial, comandaFinal : String;
    PesoAnterior: Double;
    precoKG     : Double;
    vrtot, pesolimite : Double;
    procedure MensagemMemo(sHead, sTitulo, sCorpo : string; iCor : integer; sPeso : double; pausa : Cardinal);
    procedure InputBoxSetPasswordChar(var Msg: TMessage); message InputBoxMessage;
    procedure ConfiguraBal;
    procedure ConsultaCaixa;
    procedure zeraGerador;
    function lerBalanca(Peso: Double): Boolean;
    function geraIdComandaBal : integer;
  public
    { Public declarations }
  end;

var
  fPrinc: TfPrinc;
  codUsuario : integer;
  nomUsuario : string;

  sAcessoUsuario : string;
  sAcessoSenha  : string;
  sUserFunc, codCaixa, datasenha: string;

implementation

{$R *.dfm}

uses uFuncoes, uModulo, Utransacao, uMensagem, upesqcad, urelPagamento,
  uselecionaprod;

procedure TfPrinc.InputBoxSetPasswordChar(var Msg: TMessage);
var
     hInputForm, hEdit: HWND;
begin
     hInputForm := Screen.Forms[0].Handle;
     if (hInputForm <> 0) then
     begin
          hEdit := FindWindowEx(hInputForm, 0, 'TEdit', nil);
          SendMessage(hEdit, EM_SETPASSWORDCHAR, Ord('*'), 0);
     end;
end;

procedure TfPrinc.zeraGerador;
begin
      sqlcon.Close;
      sqlcon.SQL.Text := 'SELECT GEN_ID(gen_comandabalanca_auto, 0) FROM RDB$DATABASE';
      sqlcon.Open;

      if (sqlcon.Fieldbyname('gen_id').AsInteger = strToInt(comandaFinal))
      or (sqlcon.Fieldbyname('gen_id').AsInteger < strToInt(comandaInicial)) then
      begin
          sqlcon.Close;
          sqlcon.SQL.Text := 'set generator gen_comandabalanca_auto to ' + comandaInicial;
          sqlcon.ExecSQL;
      end;
end;

function TfPrinc.geraIdComandaBal : integer;
var sqlc : TSQLQuery;
    comanda : integer;
begin
    zeraGerador;

    sqlc               := TSQLQuery.Create(dm.conexao);
    sqlc.SQLConnection := dm.conexao;

    sqlc.Close;
    sqlc.SQL.Text := 'SELECT GEN_ID(gen_comandabalanca_auto, 1) FROM RDB$DATABASE';
    sqlc.Open;

    Result := sqlc.FieldByName('Gen_id').AsInteger;
end;

procedure TfPrinc.ConfiguraBal;
var  timeout : integer;
begin
    try
      FACBrBal.Desativar;

      FACBrBAL.Modelo           := TACBrBALModelo(2);
      FACBrBAL.Device.Porta     := dm.FiniParam.ReadString('Balanca1','Porta','COM1');
      FACBrBAL.Device.Baud      := StrToInt(dm.FiniParam.ReadString('Balanca1','BaudRate','2400'));
      FACBrBAL.Device.Data      := StrToInt(dm.FiniParam.ReadString('Balanca1','DataBits','8'));
      FACBrBAL.Device.Parity    := TACBrSerialParity(dm.FiniParam.ReadInteger('Balanca1','Paridade',0));
      FACBrBAL.Device.Stop      := TACBrSerialStop(dm.FiniParam.ReadInteger('Balanca1','StopBits',0));
      FACBrBAL.Device.HandShake := TACBrHandShake(dm.FiniParam.ReadInteger('Balanca1','HandShaking',0));
      TimeOut                   := dm.FiniParam.ReadInteger('Balanca1','TimeOut',2000);

      FACBrBal.Ativar;

      FACBrBAL.EnviarPrecoKg(vrVenda, TimeOut);
    except
      Application.MessageBox('Falha ao enviar pre�o/KG para a balan�a!', 'Aten��o', mb_ok + mb_iconerror);
      exit;
    end;

    FACBrBal.Desativar;

    FACBrBAL.Modelo           := TACBrBALModelo(dm.FiniParam.ReadInteger('Balanca1','Modelo',2));
    FACBrBAL.Device.Porta     := dm.FiniParam.ReadString('Balanca1','Porta','COM2');
    FACBrBAL.Device.Baud      := StrToInt(dm.FiniParam.ReadString('Balanca1','BaudRate','2400'));
    FACBrBAL.Device.Data      := StrToInt(dm.FiniParam.ReadString('Balanca1','DataBits','8'));
    FACBrBAL.Device.Parity    := TACBrSerialParity(dm.FiniParam.ReadInteger('Balanca1','Paridade',0));
    FACBrBAL.Device.Stop      := TACBrSerialStop(dm.FiniParam.ReadInteger('Balanca1','StopBits',0));
    FACBrBAL.Device.HandShake := TACBrHandShake(dm.FiniParam.ReadInteger('Balanca1','HandShaking',0));
    TimeOut                   := dm.FiniParam.ReadInteger('Balanca1','TimeOut',2000);

    FACBrBal.Ativar;
end;
procedure TfPrinc.MensagemMemo(sHead, sTitulo, sCorpo : string; iCor : integer; sPeso : double; pausa : cardinal);
begin
      mMensagem.Lines.Clear;

      mMensagem.Color := iCor;

      mMensagem.Lines.Add(sHead);
      mMensagem.Lines.Add(sTitulo);
      mMensagem.Lines.Add(sCorpo);

      if passouLimite and (sCodProdSub <> '') then
        vrPeso.Caption := Format('%.2f Un', [sPeso])

      else
        vrPeso.Caption := Format('%.3f kg', [sPeso]);

      vrProd.Caption := FormatFloat('R$ #,##0.00', sPeso * vrVenda);

      if pausa > 0 then
        Sleep(pausa * 1000);
end;
procedure TfPrinc.Timer1Timer(Sender: TObject);
begin
    FACBrBAL.Desativar;
    FACBrBAL.LePeso(2000);
    FAcbrBAL.Ativar;
end;

function TfPrinc.lerBalanca(Peso: Double): Boolean;
var codProdSalva1, codProdSalva2, descricao, vrVendaMemo: String;
    vrunit, qtd : double;
begin
  if (Arredondar(Peso, 3) = Arredondar(PesoAnterior, 3))
  or (Arredondar(Peso, 3) = Arredondar(PesoAnterior + 0.002, 3))
  or (Arredondar(Peso, 3) = Arredondar(PesoAnterior - 0.002, 3))
  or (Arredondar(Peso, 3) < Arredondar(strToFloat('0,020'), 3)) then
    Exit;

  if not BalancaPronta then
    exit
  else
    BalancaPronta := false;

  PesoAnterior := Peso;

  MensagemMemo(' ', 'Aguarde', 'Lendo balan�a...', clYellow, 0, 3);

  sqlcon.Close;
  sqlcon.SQL.Text := 'select tbprod.descricao as descProd, tbprod.pVendaa as vrUnit,' +
                     ' tbunmed.descricao as un ' +
                     'from tbprod ' +
                     'left join tbunmed on tbunmed.codigo = tbprod.unmed ' +
                     'where tbprod.codigo = ' + sCodProd;
  sqlcon.Open;

  if sqlcon.IsEmpty then
    Exit;

  if (peso > pesolimite) and (sCodProdSub <> '') then
  begin
    passouLimite := true;

    sqlcon.Close;
    sqlcon.SQL.Text := 'select tbprod.descricao as descProd, ' +
                       ' tbprod.pVendaa as vrUnit ' +
                       ' from tbprod ' +
                       ' where tbprod.codigo = ' + quotedStr(sCodProdSub);
    sqlcon.Open;

    vrunit    := sqlcon.FieldByName('vrUnit').AsFloat;
    vrvenda   := vrunit;
    descricao := sqlcon.FieldByName('descProd').AsString;
    vrtot     := vrunit;
    Peso       := 1;

    codProdSalva1 := scodprodsub;

    if (Parametro('TIPO_PESQ_CODPROD') = 'I')
    or (Parametro('TIPO_PESQ_CODPROD') = 'P') then
    begin
         sCodProdSub := codProdSalva1;
         codProdSalva2     := '';
    end
    else
         if codProdSalva1 <> sCodProdSub then
              codProdSalva2 := sCodProdSub
         else
              codProdSalva2 := '';
  end

  else
  begin
    vrunit    := sqlcon.FieldByName('vrUnit').AsFloat;
    vrtot     := vrunit * peso;
    vrvenda   := vrunit;
    descricao := sqlcon.FieldByName('descProd').AsString;
    //qtd       := peso;

    codProdSalva1 := sCodProd;

    if (Parametro('TIPO_PESQ_CODPROD') = 'I')
    or (Parametro('TIPO_PESQ_CODPROD') = 'P') then
    begin
         sCodProd := codProdSalva1;
         codProdSalva2     := '';
    end
    else
         if codProdSalva1 <> sCodProd then
              codProdSalva2 := sCodProd
         else
              codProdSalva2 := '';
  end;

  cdsComandaItem.EmptyDataSet;

  cdsComandaItem.Append;
  cdsComandaItemCOMANDA.AsInteger          := geraIdComandaBal;
  cdsComandaItemCODPROD.AsString           := codProdSalva1;
  cdsComandaItemCODPROD_2.AsString         := codProdSalva2;
  cdsComandaItemDESCRICAO.AsString         := descricao;
  cdsComandaItemQTD.AsFloat                := Peso;
  cdsComandaItemVR_UNIT.AsFloat            := vrunit;
  cdsComandaItemFUNCIONARIO.AsString       := '';
  cdsComandaItemID_INGRE.AsInteger         := 0;
  cdsComandaItemSEQ_PESO.AsInteger         := 1;
  cdsComandaItemVIAGEM.AsString            := 'N';
  cdsComandaItemTAXAATENDIMENTO.AsString   := 'N';

  cdsComandaItem.Post;
  cdsComandaItem.ApplyUpdates(-1);

  MensagemMemo(' ', 'Leitura conclu�da!', 'Por favor retire seu prato.',
                clLime, peso, 0);

  try
    application.CreateForm(Tfrelpagamento, frelpagamento);
    frelpagamento.rlNomeEmp.Lines.Add(IfThen(dm.tbempNOME.AsString = '',
      dm.tbempEMPRESA.AsString, dm.tbempNOME.AsString));
    frelpagamento.rlComanda2.Caption := 'Comanda: ' + cdsComandaItemCOMANDA.AsString;
    frelpagamento.vrtot := vrtot;
    frelpagamento.Imprimir;
  finally
    freeAndNil(frelpagamento);
  end;
end;

procedure TfPrinc.btSairClick(Sender: TObject);
var sSenha : string;
begin
     Timer1.enabled := false;
     sSenha := '';

     PostMessage(Handle, InputBoxMessage, 0, 0);
     if InputQuery('Senha de acesso','Senha',sSenha) = False then
     begin
          Timer1.enabled := true;
          Exit;
     end;

     if sSenha <> 'bbifood' then
     begin
          Application.MessageBox('Senha inv�lida.','Aten��o',MB_ICONEXCLAMATION);
          Timer1.enabled := true;
          Exit;
     end;

     Timer1.enabled := false;
     close;
end;

procedure TfPrinc.FACBrBALLePeso(Peso: Double; Resposta: AnsiString);
begin
  if Peso <= 0.000 then
  begin
    BalancaPronta := True;
    passouLimite  := false;

    PesoAnterior  := 0.000;

    MensagemMemo(' ', 'Balan�a pronta.', 'Coloque o seu prato!', clLime, 0, 0);
  end

  else if Peso > 0 then
    lerBalanca(Peso);
end;

procedure TfPrinc.ConsultaCaixa;
begin
    sqlcon.Close;
    sqlcon.SQL.Text := 'select * '+
                       'from tbcaixa '+
                       'where aberto = ''S'' ';
    sqlcon.Open;

    if sqlcon.IsEmpty then
    begin
        Application.MessageBox('Abra o caixa antes de utilizar a balan�a autom�tica','Aten��o', mb_ok + mb_iconexclamation);
        Abort;
    end
end;

procedure TfPrinc.FormActivate(Sender: TObject);
begin
    ConsultaCaixa;
end;

procedure TfPrinc.FormCreate(Sender: TObject);
begin
   comandaInicial  := dm.FiniParam.ReadString( 'ComandaBalancaAuto','ComandaInicial','500');
   comandaFinal    := dm.FiniParam.ReadString( 'ComandaBalancaAuto','ComandaFinal','599');
end;

procedure TfPrinc.FormDestroy(Sender: TObject);
begin
  // Desconecta da balan�a e libera o objeto
  freeAndNil(FACBrBAL);
  cdsComandaItem.Close;
  dm.tbemp.Close;
end;

procedure TfPrinc.FormResize(Sender: TObject);
begin
    pnlTitulo.Width := fPrinc.Width;
end;

procedure TfPrinc.FormShow(Sender: TObject);
begin
  sCodProd     := dm.sCodProd;
  sCodProdSub  := dm.sCodprodsub;
  pesolimite   := dm.peso_limite;
  passouLimite := false;

  dm.tbemp.Open;
  cdsComandaItem.Open;

  sqlcon.Close;
  sqlcon.SQL.Text := ' select pvendaa from tbprod where codigo = ' +
                      quotedStr(sCodProd);
  sqlcon.Open;

  if sqlcon.IsEmpty then
  begin
    application.Messagebox('Produto invalido!', 'Aten��o', mb_iconexclamation);
    Close;
  end;

  MensagemMemo('Balan�a pronta.', 'Coloque o seu prato!','', clLime, 0, 0);

  vrPeso.Caption := '0,000 kg';
  vrProd.Caption := 'R$ 0,00';

  Application.Title := 'Balan�a Automatica';

  BalancaPronta  := true;

  zeraGerador;
  ConfiguraBal;
  Timer1.Enabled := true;
end;

end.
