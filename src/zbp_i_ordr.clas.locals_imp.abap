CLASS lhc_oatch DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE oatch.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE oatch.

    METHODS read FOR READ
      IMPORTING keys FOR READ oatch RESULT result.

    METHODS rba_Order FOR READ
      IMPORTING keys_rba FOR READ oatch\_Order FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_oatch IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Order.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ORDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ordr RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ordr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ordr RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE ordr.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ordr.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE ordr.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE ordr.

    METHODS read FOR READ
      IMPORTING keys FOR READ ordr RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK ordr.

    METHODS rba_Item FOR READ
      IMPORTING keys_rba FOR READ ordr\_Item FULL result_requested RESULT result LINK association_links.

    METHODS cba_Item FOR MODIFY
      IMPORTING entities_cba FOR CREATE ordr\_Item.

    METHODS set_docnum FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ordr~set_docnum.

    METHODS setCardname FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ordr~setCardname.

    METHODS precheck_cba_Item FOR PRECHECK
      IMPORTING entities FOR CREATE ordr\_Item.
    METHODS rba_Attachments FOR READ
      IMPORTING keys_rba FOR READ ordr\_Attachments FULL result_requested RESULT result LINK association_links.

    METHODS cba_Attachments FOR MODIFY
      IMPORTING entities_cba FOR CREATE ordr\_Attachments.


ENDCLASS.

CLASS lhc_ORDR IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
    ycl_order_api=>get_instance(  )->create_header(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD earlynumbering_create.
    ycl_order_api=>get_instance(  )->earlynumbering_create(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.

*    READ ENTITIES OF yi_ordr IN LOCAL MODE
*    ENTITY ordr
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_result).

    ycl_order_api=>get_instance(  )->delete_order(
      EXPORTING
        keys     = keys
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

*    LOOP AT lt_result INTO DATA(ls_order).
*    DELETE FROM yordr
*      WHERE docentry = @ls_order-Docentry.
*    IF sy-subrc <> 0.
*      APPEND VALUE #( %tky = ls_order-%tky ) TO failed-ordr.
*    ENDIF.
*  ENDLOOP.

  ENDMETHOD.

  METHOD read.

    SELECT *
  FROM yordr
  FOR ALL ENTRIES IN @keys
  WHERE docentry = @keys-docentry
  INTO TABLE @DATA(lt_result).

    result = VALUE #(
        FOR order IN lt_result
        (
            %key-Docentry = order-docentry
        )
     ).

  ENDMETHOD.

  METHOD lock.


    TRY.
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EYLOCK_ORDR' ).

        LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_order>).
          TRY.
              lock->enqueue(
*              it_table_mode =
                it_parameter  = VALUE #( ( name = 'DOCENTRY' value = REF #( <lfs_order>-Docentry  ) ) )
*              _scope        =
*              _wait         =
              ).

            CATCH cx_abap_foreign_lock INTO DATA(ls_foreign_lock).
              APPEND VALUE #(
                  %key-docentry = <lfs_order>-Docentry
                  %msg = new_message_with_text(
                           severity = if_abap_behv_message=>severity-error
                           text     = 'Object Order is locked by user: ' && ls_foreign_lock->user_name && '. You cannot delete this object.'
                         )
               ) TO reported-ordr.

              APPEND VALUE #( %key-docentry = <lfs_order>-Docentry ) TO failed-ordr.

          ENDTRY.

        ENDLOOP.




      CATCH cx_abap_lock_failure INTO DATA(exception).
        DATA(lv_ex_msg) = exception->get_text( ).
        RAISE SHORTDUMP exception.
    ENDTRY.




  ENDMETHOD.

  METHOD rba_Item.
  ENDMETHOD.

  METHOD cba_Item.
    ycl_order_api=>get_instance(  )->create_ba_item(
      EXPORTING
        entities_cba = entities_cba
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.


  METHOD set_docnum.
    READ ENTITIES OF yi_ordr IN LOCAL MODE
    ENTITY ordr
    FIELDS ( docentry docstatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_order).
      MODIFY ENTITIES OF yi_ordr IN LOCAL MODE
      ENTITY ordr
      UPDATE
      FIELDS ( docnum docstatus )
      WITH VALUE #(
      (
        %tky = ls_order-%tky

        docnum = ls_order-docentry + 100000
        docstatus = 'O'

        %control-docnum    = if_abap_behv=>mk-on
        %control-docstatus = if_abap_behv=>mk-on
      )
    ).

    ENDLOOP.

  ENDMETHOD.

  METHOD setCardname.
    READ ENTITIES OF yi_ordr IN LOCAL MODE
    ENTITY ordr
    FIELDS ( cardcode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_order).

      SELECT SINGLE cardname FROM yocrd WHERE cardcode = @ls_order-Cardcode INTO @DATA(lv_cardname).
      MODIFY ENTITIES OF yi_ordr IN LOCAL MODE
      ENTITY ordr
      UPDATE
      FIELDS ( cardname )
      WITH VALUE #(
      (
        %tky = ls_order-%tky
        cardname = lv_cardname
        %control-cardname    = if_abap_behv=>mk-on
      )
    ).

    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_cba_item.

    "DATA: lt_headers TYPE TABLE FOR READ RESULT yi_ordr.

    READ ENTITIES OF yi_ordr
      IN LOCAL MODE
      ENTITY ordr
      FIELDS ( cardcode doccur )
      WITH CORRESPONDING #( entities )
      RESULT DATA(lt_headers).

    LOOP AT entities INTO DATA(ls_entity).

