unit model.api.message;

interface

type
  TAPIMessage = class
  private
    Fmessage: String;
  public
    property message: String read Fmessage write Fmessage;
  end;

implementation

end.
