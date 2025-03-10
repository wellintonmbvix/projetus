unit model.api.error;

interface

type
  TAPIError = class
    private
      Ferror: String;
    public
      property error: String read Ferror write Ferror;
  end;

implementation

end.
