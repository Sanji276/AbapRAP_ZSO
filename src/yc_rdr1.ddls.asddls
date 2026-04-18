@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View For Order Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity YC_RDR1
  as projection on YI_RDR1
{
  key Id,
  key Docentry,
      Itemcode,
      Description,
      Unit,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Quantity,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      Price,
      @Semantics.amount.currencyCode: 'Currency'
      Linetotal,
      Whscode,
      Whsname,
      Taxcode,
      @Semantics.amount.currencyCode: 'Currency'
      Taxamount,
      Freetext,
      CreatedBy,
      CreatedAt,
      Lastchangedat,
      _header.Docnum as DocNum,
      _header.Cardname as CardName,
      /* Associations */
      _header : redirected to parent YC_ORDR
      
}
