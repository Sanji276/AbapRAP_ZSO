@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for order item table'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_RDR1 as 
    select from yrdr1
    association to parent YI_ORDR as _header on _header.Docentry = $projection.Docentry
{
    key id as Id,
    key docentry as Docentry,
    itemcode as Itemcode,
    description as Description,
    unit as Unit,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    quantity as Quantity,
    currency as Currency,
    @Semantics.amount.currencyCode: 'Currency'
    price as Price,
    @Semantics.amount.currencyCode: 'Currency'
    linetotal as Linetotal,
    whscode as Whscode,
    whsname as Whsname,
    taxcode as Taxcode,
    @Semantics.amount.currencyCode: 'Currency'
    taxamount as Taxamount,
    freetext as Freetext,
    created_by as CreatedBy,
    created_at as CreatedAt,
    lastchangedat as Lastchangedat,
    _header    
}
