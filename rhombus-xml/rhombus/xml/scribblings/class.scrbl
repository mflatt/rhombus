#lang rhombus/scribble/manual
@(import:
    meta_label:
      rhombus open
      xml)

@title{XML Document Representation}

@doc(
  class xml.Document(~prolog: prolog :: xml.Prolog = xml.Prolog(),
                     ~element: element :: xml.Element,
                     ~misc: misc :: List.of(xml.Misc) = [])
){

}

@doc(
  class xml.Sourced(~srcloc: srcloc :: maybe(xml.SrclocRange) = #false):
    nonfinal

  class xml.SrclocRange(line :: NonnegInt,
                        char :: NonnegInt,
                        offset :: NonnegInt,
                        line_span :: NonnegInt,
                        char_span :: NonnegInt,
                        offset_span :: NonnegInt)
){

}

@doc(
  class xml.Element(~name: name :: String,
                    ~attributes: attributes :: List.of(xml.Attribute) = [],
                    ~content: content :: List.of(xml.Content) = []):
    extends xml.Sourced

  class xml.Attribute(~name: name :: String,
                      ~value: value :: String || xml.OtherPermitted):
    extends xml.Sourced

  class xml.PCData(~text: text :: String):
    extends xml.Sourced
){

}

@doc(
  annot.macro 'xml.Content'

  annot.macro 'xml.OtherPermitted'

  Parameter.def xml.current_permissive :: Any.to_boolean:
    #false
){
}

@doc(
  class xml.CData(~text: text :: String && !satisfying(String.contains(_, "]]>"))):
    extends xml.Sourced

  class xml.Verbatim(~text: text :: String):
    extends xml.Sourced

  annot.macro 'xml.EntityInt'

  class xml.Entity(~text: text :: String || xml.EntityInt):
    extends xml.Sourced
){
}

@doc(
  class xml.Prolog(~pre_misc: post_misc :: List.of(xml.Misc) = [],
                   ~dtd: dtd :: maybe(xml.DTD) = #false,
                   ~post_misc: pst_misc :: List.of(xml.Misc) = [])

  class xml.Comment(~text: text :: String)

  class xml.ProcessingInstruction(~target_name: target_name :: String,
                                  ~instruction: instruction :: String):
    extends xml.Sourced

  annot.macro 'xml.Misc'
){

}

@doc(
  class xml.DTD(~name: name :: String,
                ~system: system :: String,
                ~public: public :: maybe(String) = #false)
){
}

