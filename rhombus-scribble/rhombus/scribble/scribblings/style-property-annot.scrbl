#lang rhombus/scribble/manual
@(import:
    "common.rhm" open
    "rkt.rkt" open
    "style.rhm" open)

@(macro 'veneer_alias($rhm, $rkt)':
    '@doc(
       veneer $rhm
     ){
      @veneer_same($rhm, $rkt)
     }')
    

@title(~tag: "style-property-annot"){Style Property Datatypes}

@veneer_alias(Style.Numberer, rkt_numberer)
@veneer_alias(Style.DocumentVersion, rkt_document_version)
@veneer_alias(Style.DocumentDate, rkt_document_date)
@veneer_alias(Style.DocumentSource, rkt_document_source)

@doc(
  veneer Style.Color
  fun Style.Color(color :: String) :: Style.Color
  fun Style.Color(red :: Byte, green :: Byte, blue :: Byte)
    :: Style.Color
){

  @veneer_same(Style.Color, rkt_color)

}

@doc(
  veneer Style.BackgroundColor
  fun Style.BackgroundColor(color :: String)
    :: Style.BackgroundColor
  fun Style.BackgroundColor(red :: Byte, green :: Byte, blue :: Byte)
    :: Style.BackgroundColor
){

  @veneer_same(Style.BackgroundColor, rkt_background_color)

}

@veneer_alias(Style.TargetURL, rkt_target_url)

@veneer_alias(Style.BoxMode, rkt_box_mode)
@veneer_alias(Style.LinkRenderStyle, rkt_link_render_style)
@veneer_alias(Style.RenderConvertibleAs, rkt_render_convertible_as)
@veneer_alias(Style.HTML.BodyId, rkt_body_id)
@veneer_alias(Style.HTML.AltTag, rkt_alt_tag)
@veneer_alias(Style.HTML.Attributes, rkt_attributes_id)
@veneer_alias(Style.HTML.HeadExtra, rkt_head_extra)
@veneer_alias(Style.HTML.HeadAddition, rkt_head_addition)
@veneer_alias(Style.HTML.Hover, rkt_hover_property)
@veneer_alias(Style.HTML.URLAnchor, rkt_url_anchor)
@veneer_alias(Style.HTML.PartTitleAndContentWrapper, rkt_part_title_and_content_wrapper)
@veneer_alias(Style.HTML.PartLinkRedirect, rkt_part_link_redirect)
@veneer_alias(Style.HTML.Script, rkt_script_property)
@veneer_alias(Style.HTML.Xexpr, rkt_xexpr_property)

@veneer_alias(Style.Latex.CommandExtras, rkt_command_extras)
