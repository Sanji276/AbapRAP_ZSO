CLASS ycl_order_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS: get_instance RETURNING VALUE(ro_instance) TYPE REF TO ycl_order_api.

    TYPES: tt_create_order         TYPE TABLE FOR CREATE yi_ordr\\ordr,
           tt_mapped_early_order   TYPE RESPONSE FOR MAPPED EARLY yi_ordr,
           tt_failed_early_order   TYPE RESPONSE FOR FAILED EARLY yi_ordr,
           tt_reported_early_order TYPE RESPONSE FOR REPORTED EARLY yi_ordr,
           tt_reported_late_order  TYPE RESPONSE FOR REPORTED LATE yi_ordr,
           tt_delete_order         TYPE TABLE FOR DELETE yi_ordr\\ordr.

    TYPES: tt_create_order_item TYPE TABLE FOR CREATE yi_ordr\\ordr\_item,
           tt_header            TYPE TABLE OF yordr WITH EMPTY KEY.


    CLASS-DATA:
      gt_header              TYPE STANDARD TABLE OF yordr,
      gt_item                TYPE STANDARD TABLE OF yrdr1,
      gt_order_delete_dockey TYPE RANGE OF yordr-docentry.

    METHODS: earlynumbering_create
      IMPORTING entities TYPE tt_create_order
      CHANGING  mapped   TYPE tt_mapped_early_order
                failed   TYPE tt_failed_early_order
                reported TYPE tt_reported_early_order,

      earlynumbering_cba_Item
        IMPORTING entities TYPE tt_create_order_item
        CHANGING  mapped   TYPE tt_mapped_early_order
                  failed   TYPE tt_failed_early_order
                  reported TYPE tt_reported_early_order,

      create_header
        IMPORTING entities TYPE tt_create_order "table for create yi_ordr\\ordr [ derived type... ]
        CHANGING  mapped   TYPE tt_mapped_early_order "response for mapped early yi_ordr  [ derived type... ]
                  failed   TYPE tt_failed_early_order "response for failed early yi_ordr  [ derived type... ]
                  reported TYPE tt_reported_early_order, "response for reported early yi_ordr    [ derived type... ]


      create_ba_item
        IMPORTING entities_cba TYPE tt_create_order_item "table for create yi_ordr\\ordr\_item   [ derived type... ]
        CHANGING  mapped       TYPE tt_mapped_early_order "response for mapped early yi_ordr  [ derived type... ]
                  failed       TYPE tt_failed_early_order "response for failed early yi_ordr  [ derived type... ]
                  reported     TYPE tt_reported_early_order, "response for reported early yi_ordr    [ derived type... ]

      save_order
        CHANGING reported TYPE tt_reported_late_order,"response for reported late yi_ordr [ derived type... ]


      check_before_save_item
        RETURNING
          VALUE(rt_error_orders) TYPE tt_header, "returns headers that failed validation

      delete_order
        IMPORTING keys     TYPE tt_delete_order"table for delete yi_ordr\\ordr [ derived type... ]
        CHANGING  mapped   TYPE tt_mapped_early_order"response for mapped early yi_ordr  [ derived type... ]
                  failed   TYPE tt_failed_early_order "response for failed early yi_ordr  [ derived type... ]
                  reported TYPE tt_reported_early_order. "response for reported early yi_ordr    [ derived type... ]

