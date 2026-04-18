@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for Currency'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_CURRENCY 
    as select from I_Currency
    association [1..1] to I_CurrencyText as _text 
        on _text.Currency = $projection.CurrCode and _text.Language = $session.system_language
{
   key Currency as CurrCode,
   _text.CurrencyName as CurrName,
   _text
}
