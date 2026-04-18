@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for BP cardtype'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_CARDTYPE 
    as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'YCARDTYPE' )
{
    key domain_name,
    key value_position,
    key language,
    value_low as Value,
    text as Description
}
