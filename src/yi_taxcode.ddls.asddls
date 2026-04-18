@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface For taxcode'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_TAXCODE 
    as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'YDOMTAXCODE' )
{
key domain_name,
key value_position,

    value_low as Value,
    text as Description
}
where language = $session.system_language
