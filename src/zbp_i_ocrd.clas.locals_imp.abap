CLASS lhc__cardcode DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR cardcode RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR cardcode RESULT result.

    METHODS setactive FOR MODIFY
      IMPORTING keys FOR ACTION cardcode~setactive RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR cardcode RESULT result.

ENDCLASS.

CLASS lhc__cardcode IMPLEMENTATION.


  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF YI_OCRD
    IN LOCAL MODE
    ENTITY cardcode
    FIELDS ( IsActive )
    WITH CORRESPONDING #( keys )
    RESULT DATA(LT_RESULT).

    RESULT = VALUE #(
        FOR ROW IN LT_RESULT
        (
            %tky = row-%tky
            %action-setActive = COND #( WHEN row-Isactive = abap_true then if_abap_behv=>fc-o-disabled
                                                                      else if_abap_behv=>fc-o-enabled
                                                 )
        )
     ).

  ENDMETHOD.

  METHOD setActive.
    MODIFY ENTITIES OF YI_OCRD
    IN LOCAL MODE
    ENTITY cardcode
    UPDATE FIELDS ( Isactive )
    WITH VALUE #(
        FOR KEY IN KEYS
        (
            %tky = key-%tky
            Isactive = abap_true
        )
     ).

     READ ENTITIES OF YI_OCRD
     IN LOCAL MODE
     ENTITY cardcode
     ALL FIELDS WITH
     VALUE #(
        FOR KEY IN KEYS
        (
            %tky = KEY-%tky
        )
     ) RESULT DATA(LT_RESULT).

     RESULT = VALUE #(
        FOR ROW IN LT_RESULT
        (
            %tky = row-%tky
            %param = row
        )
       ).


  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
