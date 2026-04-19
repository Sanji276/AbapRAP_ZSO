@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface For Attachements'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_OATCH
  as select from yoatch
  association to parent YI_ORDR as _order on _order.Docentry = $projection.Docentry
{
  key attach_id  as AttachId,
      docentry   as Docentry,
      @Semantics.largeObject: {
          mimeType: 'Mimetype',
          fileName: 'Filename',
          acceptableMimeTypes: [ 'application/pdf',
                                 'image/png',
                                 'image/jpeg',
                                 'application/vnd.ms-excel',
                                 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
          contentDispositionPreference: #ATTACHMENT
      }
      attachment as Attachment,
      comments   as Comments,
      @Semantics.mimeType: true
      mimetype   as Mimetype,
      
      filename   as Filename,
      _order
}
