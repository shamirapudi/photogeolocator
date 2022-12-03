unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,
  FMX.StdCtrls, FMX.Controls.Presentation, System.Sensors.Components, FMX.Media,
  FMX.ScrollBox, FMX.Memo, FMX.Objects,
  FMX.MediaLibrary, FMX.Platform, System.Messaging, FMX.TabControl,
  FMX.WebBrowser, FMX.StdActns, FMX.ActnList, System.Actions,
  FMX.MediaLibrary.Actions;

type
  TForm1 = class(TForm)
    CameraComponent1: TCameraComponent;
    LocationSensor1: TLocationSensor;
    Button1: TButton;
    Image1: TImage;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    WebBrowser1: TWebBrowser;
    Button2: TButton;
    ActionList1: TActionList;
    TakePhotoFromCameraAction1: TTakePhotoFromCameraAction;
    Button3: TButton;
    TakePhotoFromLibraryAction1: TTakePhotoFromLibraryAction;

    procedure LocationSensor1LocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure Button1Click(Sender: TObject);
    procedure TakePhotoFromCameraAction1DidFinishTaking(Image: TBitmap);
    procedure TakePhotoFromLibraryAction1DidFinishTaking(Image: TBitmap);

  private
    { Private declarations }
    FGeocoder: TGeocoder;
   procedure OnGeocodeReverseEvent(const Address: TCivicAddress);
   //CAMERA
    procedure DoDidFinish(Image: TBitmap);
    procedure DoMessageListener(const Sender: TObject; const M: TMessage);



  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  geo_info:string;
 // CameraComponentForm : TCameraComponentForm;


implementation


{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  Service: IFMXCameraService;
  Params: TParamsPhotoQuery;
begin
 //button1 uses the camera component,it is hidden because it does
 //not work properly on android 10

  if TPlatformServices.Current.SupportsPlatformService(IFMXCameraService,
    Service) then
  begin
    //Params.Editable := True;
    Params.NeedSaveToAlbum := True;
    Params.RequiredResolution := TSize.Create(640, 640);
    Params.OnDidFinishTaking := DoDidFinish;
    Service.TakePhoto(Button1, Params);

  end
  else
    ShowMessage('This device does not support the camera service');

end;


procedure TForm1.DoDidFinish(Image: TBitmap);
begin
 Image1.Bitmap.Assign(Image);
end;

procedure TForm1.DoMessageListener(const Sender: TObject; const M: TMessage);
begin
 if M is TMessageDidFinishTakingImageFromLibrary then
    Image1.Bitmap.Assign(TMessageDidFinishTakingImageFromLibrary(M).Value);
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
var
  LDecSeparator: String;
  Sdata:double;
  Sdata_2:double;
  URLString: String;
begin
   LDecSeparator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  Sdata:= NewLocation.Latitude;
  Sdata_2:= NewLocation.Longitude;
  URLString := 'https://maps.google.com/maps?q=' + FloatToStr(Sdata)+ ','+
   FloatToStr(Sdata_2);
   WebBrowser1.Navigate(URLString);

//implement a feature to watermark the image with the geolocation details
  //Image1.Canvas.Font.Size:= 11;
  //Image1.Canvas.


 try
    // Setup an instance of TGeocoder
    if not Assigned(FGeocoder) then
    begin
      if Assigned(TGeocoder.Current) then
        FGeocoder := TGeocoder.Current.Create;
      if Assigned(FGeocoder) then
        FGeocoder.OnGeocodeReverse := OnGeocodeReverseEvent;
    end;

    // Translate location to address
    if Assigned(FGeocoder) and not FGeocoder.Geocoding then
      FGeocoder.GeocodeReverse(NewLocation);
  except
    Label1.Text := 'Geocoder service error';
  end;
end;

procedure TForm1.OnGeocodeReverseEvent(const Address: TCivicAddress);

begin
Label1.Text:= Address.AdminArea;
Label2.Text:= Address.CountryCode;
Label3.Text:= Address.CountryName;
Label5.Text:= Address.Locality;
Label6.Text:= Address.PostalCode;
Label7.Text:= Address.SubAdminArea;
Label8.Text:= Address.SubLocality;
Label9.Text := Address.SubThoroughfare;
Label10.Text:= Address.Thoroughfare;


end;



procedure TForm1.TakePhotoFromCameraAction1DidFinishTaking(Image: TBitmap);
begin
 Image1.Bitmap.Assign(Image);
 LocationSensor1.Active := True;
end;

procedure TForm1.TakePhotoFromLibraryAction1DidFinishTaking(Image: TBitmap);
begin
//load image from storage
  Image1.Bitmap.Assign(Image);
end;

end.