*      check_required_itemdetails_exist_in_row
*        importing keys



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ycl_order_api IMPLEMENTATION.
  METHOD get_instance.
    DATA lv_instance TYPE REF TO ycl_order_api.
    lv_instance = ro_instance = COND #( WHEN lv_instance IS BOUND
                          THEN lv_instance
                          ELSE NEW #( ) ).
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA: lv_qty     TYPE i,
          lv_number  TYPE cl_numberrange_runtime=>nr_number,
          lv_current TYPE i.

    DATA(lt_entities) = entities.

    "Step 1: only new entities
    DELETE lt_entities WHERE docentry IS NOT INITIAL.

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    lv_qty = lines( lt_entities ).

    TRY.
        " STEP 1: Check interval exists
        DATA lt_intervals TYPE cl_numberrange_intervals=>nr_interval.

        cl_numberrange_intervals=>read(
          EXPORTING
            object   = 'YODRDOCKEY'
          IMPORTING
            interval = lt_intervals
        ).

      CATCH cx_nr_object_not_found.

        " STEP 2: Create interval if not exists
        DATA lt_new_intervals TYPE cl_numberrange_intervals=>nr_interval.
        DATA ls_new_interval   TYPE cl_numberrange_intervals=>nr_nriv_line.

        ls_new_interval-nrrangenr = '01'.
        ls_new_interval-fromnumber = '0000000001'.
        ls_new_interval-tonumber   = '0999999999'.
        ls_new_interval-nrlevel    = '0000000000'.
        ls_new_interval-externind  = abap_false.

        APPEND ls_new_interval TO lt_new_intervals.

        TRY.
            cl_numberrange_intervals=>create(
              EXPORTING
                object    = 'YODRDOCKEY'
                interval  = lt_new_intervals
            ).
          CATCH cx_number_ranges.
        ENDTRY.

      CATCH cx_number_ranges.
    ENDTRY.

    " STEP 3: Get number range values
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '01'
            object      = 'YODRDOCKEY'
            quantity    = CONV #( lv_qty )
          IMPORTING
            number            = lv_number
            returned_quantity = DATA(lv_returned_qty)
        ).
      CATCH cx_number_ranges.
        "handle exception
    ENDTRY.

    " STEP 4: Map numbers to RAP entities
    lv_current = lv_number - lv_returned_qty + 1.

    LOOP AT lt_entities INTO DATA(ls_entity).

      APPEND VALUE #(
        %cid      = ls_entity-%cid
        %key      = VALUE #( docentry = lv_current )
        %is_draft = ls_entity-%is_draft
      ) TO mapped-ordr.

      lv_current += 1.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_item.
    DATA(lt_entities) = entities.


    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

      LOOP AT <fs_entity>-%target ASSIGNING FIELD-SYMBOL(<fs_item>).
        TRY.
            DATA(lv_new_id) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16(  ).

            IF sy-subrc = 0.
              APPEND VALUE #(
                  %cid = <fs_item>-%cid
                  %key = VALUE #( Id = lv_new_id )
                  %is_draft = <fs_item>-%is_draft
              ) TO mapped-rdr1.
            ENDIF.

          CATCH cx_uuid_error.
        ENDTRY.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.



  METHOD create_header.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_header>).
      "GET TIME STAMP FIELD <lfs_header>-Lastchangedat.

      APPEND VALUE #(
        docentry      = <lfs_header>-Docentry
        docnum = <lfs_header>-Docnum
        series        = <lfs_header>-Series
        docdate       = <lfs_header>-Docdate
        docduedate    = <lfs_header>-Docduedate
        taxdate       = <lfs_header>-Taxdate
        cardcode      = <lfs_header>-Cardcode
        cardname      = <lfs_header>-Cardname
        numatcard     = <lfs_header>-Numatcard
        billtoaddress = <lfs_header>-Billtoaddress
        shiptoaddress = <lfs_header>-Shiptoaddress
        comments      = <lfs_header>-Comments
        doccur        = <lfs_header>-Doccur
        taxableamt    = <lfs_header>-Taxableamt
        taxamt        = <lfs_header>-Taxamt
        discount      = <lfs_header>-Discount
        doctotal      = <lfs_header>-Doctotal
        docstatus     = <lfs_header>-Docstatus
        created_by    = sy-uname
      ) TO gt_header.

      APPEND VALUE #(
        %cid = <lfs_header>-%cid
        %key-Docentry = <lfs_header>-%key-Docentry
      ) TO mapped-ordr.

    ENDLOOP.
  ENDMETHOD.



  METHOD create_ba_item.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<lfs_entity>).

      DATA(lv_docentry) = <lfs_entity>-Docentry.

      LOOP AT <lfs_entity>-%target ASSIGNING FIELD-SYMBOL(<lfs_item>).

        "GET TIME STAMP FIELD <lfs_item>-Lastchangedat.
        APPEND VALUE #(
          id        = <lfs_item>-Id
          docentry    = lv_docentry
          itemcode    = <lfs_item>-Itemcode
          description = <lfs_item>-Description
          unit        = <lfs_item>-Unit
          quantity    = <lfs_item>-Quantity
          currency    = <lfs_item>-Currency
          price       = <lfs_item>-Price
          linetotal   = <lfs_item>-Quantity * <lfs_item>-Price + <lfs_item>-Taxamount
          whscode     = <lfs_item>-Whscode
          whsname     = <lfs_item>-Whsname
          taxcode     = <lfs_item>-Taxcode
          taxamount   = <lfs_item>-Taxamount
          freetext    = <lfs_item>-Freetext
          created_by  = sy-uname
        ) TO gt_item.

        APPEND VALUE #(
          %cid = <lfs_item>-%cid
          %key-Id = <lfs_item>-%key-Id
          %key-Docentry = lv_docentry
        ) TO mapped-rdr1.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD save_order.

    CHECK gt_header IS NOT INITIAL.
    INSERT yordr FROM TABLE @gt_header.

    IF sy-subrc <> 0.

      LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<lfs_header>).
        APPEND VALUE #(
            %key-docentry = <lfs_header>-docentry

         ) TO reported-rdr1.


      ENDLOOP.
      CLEAR: gt_header, gt_item.
      RETURN.
    ENDIF.

    CHECK gt_item IS NOT INITIAL.
    INSERT yrdr1 FROM TABLE @gt_item.

    IF sy-subrc <> 0.

      LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<lfs_item>).
        APPEND VALUE #(
            %key-id = <lfs_item>-id
            %key-docentry = <lfs_item>-docentry
         ) TO reported-rdr1.


      ENDLOOP.
      CLEAR: gt_header, gt_item.
      RETURN.
    ENDIF.

    CLEAR: gt_header, gt_item.



  ENDMETHOD.

  METHOD check_before_save_item.
    LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<lfs_header>).
      DATA(lv_item_count) = REDUCE i(
        INIT n = 0
        FOR row IN gt_item
        WHERE ( docentry = <lfs_header>-docentry )
        NEXT n = n + 1
      ).

      IF lv_item_count = 0.
        APPEND <lfs_header> TO rt_error_orders.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD delete_order.

    DATA: lt_order TYPE STANDARD TABLE OF yordr.

    lt_order = CORRESPONDING #( keys MAPPING FROM ENTITY ).

    gt_order_delete_dockey = VALUE #(
        FOR ls_order IN lt_order
        (
            sign = 'I'
            option = 'EQ'
            low = ls_order-docentry
        )
     ).

  ENDMETHOD.

ENDCLASS.


