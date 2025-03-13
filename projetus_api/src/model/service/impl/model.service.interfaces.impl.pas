unit model.service.interfaces.impl;

interface

uses
  System.StrUtils,
  System.Generics.Collections,
  System.SysUtils,

  dbebr.factory.interfaces,
  dbebr.factory.firedac,
//  ormbr.dml.generator.mysql,
  ormbr.dml.generator.postgresql,
  ormbr.container.objectset.interfaces,
  ormbr.container.objectset,
//  ormbr.container.fdmemtable,
  ormbr.container.clientdataset,

  firedac.Comp.Client,

  model.resource.interfaces,
  model.resource.impl.factory,
  model.service.interfaces;

type
  TServiceORMBr<T: class, constructor> = class(TInterfacedObject, IService<T>)
  private
    FParent: T;
    FConnection: IConnection;
    FConnectionORM: IDBConnection;
    FORMBrContainer: IContainerObjectSet<T>;
  public
    constructor Create(aParent: T);
    destructor Destroy; override;
    class function New(aParent: T): IService<T>;

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
      var nRecords: Integer): IService<T>;
    function GetId(aFilter: String; var aList: TObjectList<T>): IService<T>;
  end;

implementation

{ TServiceORMBr<T> }

constructor TServiceORMBr<T>.Create(aParent: T);
begin
  FParent := aParent;

  FConnection := TResource.New.Connection;
  FConnectionORM := TFactoryFiredac.Create(TFDConnection(FConnection.Connect), dnPostgreSQL);
//  FConnectionORM := TFactoryFiredac.Create(TFDConnection(FConnection.Connect), dnMySQL);
  FORMBrContainer := TContainerObjectSet<T>.Create(FConnectionORM);
end;

function TServiceORMBr<T>.Delete: IService<T>;
begin
  Result := Self;
  FORMBrContainer.Delete(FParent);
end;

destructor TServiceORMBr<T>.Destroy;
begin
  inherited;
end;

function TServiceORMBr<T>.Insert: IService<T>;
begin
  Result := Self;
  FORMBrContainer.Insert(FParent);
end;

function TServiceORMBr<T>.ListAll(aFilter: String; var aList: TObjectList<T>;
  const aOrderBy: String): IService<T>;
begin
  Result := Self;
  aList := FORMBrContainer.FindWhere(aFilter, aOrderBy);
end;

function TServiceORMBr<T>.ListByGuid(aField, aGuid: String;
  var aList: TObjectList<T>): IService<T>;
begin
  Result := Self;
  aList := FORMBrContainer.FindWhere(Format(aField + ' = %s',
    [QuotedStr(aGuid)]));
  if Assigned(aList) and (aList.Count > 0) then
    FParent := aList.First;
end;

function TServiceORMBr<T>.ListById(aField: String; aId: Integer;
  var oEntity: T): IService<T>;
begin
  Result := Self;
  oEntity := FORMBrContainer.Find(aId);
  if Assigned(oEntity) then
    FParent := oEntity;
end;

function TServiceORMBr<T>.ListById(aField: String; aId: Integer): IService<T>;
begin
  Result := Self;
  var
  LList := FORMBrContainer.FindWhere(Format(aField + ' = %d', [aId]));
  if Assigned(LList) and (LList.Count > 0) then
    FParent := LList.First;
end;

function TServiceORMBr<T>.ListPaginate(aFilter: String;
  var aList: TObjectList<T>; const aOrderBy: String;
  aPageSize, aPageNext: Integer): IService<T>;
begin
  Result := Self;
  aList := FORMBrContainer.NextPacket(aFilter, aOrderBy, aPageSize, aPageNext);
end;

function TServiceORMBr<T>.Modify(AValue: T): IService<T>;
begin
  Result := Self;
  FORMBrContainer.Modify(FParent);
end;

class function TServiceORMBr<T>.New(aParent: T): IService<T>;
begin
  Result := Self.Create(aParent);
end;

function TServiceORMBr<T>.This: T;
begin
  Result := FParent;
end;

function TServiceORMBr<T>.Update: IService<T>;
begin
  Result := Self;
  FORMBrContainer.Update(FParent);
end;

function TServiceORMBr<T>.GetId(aFilter: String;
  var aList: TObjectList<T>): IService<T>;
begin
  Result := Self;
  aList := FORMBrContainer.FindWhere(aFilter);
  if Assigned(aList) and (aList.Count > 0) then
    FParent := aList.First;
end;

function TServiceORMBr<T>.GetRecordsNumber(aTableName, aFilter: String;
  var nRecords: Integer): IService<T>;
var
  vQry : TFDQuery;
begin
  Result := Self;
  vQry := TFDQuery.Create(nil);
  Try
    With vQry Do
      Begin
        Connection := TFDConnection(FConnection.Connect);
        SQL.Add('SELECT COUNT(*) FROM '+aTableName);
        if aFilter.Length > 0 then
          SQL.Add('WHERE '+aFilter);
        Open;
        nRecords := Fields[0].AsInteger;
      End;
  Finally
    FreeAndNil(vQry);
  End;
end;

end.