*      READ TABLE lt_headers INTO DATA(ls_header)
*        WITH  KEY docentry = ls_entity-%tky-docentry.

      TRY.
          DATA(ls_header) = lt_headers[
            KEY entity
            docentry = ls_entity-%tky-docentry
          ].
        CATCH cx_sy_itab_line_not_found.
          CONTINUE.
      ENDTRY.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(lv_error) = abap_false.

      IF ls_header-cardcode IS INITIAL.
        lv_error = abap_true.

        APPEND VALUE #(
          %tky = ls_entity-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Please select customer code.'
          )
        ) TO reported-ordr.
      ENDIF.

      IF ls_header-doccur IS INITIAL.
        lv_error = abap_true.

        APPEND VALUE #(
          %tky = ls_entity-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Please select currency.'
          )
        ) TO reported-ordr.
      ENDIF.

      IF lv_error = abap_true.
        APPEND VALUE #( %tky = ls_entity-%tky ) TO failed-ordr.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD rba_Attachments.
  ENDMETHOD.

  METHOD cba_Attachments.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_RDR1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE rdr1.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE rdr1.

    METHODS read FOR READ
      IMPORTING keys FOR READ rdr1 RESULT result.

    METHODS rba_Header FOR READ
      IMPORTING keys_rba FOR READ rdr1\_Header FULL result_requested RESULT result LINK association_links.

    METHODS setHeaderDocCurr FOR DETERMINE ON MODIFY
      IMPORTING keys FOR rdr1~setHeaderDocCurr.
    METHODS calculateLineTotal FOR DETERMINE ON MODIFY
      IMPORTING keys FOR rdr1~calculateLineTotal.

    METHODS calculateTaxAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR rdr1~calculateTaxAmount.


ENDCLASS.

CLASS lhc_RDR1 IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Header.
  ENDMETHOD.


  METHOD setHeaderDocCurr.

    READ ENTITIES OF yi_ordr IN LOCAL MODE
    ENTITY rdr1 BY \_header
      FIELDS ( doccur )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_headers)
    LINK DATA(lt_links).

    LOOP AT lt_links INTO DATA(ls_link).

