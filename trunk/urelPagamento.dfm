object frelpagamento: Tfrelpagamento
  Left = 0
  Top = 0
  Caption = 'frelpagamento'
  ClientHeight = 639
  ClientWidth = 723
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object RLReport1: TRLReport
    Left = 8
    Top = 8
    Width = 359
    Height = 1134
    Margins.LeftMargin = 0.000000000000000000
    Margins.TopMargin = 0.000000000000000000
    Margins.RightMargin = 5.000000000000000000
    Margins.BottomMargin = 5.000000000000000000
    DataSource = fPrinc.dsProd
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    PageSetup.PaperSize = fpCustom
    PageSetup.PaperWidth = 95.000000000000000000
    PageSetup.PaperHeight = 300.000000000000000000
    PrintDialog = False
    object RLBand2: TRLBand
      Left = 0
      Top = 0
      Width = 340
      Height = 33
      BandType = btHeader
      Borders.Sides = sdCustom
      Borders.DrawLeft = False
      Borders.DrawTop = False
      Borders.DrawRight = False
      Borders.DrawBottom = True
      object rlNomeEmp: TRLMemo
        Left = 80
        Top = 8
        Width = 186
        Height = 19
        Alignment = taCenter
        Behavior = [beSiteExpander]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object RLBand4: TRLBand
      Left = 0
      Top = 73
      Width = 340
      Height = 20
      BandType = btTitle
      Borders.Sides = sdCustom
      Borders.DrawLeft = False
      Borders.DrawTop = False
      Borders.DrawRight = False
      Borders.DrawBottom = True
      object RLLabel2: TRLLabel
        Left = 5
        Top = 1
        Width = 56
        Height = 16
        Caption = 'Produto'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RLLabel3: TRLLabel
        Left = 200
        Top = 0
        Width = 29
        Height = 16
        Caption = 'QTD'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RLLabel4: TRLLabel
        Left = 299
        Top = 1
        Width = 38
        Height = 16
        Caption = 'Valor'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object RLBand5: TRLBand
      Left = 0
      Top = 118
      Width = 340
      Height = 113
      BandType = btSummary
      Borders.Sides = sdCustom
      Borders.DrawLeft = False
      Borders.DrawTop = True
      Borders.DrawRight = False
      Borders.DrawBottom = False
      object RLMemo1: TRLMemo
        Left = 125
        Top = 67
        Width = 82
        Height = 13
        Alignment = taCenter
        Behavior = [beSiteExpander]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Lines.Strings = (
          'BBI Food')
        ParentFont = False
      end
      object RLDraw3: TRLDraw
        Left = 166
        Top = 111
        Width = 1
        Height = 1
      end
      object RLMemo2: TRLMemo
        Left = 94
        Top = 27
        Width = 156
        Height = 19
        Alignment = taCenter
        Behavior = [beSiteExpander]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Lines.Strings = (
          'Bom Apetite!')
        ParentFont = False
      end
    end
    object RLBand1: TRLBand
      Left = 0
      Top = 93
      Width = 340
      Height = 25
      object RLDBText2: TRLDBText
        Left = 194
        Top = 3
        Width = 42
        Height = 16
        Alignment = taCenter
        AutoSize = False
        DataField = 'qtd'
        DataSource = fPrinc.dsProd
        DisplayMask = '#0.000'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Text = ''
      end
      object RLDBText3: TRLDBText
        Left = 268
        Top = 3
        Width = 69
        Height = 16
        Alignment = taRightJustify
        AutoSize = False
        DataField = 'VrTotal'
        DataSource = fPrinc.dsProd
        DisplayMask = 'R$ #,###,##0.00'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Text = ''
      end
      object RLDBMemo1: TRLDBMemo
        Left = 5
        Top = 3
        Width = 172
        Height = 16
        Behavior = [beSiteExpander]
        DataField = 'Descricao'
        DataSource = fPrinc.dsProd
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
    end
    object RLBand3: TRLBand
      Left = 0
      Top = 33
      Width = 340
      Height = 40
      BandType = btHeader
      Borders.Sides = sdCustom
      Borders.DrawLeft = False
      Borders.DrawTop = False
      Borders.DrawRight = False
      Borders.DrawBottom = True
      object RLSystemInfo3: TRLSystemInfo
        Left = 5
        Top = 23
        Width = 43
        Height = 14
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Text = ''
      end
      object RLSystemInfo4: TRLSystemInfo
        Left = 293
        Top = 23
        Width = 44
        Height = 14
        Alignment = taRightJustify
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Info = itHour
        ParentFont = False
        Text = ''
      end
      object rlComanda2: TRLLabel
        Left = 94
        Top = 5
        Width = 142
        Height = 19
        Alignment = taCenter
        Caption = 'Comanda: 01999'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
end
