unit urelPagamento;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, RLPrinters, RLBarcode, System.StrUtils,
  Data.FMTBcd, Data.DB, Datasnap.Provider, Data.SqlExpr, Datasnap.DBClient;

type
  Tfrelpagamento = class(TForm)
    RLReport1: TRLReport;
    RLBand2: TRLBand;
    RLBand4: TRLBand;
    RLLabel2: TRLLabel;
    RLLabel3: TRLLabel;
    RLLabel4: TRLLabel;
    RLBand5: TRLBand;
    RLMemo1: TRLMemo;
    RLMemo2: TRLMemo;
    RLBand1: TRLBand;
    RLDBText2: TRLDBText;
    RLDBMemo1: TRLDBMemo;
    rlNomeEmp: TRLMemo;
    RLBand3: TRLBand;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    rlComanda2: TRLLabel;
    RLBand6: TRLBand;
    RLLabel1: TRLLabel;
    rlVrTotal: TRLLabel;
    RLDBBarcode1: TRLDBBarcode;
    rbAdicionais: TRLBand;
    pnlAdicional1: TRLPanel;
    rlAdicional1: TRLLabel;
    cdsAdicional: TClientDataSet;
    pnlAdicional3: TRLPanel;
    rlAdicional3: TRLLabel;
    pnlAdicional7: TRLPanel;
    rlAdicional7: TRLLabel;
    pnlAdicional5: TRLPanel;
    rlAdicional5: TRLLabel;
    pnlAdicional9: TRLPanel;
    rlAdicional9: TRLLabel;
    pnlAdicional2: TRLPanel;
    rlAdicional2: TRLLabel;
    pnlAdicional4: TRLPanel;
    rlAdicional4: TRLLabel;
    pnlAdicional8: TRLPanel;
    rlAdicional8: TRLLabel;
    pnlAdicional6: TRLPanel;
    rlAdicional6: TRLLabel;
    pnlAdicional10: TRLPanel;
    rlAdicional10: TRLLabel;
    sdsAdicional: TSQLDataSet;
    dspAdicional: TDataSetProvider;
    cdsAdicionalCODIGO: TStringField;
    cdsAdicionalDESCRICAO: TStringField;
    RLMemo3: TRLMemo;
    procedure RLBand1BeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rbAdicionaisBeforePrint(Sender: TObject; var PrintIt: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    vrtot : double;
    procedure Imprimir;
  end;

var
  frelpagamento: Tfrelpagamento;

implementation

{$R *.dfm}

uses uFuncoes, uModulo, uPrinc;

procedure Tfrelpagamento.Imprimir;
label TrataErroAoImprimir;
var
     auxPrinterName : String;
     iErroAoImprimir : Integer;
     bImpresso : Boolean;
begin
     iErroAoImprimir := 0;
     bImpresso := False;

     TrataErroAoImprimir :

     try
          //Corre��o erro fortes comparando com ACBr - 27/08/2015
          //SetVersion( CommercialVersion, ReleaseVersion, CommentVersion );

          RLPrinter.Refresh;

          auxPrinterName := RLPrinter.PrinterName;

          if (dm.FiniParam.ReadString('Caixa','ImpressoraPadraoCupom','') <> '')
          and (auxPrinterName <> dm.FiniParam.ReadString('Caixa','ImpressoraPadraoCupom','')) then
               RLPrinter.PrinterName := dm.FiniParam.ReadString('Caixa','ImpressoraPadraoCupom','');

          // Ajustando o tamanho da p�gina //
          RLReport1.PageBreaking := pbNone;

          RLReport1.Prepare;

          //RLReport1.PreviewModal;
          //Sleep(2000);

          //try
               RLReport1.Print;
          //except
          //end;

          bImpresso := True;

          if auxPrinterName <> RLPrinter.PrinterName then
               RLPrinter.PrinterName := auxPrinterName;
     except
          on E : Exception do
          begin
              Application.MessageBox('Erro ao imprimir comanda.', 'Aten�ao', mb_iconexclamation);
              exit;
              { if AnsiPos('Printing in progress',E.Message) > 0 then
                    RLPrinter.EndDoc;
               Inc(iErroAoImprimir);
               if (iErroAoImprimir > 1) and (bImpresso = False) then //Se deu mais de um erro, exibe a mensagem
                    Fprinc.ApplicationEvents1Exception(RLReport1, E);}
          end;
     end;

     if (iErroAoImprimir = 1) and (bImpresso = False) then //Se deu erro na primeira vez, tenta novamente
          goto TrataErroAoImprimir;
end;

procedure Tfrelpagamento.rbAdicionaisBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
var
  i, j        : Integer;
  k           : integer;
  rlAdicional : TRLLabel;
  pnlAdicional: TRLPanel;
  sEspacos    : string;

begin
  if Parametro('UTILIZA_ADICIONAL_BALANCAAUTO') = 'S' then
  begin
      rlAdicional := TRLLabel.Create(nil);

      cdsAdicional.Close;
      cdsAdicional.Open;

      if (cdsAdicional.IsEmpty) or (cdsAdicional.RecordCount > 10) then
      begin
          rbAdicionais.Height := rbAdicionais.Height - 31;
          exit;
      end;

      k := 0;
      // Loop para percorrer os registros do TSQLQuery
      for i := 0 to cdsAdicional.RecordCount - 1 do
      begin
        sEspacos := '';

        // Obt�m uma refer�ncia � pr�xima Label com nome sequencial
        rlAdicional := TRLLabel(FindComponent('rlAdicional' + IntToStr(i + 1)));

        // Se a Label foi encontrada, configura a propriedade "Visible" para True
        if Assigned(rlAdicional) then
        begin
          rlAdicional.Caption := LeftStr(cdsAdicionalDESCRICAO.AsString, 15);
          k := k + 1;
        end
        else
          exit;

        //verifica se a quantidade de labels visiveis nao ��e par,
        //se nao for, adiciona o espa�o necessario para mostrar o painel
        if not (k mod 2 = 0) then
           rbAdicionais.Height := rbAdicionais.Height + 31;

        rlAdicional.Caption := '___' + rlAdicional.Caption;

        // Move para o pr�ximo registro
        cdsAdicional.Next;
      end;

      i := 0;

      pnlAdicional := TRLPanel.Create(nil);

      cdsAdicional.First;
      // Loop para percorrer os registros do TSQLQuery
      for i := 0 to cdsAdicional.RecordCount - 1 do
      begin
        // Obt�m uma refer�ncia do proximo painel com nome sequencial
        pnlAdicional := TRLPanel(FindComponent('pnlAdicional' + IntToStr(i + 1)));

        // Se o painel foi encontrado, configura a propriedade "Visible" para True
        if Assigned(pnlAdicional) then
          pnlAdicional.Visible := True;

        // Move para o pr�ximo registro
        cdsAdicional.Next;
      end;
  end
  else
    begin
      rbAdicionais.Height := rbAdicionais.Height - 31;
      exit;
    end;
end;

procedure Tfrelpagamento.RLBand1BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
    rlVrTotal.Caption := FormatFloat('R$ #,##0.00', vrtot);
end;

end.
