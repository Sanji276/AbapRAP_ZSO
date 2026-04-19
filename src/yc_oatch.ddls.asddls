@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for attachments'
@Metadata.allowExtensions: true
define view entity YC_OATCH 
    as projection on YI_OATCH
{
    key AttachId,
    Docentry,
    Attachment,
    Comments,
    Mimetype,
    Filename,
    _order.Docnum as DocNum,
      _order.Cardname as CardName,
    /* Associations */
    _order : redirected to parent YC_ORDR
}
