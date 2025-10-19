unit model.service.interfaces;

interface

uses
  System.Generics.Collections;

type
  IService<T: Class> = interface(IInterface)
    ['{8BED4E07-524F-42A2-8443-9C79F319E385}']

    function ListAll(aFilter: String; var aList: TObjectList<T>;
      const aOrderBy: String = ''): IService<T>;
    function ListPaginate(aFilter: String; var aList: TObjectList<T>;
      const aOrderBy: String = ''; aPageSize: Integer = 10;
      aPageNext: Integer = 1): IService<T>;
    function ListById(aField: String; aId: Integer): IService<T>; overload;
    function ListById(aField: String; aId: Integer; var oEntity: T)
      : IService<T>; overload;
    function ListByGuid(aField, aGuid: String; var aList: TObjectList<T>)
      : IService<T>; overload;
    function Insert: IService<T>;
    function Modify(AValue: T): IService<T>;
    function Update: IService<T>;
    function Delete: IService<T>;
    function This: T;
    function GetRecordsNumber(aTableName: String; aFilter: String;
      var nRecords: Integer; stringJoin: String = ''): IService<T>;
    function GetId(aFilter: String; var aList: TObjectList<T>): IService<T>;
  end;

implementation

end.
