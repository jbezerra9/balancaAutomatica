unit uselecionaprod;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils ,System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Data.FMTBcd,
  Data.DB, Data.SqlExpr, Datasnap.DBClient;

type
  TfSelecionaProd = class(TForm)
    pnlMeio: TPanel;
    sqlcon: TSQLQuery;
    sqlaux: TSQLQuery;
    pnlProdutos: TPanel;
    lbSelecione: TLabel;
    btAnterior: TButton;
    btProx: TButton;
    procedure FormShow(Sender: TObject);
    procedure btAnteriorClick(Sender: TObject);
    procedure btProxClick(Sender: TObject);
  private
    { Private declarations }
    ultBtnGrup, ultBtnProd, ultBtnGrup_Caption, ultBtnGrupEve: String;

    iQtdMesclar, iMesa, sNum, seqItemProdCombo, auxIDCombo, pagGrup, pagProd,
    ultPagGrup, ultPagProd, limitGrup, limitProd, nColunasProd, auxQtdMesc, skip: integer;
  public
    { Public declarations }

    bt_Prod_DivVert  : Integer;
    bt_Prod_DivHorz  : Integer;
    bt_Prod_Heigth   : Integer;
    bt_Prod_Width    : Integer;
    bt_Prod_FontName,sCodprod : String;
    bt_Prod_FontSize : Integer;

    bt_Prod_MaxCaracteres : Integer;
    bt_Prod_InfoValor : Boolean;

    procedure CriaBotoesProdutos(sTipo : String);
    procedure ClickBtnProduto(Sender: TObject);
  end;

var
  fSelecionaProd: TfSelecionaProd;

const
    corBtnGrup        = clWindow;
    corBtnGrupClick   = $0000AA55;
    corBtnProd        = $00BCE3D6;
    corBtnProdClick   = $0000AA55;

implementation

{$R *.dfm}

uses uFuncoes, uModulo, uPrinc;

procedure TFSelecionaProd.CriaBotoesProdutos(sTipo : String);
var
     botao, botao2: TButton ;
     c, l: Integer; //coluna e linha
     x: Integer;
     iLeft, iTop: Integer; //Define a posi��o e distancia entre os botoes
begin
     limitGrup := 21;

     //Limpa os componentes do pnlProdutos
     while pnlProdutos.ComponentCount > 0 do
          pnlProdutos.Components[pnlProdutos.ComponentCount -1].Destroy;

     sqlcon.Close;
     sqlcon.SQL.Text := 'select '+
                        ' first ' + IntToStr(limitGrup) +
                        ' skip ' + IntToStr(skip) +
                        ' tbprod.codigo, tbprod.descricao, '+
                        ' count(tbprod.codigo) as qtd, ' +
                        ' tbprod.PVendaA ' +
                        ' from tbprod ' +
                        ' left join tbunmed on tbunmed.codigo = tbprod.unmed ' +
                        ' inner join tbgrupo on tbgrupo.codigo = tbprod.grupo ' +
                        ' and tbprod.disponivel = ' +  QuotedStr('S') +
                        ' and tbprod.pvendaa > 0 ' +
                        sTipo;

     sqlcon.SQL.Text := sqlcon.SQL.Text + ' group by tbprod.codigo, tbprod.descricao, '+
                                            'tbprod.PVendaA';

     sqlcon.SQL.Text := sqlcon.SQL.Text + ' order by tbprod.descricao';

     sqlcon.Open;

     ultPagGrup := sqlcon.RecordCount div limitGrup;

     btAnterior.Enabled := skip > 0;
     btProx.Enabled     := skip < ultPagGrup;

     nColunasProd := pnlProdutos.Width div bt_Prod_DivHorz;

     iLeft := bt_Prod_DivHorz - bt_Prod_Width;
     iTop  := bt_Prod_DivVert - bt_Prod_Heigth;

     c := 0;
     l := iTop;

     while sqlcon.Eof = False do
     begin
          inc(c);

          botao := TButton.Create(pnlProdutos);

          botao.Name := 'btProd' + sqlcon.FieldByName('codigo').AsString;

          botao.OnClick := ClickBtnProduto;

          botao.Caption := sqlcon.FieldByName('descricao').AsString;

          //Informa o valor do produto
          if bt_Prod_InfoValor then
               botao.Caption := botao.Caption + #13 +
                    FormatCurr('#,###,##0.00',sqlcon.FieldByName('pvendaa').AsFloat);

          botao.WordWrap := True; //Quebra de linha

          //deixa o bot�o dentro do pnlProdutos
          botao.Parent := pnlProdutos;

          //atribui o tamanho
          botao.Height := bt_Prod_Heigth;
          botao.Width  := bt_Prod_Width;

          botao.Tag        := 0;
          botao.Font.Color := clWindowText;


          botao.Font.Name := bt_Prod_FontName;
          botao.Font.Size := bt_Prod_FontSize;
          botao.Font.Style := [fsBold];

          //posiciona o botao dentro do pnlProdutos
          if c > 1 then
          begin
               if c > nColunasProd then
               begin
                    c := 1;
                    l := l + iTop + botao.Height;
                    botao.Left := iLeft;
               end
               else
               begin
                    x := botao2.Left + botao2.Width + iLeft;
                    botao.Left := x;
               end;
          end
          else
          begin
               x := iLeft;
               botao.Left := x;
          end;
          botao.Top := l;

          sqlcon.Next;
          botao2 := botao;

          Self.Refresh;
     end;
