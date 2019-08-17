unit UFrmPrincipalImpl;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    edtDocumentoCliente: TLabeledEdit;
    cmbTamanhoPizza: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    cmbSaborPizza: TComboBox;
    Button1: TButton;
    mmRetornoWebService: TMemo;
    Label3: TLabel;
    edtEnderecoBackend: TLabeledEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  WSDLPizzariaBackendControllerImpl, Rtti, REST.JSON, UPizzaTamanhoEnum,
  UPizzaSaborEnum, UPedidoRetornoDTOImpl;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  oPizzariaBackendController: IPizzariaBackendController;
begin
  if edtDocumentoCliente.Text = EmptyStr then
    begin
      Application.MessageBox('Prezado cliente informe o n� do pedido', 'Aten��o', MB_OK + MB_ICONWARNING);
      edtDocumentoCliente.SetFocus;
    end
  else
  if cmbTamanhoPizza.ItemIndex < 0 then
    begin
      Application.MessageBox('Escolha um tamanho de pizza', 'Aten��o', MB_OK + MB_ICONWARNING);
      cmbTamanhoPizza.SetFocus;
    end
  else
  if cmbSaborPizza.ItemIndex < 0 then
    begin
      Application.MessageBox('Escolha um sabor de pizza', 'Aten��o', MB_OK + MB_ICONWARNING);
      cmbSaborPizza.SetFocus;
    end
  else
    begin
      oPizzariaBackendController := WSDLPizzariaBackendControllerImpl.GetIPizzariaBackendController(edtEnderecoBackend.Text);
      mmRetornoWebService.Text := TJson.ObjectToJsonString(oPizzariaBackendController.efetuarPedido(
      TRttiEnumerationType.GetValue<TPizzaTamanhoEnum>(cmbTamanhoPizza.Text),
      TRttiEnumerationType.GetValue<TPizzaSaborEnum>(cmbSaborPizza.Text), edtDocumentoCliente.Text));
       Application.MessageBox('Pedido realizado com sucesso!', 'Aten��o', MB_OK + MB_ICONINFORMATION);
    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  oPizzariaBackendController: IPizzariaBackendController;
  oDTO : TPedidoRetornoDTO;
begin
  if edtDocumentoCliente.Text = EmptyStr then
    exit;

  oPizzariaBackendController := WSDLPizzariaBackendControllerImpl.GetIPizzariaBackendController(edtEnderecoBackend.Text);

  oDTO := oPizzariaBackendController.consultarPedido(edtDocumentoCliente.Text);
  mmRetornoWebService.Clear;

  mmRetornoWebService.Lines.Add('Tamanho da Pizza: '+ Copy(
                                                            TRttiEnumerationType.GetName<TPizzaTamanhoEnum>(oDTO.PizzaTamanho),
                                                            3,
                                                            length(TRttiEnumerationType.GetName<TPizzaTamanhoEnum>(oDTO.PizzaTamanho))
                                                          )
                                );
  mmRetornoWebService.Lines.Add('Sabor da Pizza  : '+ Copy(
                                                            TRttiEnumerationType.GetName<TPizzaSaborEnum>(oDTO.PizzaSabor),
                                                            3,
                                                            length(TRttiEnumerationType.GetName<TPizzaSaborEnum>(oDTO.PizzaSabor))
                                                          )
                                );

  mmRetornoWebService.Lines.Add('Pre�o da Pizza  : '+ FormatCurr('R$0.00',oDTO.ValorTotalPedido));

  mmRetornoWebService.Lines.Add('Tempo de Preparo: '+ oDTO.TempoPreparo.ToString + ' minutos.');
end;

end.
