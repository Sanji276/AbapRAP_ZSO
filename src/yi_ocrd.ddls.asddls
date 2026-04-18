@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for business partners'
@Metadata.ignorePropagatedAnnotations: true
define root view entity YI_OCRD 
    as select from yocrd
{
    key cardcode as Cardcode,
    key id      as Id,
    cardname as Cardname,
    cardtype as Cardtype,
    billaddress as Billaddress,
    shipaddress as Shipaddress,
    pannum as Pannum,
    mobile as Mobile,
    isactive as Isactive,
    created_by as CreatedBy,
    created_at as CreatedAt,
    lastchangedat as Lastchangedat,
    locallastchangedat as Locallastchangedat
}
