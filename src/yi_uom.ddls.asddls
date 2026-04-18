@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for Uom'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_UOM as 
    select from I_UnitOfMeasure
    association [1..1] to I_UnitOfMeasureText as _Text 
        on _Text.UnitOfMeasure = $projection.UomCode and _Text.Language = $session.system_language
{
    key UnitOfMeasure as UomCode,
    _Text.UnitOfMeasureName as UomName,
    _Text
}
