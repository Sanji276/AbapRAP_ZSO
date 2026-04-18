@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View For Business partner'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity YC_OCRD
  provider contract transactional_query 
    as projection on YI_OCRD
{
    key Cardcode,
    key Id,
    Cardname,
    Cardtype,
    Billaddress,
    Shipaddress,
    Pannum,
    Mobile,
    Isactive,
    CreatedAt,
    CreatedBy,
    Lastchangedat,
    Locallastchangedat
}
