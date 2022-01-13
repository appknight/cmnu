class /AKN/CL_CMNU definition
  public
  create public .

public section.

  events ACTION
    exporting
      value(TYPE) type CLIKE
      value(NAME) type CLIKE .

  methods INIT_LOGO
    importing
      !LOGONAME type CLIKE
      !DISP_MODE type I default CL_GUI_PICTURE=>DISPLAY_MODE_FIT_CENTER .
  methods INIT_MENU
    importing
      !HEADING type CLIKE .
  methods EXPAND_ROOT_FOLDER
    importing
      !EXPAND_SUBTREE type ABAP_BOOL default 'X'
      !LEVEL_COUNT type I default 3 .
  methods CLEAR_CONTAINER .
  methods GET_CONTAINER
    returning
      value(CONTAINER) type ref to CL_GUI_CONTAINER .
  methods SHOW_LOGO .
  methods HIDE_LOGO .
  methods INIT_LOGO_HEADER
    importing
      !LOGONAME type CLIKE
      !DISP_MODE type I default CL_GUI_PICTURE=>DISPLAY_MODE_FIT_CENTER .
protected section.

  data MO_LOGO type ref to /AKN/CL_PICT .
  constants C_COLUMN_HIERARCHY type TV_ITMNAME value 'Hierarchy' ##NO_TEXT.
  data SPLITTER_VERT type ref to CL_GUI_EASY_SPLITTER_CONTAINER .
  data MAIN_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data DOCU_CONTAINER type ref to CL_GUI_CONTAINER .
  data MENU type ref to CL_COLUMN_TREE_MODEL .
  data DOCU type ref to CL_GUI_HTML_VIEWER .
  data LOGO type ref to CL_GUI_PICTURE .
  data SPLT_CONTAINER_HORZ type ref to CL_GUI_CUSTOM_CONTAINER .
  data MENU_CONTAINER type ref to CL_GUI_CONTAINER .
  data HDLO_CONTAINER type ref to CL_GUI_CONTAINER .
  data SPLITTER_HORZ type ref to CL_GUI_EASY_SPLITTER_CONTAINER .
  data HDLO type ref to CL_GUI_PICTURE .
  data MO_LOGO_HDR type ref to /AKN/CL_PICT .

  methods BUILD_NODES .
  methods ADD_NODE
    importing
      !I_PRNT type TM_NODEKEY optional
      !I_FUNC type CLIKE
      !I_TEXT type CLIKE
      !I_ICON type CLIKE .
  methods ADD_FOLDER
    importing
      !I_FNAM type CLIKE
      !I_TEXT type CLIKE
      !I_PARENT type CLIKE optional .
  methods HANDLE_ITEM_DOUBLE_CLICK
    for event ITEM_DOUBLE_CLICK of CL_COLUMN_TREE_MODEL
    importing
      !ITEM_NAME
      !NODE_KEY .
  methods HANDLE_NODE_DOUBLE_CLICK
    for event NODE_DOUBLE_CLICK of CL_COLUMN_TREE_MODEL
    importing
      !NODE_KEY .
private section.
ENDCLASS.



CLASS /AKN/CL_CMNU IMPLEMENTATION.


  METHOD add_folder.


    DATA nodes TYPE treemcnota.
    DATA node  TYPE treemcnodt.

    node-node_key  = i_fnam.
    node-relatkey  = i_parent.
    node-isfolder  = abap_true.
    node-relatship = cl_column_tree_model=>relat_last_child.

    APPEND node TO nodes.
    menu->add_nodes( nodes ).

    DATA items TYPE treemcitac.
    DATA item  TYPE treemciten.

    item-node_key = node-node_key.
    item-item_name = c_column_hierarchy.
    item-text      = i_text.
    item-class     = cl_column_tree_model=>item_class_text.
    APPEND item TO items.

    menu->add_items( items ).


  ENDMETHOD.


  method ADD_NODE.


    DATA nodes TYPE treemcnota.
    DATA node  TYPE treemcnodt.

    node-node_key  = i_func.
    node-relatkey  = i_prnt.
    node-relatship = cl_column_tree_model=>relat_last_child.
    node-n_image   = i_icon.

    APPEND node TO nodes.
    menu->add_nodes( nodes ).

    DATA items TYPE treemcitac.
    DATA item  TYPE treemciten.

    item-node_key = node-node_key.
    item-item_name = c_column_hierarchy.
    item-text      = i_text.
    item-class     = cl_column_tree_model=>item_class_text.
    APPEND item TO items.

    menu->add_items( items ).



  endmethod.


  METHOD build_nodes.

    "redefine!

