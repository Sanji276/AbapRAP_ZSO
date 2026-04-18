@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for order header table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity YI_ORDR as 
    select from yordr
    composition [1..*] of YI_RDR1 as _item
{    
    key yordr.docentry as Docentry,
    yordr.series as Series,
    yordr.docnum as Docnum,
    yordr.docdate as Docdate,
    yordr.docduedate as Docduedate,
    yordr.taxdate as Taxdate,
    yordr.cardcode as Cardcode,
    yordr.cardname as Cardname,
    yordr.numatcard as Numatcard,
    yordr.billtoaddress as Billtoaddress,
    yordr.shiptoaddress as Shiptoaddress,
    yordr.comments as Comments,
    yordr.doccur as Doccur,
    @Semantics.amount.currencyCode: 'Doccur'
    yordr.taxableamt as Taxableamt,
    @Semantics.amount.currencyCode: 'Doccur'
    yordr.taxamt as Taxamt,
    @Semantics.amount.currencyCode: 'Doccur'
    yordr.discount as Discount,
    @Semantics.amount.currencyCode: 'Doccur'
    yordr.doctotal as Doctotal,
    yordr.docstatus as Docstatus,
    yordr.created_by as CreatedBy,
    yordr.created_at as CreatedAt,
    yordr.lastchangedat as Lastchangedat,
    yordr.locallastchangedat as Locallastchangedat,
    _item
}
