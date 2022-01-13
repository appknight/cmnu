*&---------------------------------------------------------------------*
*& Report /AKN/CMNU_DEMO
*&---------------------------------------------------------------------*

" Demonstration report for customizing menu

REPORT /akn/cmnu_demo MESSAGE-ID /akn/velo.

CLASS velo_menu DEFINITION INHERITING FROM /akn/cl_cmnu.

  PUBLIC SECTION.
    METHODS constructor.
  PROTECTED SECTION.
    METHODS build_nodes REDEFINITION.
    METHODS handle_action FOR EVENT action OF velo_menu IMPORTING type name.
ENDCLASS.

DATA menu TYPE REF TO velo_menu.

CLASS velo_menu IMPLEMENTATION.

  METHOD constructor.

    super->constructor( ).
    SET HANDLER handle_action FOR me.

  ENDMETHOD.

  METHOD handle_action.

    show_logo( ).

    CASE type.
      WHEN 'C'. "Custom functions
        CASE name.
          WHEN 'CUSTOMONE'.
            TYPES:
              BEGIN OF _line,
                s TYPE text200,
              END OF _line,
              _lines TYPE STANDARD TABLE OF _line WITH DEFAULT KEY.

            hide_logo( ).
            DATA(text) = NEW cl_gui_textedit( parent = get_container( ) ).
            text->set_readonly_mode( 1 ).
            text->set_text_as_stream( VALUE _lines( ( s = |System-ID: { sy-sysid }| ) ) ).

          WHEN 'CUSTOMTWO'.
            DATA answer TYPE c LENGTH 1.

            CALL FUNCTION 'POPUP_TO_CONFIRM'
              EXPORTING
                titlebar              = 'Information'(i01)
                text_question         = 'Release object?'(i02)
                text_button_1         = 'Yes'(b01)
                icon_button_1         = 'ICON_ALLOW'
                text_button_2         = 'No'(b02)
                icon_button_2         = 'ICON_REJECT'
                default_button        = '1'
                display_cancel_button = 'X'
                userdefined_f1_help   = ' '
                start_column          = 25
                start_row             = 6
              IMPORTING
                answer                = answer
              EXCEPTIONS
                text_not_found        = 1
                OTHERS                = 2.
            IF sy-subrc = 0.
              CASE answer.
                WHEN '1'.
                  MESSAGE |Accepted| TYPE 'S'.
                WHEN '2'.
                  MESSAGE |Rejected| TYPE 'S'.
              ENDCASE.
            ENDIF.

        ENDCASE.

      WHEN 'T'. "Transaction
        CALL TRANSACTION name AND SKIP FIRST SCREEN.

      WHEN 'R'. "Report call
        SUBMIT (name) VIA SELECTION-SCREEN AND RETURN.

      WHEN 'V'. "View maintenance
        DATA l_viewname TYPE tabname.
        l_viewname = name.
        CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
          EXPORTING
            action                       = 'S'
            view_name                    = l_viewname
          EXCEPTIONS
            client_reference             = 1              " View is Chained to Another Client
            foreign_lock                 = 2              " View/Table is Locked by Another User
            invalid_action               = 3              " ACTION Contains Invalid Values
            no_clientindependent_auth    = 4              " No Authorization for Maintaining Cross-Client Tables/Views
            no_database_function         = 5              " No Data Capture/Disposal Function Module
            no_editor_function           = 6              " Editor Function Module Missing
            no_show_auth                 = 7              " No Display Authorization
            no_tvdir_entry               = 8              " View/Table is Not in TVDIR
            no_upd_auth                  = 9              " No Maintenance or Display Authorization
            only_show_allowed            = 10             " Display but Not Maintenance Authorization
            system_failure               = 11             " System Lock Error
            unknown_field_in_dba_sellist = 12             " Selection Table Contains Unknown Fields
            view_not_found               = 13             " View/Table Not Found in DDIC
            maintenance_prohibited       = 14             " View/Table Cannot be Maintained acc. to DDIC
            OTHERS                       = 15.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD build_nodes.


    add_folder( i_fnam = 'FOL_MAIN' i_text = 'Main Folder'(m00) ).
    add_folder( i_fnam = 'FOL_TRAN' i_text = 'Transactions'(m01) i_parent = 'FOL_MAIN' ).

    add_node( i_prnt = 'FOL_TRAN' i_func = 'T.SMW0'     i_text = 'Upload Logo'(t01) i_icon = icon_import ).
    add_node( i_prnt = 'FOL_TRAN' i_func = 'T.SE38'     i_text = 'Copy this program'(t02) i_icon = icon_abap ).

    add_folder( i_fnam = 'FOL_REPS' i_text = 'Call Reports'(m02) ).
    add_node( i_prnt = 'FOL_REPS' i_func = 'R.SHOWICON'     i_text = 'Show icons'(r01) i_icon = icon_color ).
    add_node( i_prnt = 'FOL_REPS' i_func = 'R.SHOWSYMB'     i_text = 'Show symbols'(r02) i_icon = icon_flight ).

    add_folder( i_fnam = 'FOL_CUST' i_text = 'Custom functions'(m03) ).
    add_node( i_prnt = 'FOL_CUST' i_func = 'C.CUSTOMONE'     i_text = 'Display System-ID'(c01) i_icon = icon_systemtype ).
    add_node( i_prnt = 'FOL_CUST' i_func = 'C.CUSTOMTWO'     i_text = 'Show Info message'(c02) i_icon = icon_information ).

    add_folder( i_fnam = 'FOL_VIEW' i_text = 'View Maintenance'(m04) ).
    add_node( i_prnt = 'FOL_VIEW' i_func = 'V.V_T005'     i_text = 'Countries'(v01) i_icon = icon_eu ).
    add_node( i_prnt = 'FOL_VIEW' i_func = 'V.V_T001W'     i_text = 'Plants'(v02) i_icon = icon_plant ).

  ENDMETHOD.


ENDCLASS.



INITIALIZATION.

*  AUTHORITY-CHECK OBJECT 'S_TCODE'
*           ID 'TCD' FIELD '/AKN/VELO_C'.
*  IF sy-subrc <> 0.
*    MESSAGE e172(00) WITH sy-tcode.
*    STOP.
*  ENDIF.


START-OF-SELECTION.

  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS '100'.
  SET TITLEBAR '100'.
  IF menu IS NOT BOUND.
    CREATE OBJECT menu.
    menu->init_menu( '[AppKnight] Easy Menu Report'(hdr) ).
    menu->init_logo( '/AKN/CMNU_LOGO_01' ).
    menu->init_logo_header( '/AKN/CUST/LOGO-01'  ).
    menu->expand_root_folder(
      expand_subtree = abap_true
      level_count    = 2 ).

  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'CANCEL'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'HOME'.
      SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.

ENDMODULE.