*    add_folder( i_fnam = 'FOL_MAIN' i_text = 'Grundeinstellungen'(man) ).
*    add_node( i_prnt = 'FOL_MAIN' i_func = 'V./AKN/VELO_AREAS'     i_text = 'Maintain areas'(001) i_icon = icon_variants ).
*    add_folder( i_fnam = 'FOL_OTHR' i_text = 'Others'(002) ).

  ENDMETHOD.


  METHOD CLEAR_CONTAINER.

    LOOP AT docu_container->children INTO DATA(child).
      child->free( ).
      CLEAR child.
    ENDLOOP.

  ENDMETHOD.


  METHOD expand_root_folder.


    menu->expand_root_nodes(
      expand_subtree = expand_subtree
      level_count    = level_count ).

  ENDMETHOD.


  METHOD get_container.
    container = docu_container.
  ENDMETHOD.


  method HANDLE_ITEM_DOUBLE_CLICK.

    handle_node_double_click( node_key = node_key ).

  endmethod.


  METHOD handle_node_double_click.


    DATA l_menu_type   TYPE c LENGTH 2.
    DATA l_menu_object TYPE c LENGTH 40.

    SPLIT node_key AT '.' INTO l_menu_type l_menu_object.

    RAISE EVENT action
      EXPORTING
        type = l_menu_type
        name = l_menu_object.

  ENDMETHOD.


  METHOD hide_logo.

    CHECK mo_logo IS BOUND.
    mo_logo->mo_picture->set_visible( abap_false ).

  ENDMETHOD.


  METHOD init_logo.

    CHECK mo_logo IS INITIAL.

    mo_logo = NEW #( ).
    mo_logo->display(
      logo_name = logoname
      container = docu_container
      disp_mode = disp_mode ).

  ENDMETHOD.


  METHOD init_logo_header.

    CHECK mo_logo_hdr IS INITIAL.

    mo_logo_hdr = NEW #( ).
    mo_logo_hdr->display(
      logo_name = logoname
      container = hdlo_container
      disp_mode = disp_mode ).

  ENDMETHOD.


  METHOD init_menu.

    CREATE OBJECT main_container
      EXPORTING
        container_name = 'CC_MAIN'
        dynnr          = '0100'
        repid          = sy-cprog.

    CREATE OBJECT splitter_vert
      EXPORTING
        parent        = main_container
        orientation   = cl_gui_easy_splitter_container=>orientation_horizontal
        sash_position = 30.

    CREATE OBJECT splitter_horz
      EXPORTING
        parent        = splitter_vert->top_left_container
        orientation   = cl_gui_easy_splitter_container=>orientation_vertical
        sash_position = 15.


    hdlo_container ?= splitter_horz->top_left_container.
    menu_container ?= splitter_horz->bottom_right_container.
    docu_container ?= splitter_vert->bottom_right_container.

    DATA hierarchy_header TYPE treemhhdr.
    hierarchy_header-t_image = icon_tree.
    hierarchy_header-heading = heading.
    hierarchy_header-width = 80.
    CREATE OBJECT menu
      EXPORTING
        hierarchy_column_name = c_column_hierarchy
        hierarchy_header      = hierarchy_header
        node_selection_mode   = cl_column_tree_model=>node_sel_mode_single
        item_selection        = abap_true.

    menu->create_tree_control( EXPORTING parent = menu_container ).

    menu->set_registered_events( VALUE #(
                    ( eventid = menu->eventid_item_double_click )
                    ( eventid = menu->eventid_node_double_click )
                     ) ).
    SET HANDLER handle_item_double_click      FOR menu.
    SET HANDLER handle_node_double_click      FOR menu.

    build_nodes( ).

    menu->expand_root_nodes( ).


  ENDMETHOD.


  METHOD show_logo.

    CHECK mo_logo IS BOUND.
    mo_logo->mo_picture->set_visible( abap_true ).

  ENDMETHOD.
ENDCLASS.