end;

procedure TfSelecionaProd.btAnteriorClick(Sender: TObject);
begin
    skip := skip - 21;
end;

procedure TfSelecionaProd.btProxClick(Sender: TObject);
begin
      skip := skip + 21;
end;

procedure TfSelecionaProd.ClickBtnProduto(Sender: TObject);
var sql : string;
begin
     if pnlProdutos.Tag = 1 then
          Exit;

     ultBtnProd := TButton(Sender).Name;

     if ultBtnProd <> '' then
     begin
         { try (pnlProdutos.FindComponent(ultBtnProd) as TButton).Color      := corBtnProd;
          except; end;
          }
          try (pnlProdutos.FindComponent(ultBtnProd) as TButton).Font.Color := clWindowText;
          except; end;
     end;

     ultBtnProd := TButton(Sender).Name;

     sql := 'select tbprod.descricao, tbprod.codigo, '+
            ' tbunmed.descricao as unmed,'+
            ' tbprod.PVendaA' +
            ' from tbprod'+
            ' left join tbunmed on tbprod.unmed = tbunmed.codigo';

     sql := sql + ' where tbprod.codigo = ' + QuotedStr(AnsiReplaceStr(ultBtnProd,'btProd',''));
     sql := sql + ' and tbunmed.descricao = ''KG''';

     sqlaux.Close;
     sqlaux.SQL.Text := sql;
     sqlaux.Open;

     dm.sCodProd := AnsiReplaceStr(ultBtnProd,'btProd','');

     try
          Application.CreateForm(TfPrinc, fPrinc);
          Fprinc.ShowModal;
     finally
          FreeAndNil(fprinc);
     end;

     //showMessage('honda civic');
end;

procedure TfSelecionaProd.FormShow(Sender: TObject);
begin
    bt_Prod_DivVert  := 127;
    bt_Prod_DivHorz  := 105;
    bt_Prod_Heigth   := 120;
    bt_Prod_Width    := 100;

    bt_Prod_FontName := 'Arial';
    bt_Prod_FontSize := 10;

    bt_Prod_MaxCaracteres := 0;
    bt_Prod_InfoValor     := False;

    skip := 0;

    if Assigned(fprinc) then
        CriaBotoesProdutos('and tbgrupo.descricao = '+ QuotedStr('BEBIDAS'))
    else
        CriaBotoesProdutos('and tbunmed.descricao = '+ QuotedStr('KG'));
end;

end.