*      READ TABLE lt_headers INTO DATA(ls_header)
*          WITH KEY docentry = ls_link-target-%key-Docentry.

      DATA(ls_header) = lt_headers[
                                        KEY entity
                                        Docentry = ls_link-target-%key-Docentry ].

      IF sy-subrc = 0 AND ls_header-Doccur IS NOT INITIAL.

        MODIFY ENTITIES OF yi_ordr IN LOCAL MODE
        ENTITY rdr1
         UPDATE FIELDS ( Currency )
         WITH VALUE #(
          (
              %tky = ls_link-source-%tky
              Currency = ls_header-Doccur
          )

        )
        REPORTED DATA(lt_reported).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD calculateLineTotal.

    READ ENTITIES OF yi_ordr IN LOCAL MODE
    ENTITY rdr1
    FIELDS ( Quantity Price Taxamount )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    LOOP AT lt_items INTO DATA(ls_item).
      DATA(lv_linetotal) = CONV decfloat34( ( ls_item-Quantity * ls_item-Price ) + ls_item-Taxamount ).

      MODIFY ENTITIES OF yi_ordr IN LOCAL MODE
      ENTITY rdr1
      UPDATE FIELDS ( linetotal )
      WITH VALUE #( (
            %tky = ls_item-%tky
            linetotal = lv_linetotal
            %control-linetotal = if_abap_behv=>mk-on
       ) )
       REPORTED lt_reported
       FAILED lt_failed
       .
    ENDLOOP.

  ENDMETHOD.

  METHOD calculateTaxAmount.

    READ ENTITIES OF yi_ordr IN LOCAL MODE
      ENTITY rdr1
      FIELDS ( Itemcode Unit Quantity Price Taxcode Taxamount )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items)
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    "DATA(lv_total_taxamount) = CONV decfloat34( '0.00' ).

    LOOP AT lt_items INTO DATA(ls_item).

      IF ls_item-Itemcode IS INITIAL OR ls_item-Unit     IS INITIAL
      OR ls_item-Price    IS INITIAL OR ls_item-Quantity IS INITIAL.

        APPEND VALUE #(
          %tky = ls_item-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Please select itemcode, unit, price & quantity.'
                 )
        ) TO reported-rdr1.

        IF ls_item-Taxcode IS NOT INITIAL.
          MODIFY ENTITIES OF yi_ordr IN LOCAL MODE
            ENTITY rdr1
              UPDATE FIELDS ( Taxcode )
              WITH VALUE #( (
                %tky             = ls_item-%tky
                Taxcode          = ''
                %control-Taxcode = if_abap_behv=>mk-on
              ) )
            FAILED   DATA(lt_update_failed)
            REPORTED DATA(lt_update_reported).
        ENDIF.

      ELSE.

        DATA(lv_taxamount) = COND decfloat34(
                               WHEN ls_item-Taxcode = 'VAT@13'
                                 THEN ls_item-Quantity * ls_item-Price * CONV decfloat34( '0.13' )
                               WHEN ls_item-Taxcode = 'VAT@0'
                                 THEN CONV decfloat34( '0.00' )
                               WHEN ls_item-Taxcode = 'VAT13EX5'
                                 THEN ( ( ls_item-Quantity * ls_item-Price ) + ls_item-Quantity ) * CONV decfloat34( '0.13' )
                               ELSE CONV decfloat34( '0.00' )
                             ).

        MODIFY ENTITIES OF yi_ordr IN LOCAL MODE
          ENTITY rdr1
            UPDATE FIELDS ( Taxamount )
            WITH VALUE #( (
              %tky               = ls_item-%tky
              Taxamount          = lv_taxamount
              %control-Taxamount = if_abap_behv=>mk-on
            ) )
          FAILED  lt_update_failed
          REPORTED lt_update_reported.

      ENDIF.

    ENDLOOP.

    "updating the total tax amount
    READ ENTITIES OF yi_ordr IN LOCAL MODE
   ENTITY rdr1 BY \_header
   FIELDS ( Docentry )
   WITH CORRESPONDING #( keys )
   RESULT DATA(lt_header)
   LINK DATA(lt_links)
   REPORTED DATA(lt_header_reported)
   FAILED DATA(lt_header_failed).

    CHECK lt_links IS NOT INITIAL.
    DATA(ls_first_link) = lt_links[ 1 ].

    READ ENTITIES OF yi_ordr IN LOCAL MODE
    ENTITY ordr BY \_item
    FIELDS ( Taxamount )
    WITH VALUE #( (
      %tky = ls_first_link-target-%tky
    ) )
    RESULT DATA(lt_all_items)
    REPORTED DATA(lt_all_reported)
    FAILED DATA(lt_all_failed).

    DATA(lv_total_taxamount) = CONV decfloat34( '0.00' ).
    LOOP AT lt_all_items INTO DATA(ls_all_item).
      lv_total_taxamount = lv_total_taxamount + ls_all_item-Taxamount.
    ENDLOOP.

    MODIFY ENTITIES OF yi_ordr IN LOCAL MODE
    ENTITY ordr
      UPDATE FIELDS ( taxamt )
      WITH VALUE #( (
        %tky            = ls_first_link-target-%tky
        taxamt          = lv_total_taxamount
        %control-taxamt = if_abap_behv=>mk-on
      ) )
    FAILED   DATA(lt_update_header_failed)
    REPORTED DATA(lt_update_header_reported).

    reported-ordr = CORRESPONDING #( lt_update_header_reported-ordr ).


  ENDMETHOD.

ENDCLASS.

CLASS lsc_YI_ORDR DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_YI_ORDR IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.

    DATA(lt_error_orders) = ycl_order_api=>get_instance( )->check_before_save_item( ).

    LOOP AT lt_error_orders ASSIGNING FIELD-SYMBOL(<lfs_header>).
      APPEND VALUE #(
        %key-Docentry = <lfs_header>-docentry
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'At least one item row is required.' )
      ) TO reported-ordr.

      APPEND VALUE #( %key-Docentry = <lfs_header>-docentry ) TO failed-ordr.
    ENDLOOP.

  ENDMETHOD.

  METHOD save.
    ycl_order_api=>get_instance( )->save_order(
      CHANGING
        reported = reported
    ).

    CHECK ycl_order_api=>gt_order_delete_dockey IS NOT INITIAL.

    DELETE FROM yordr
    WHERE docentry IN  @ycl_order_api=>gt_order_delete_dockey.

    CLEAR: ycl_order_api=>gt_order_delete_dockey.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: ycl_order_api=>gt_header, ycl_order_api=>gt_item.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
