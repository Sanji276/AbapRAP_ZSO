@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View For Order Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity YC_ORDR
  provider contract transactional_query 
    as projection on YI_ORDR
{
    key Docentry,
    Series,
    Docnum,
    Docdate,
    Docduedate,
    Taxdate,
    Cardcode,
    Cardname,
    Numatcard,
    Billtoaddress,
    Shiptoaddress,
    Comments,
    Doccur,
    @Semantics.amount.currencyCode: 'Doccur'
    Taxableamt,
    @Semantics.amount.currencyCode: 'Doccur'
    Taxamt,
    @Semantics.amount.currencyCode: 'Doccur'
    Discount,
    @Semantics.amount.currencyCode: 'Doccur'
    Doctotal,
    Docstatus,
    CreatedBy,
    CreatedAt,
    Lastchangedat,
    Locallastchangedat,
    /* Associations */
    _item : redirected to composition child YC_RDR1
  
}
