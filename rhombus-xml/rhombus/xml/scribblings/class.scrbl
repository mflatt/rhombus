#lang rhombus/scribble/manual
@(import:
    meta_label:
      rhombus open
      xml)

@title(~tag: "class"){XML Document Representation}

@doc(
  class xml.Document(~prolog: prolog :: xml.Prolog = xml.Prolog(),
                     ~element: element :: xml.Element,
                     ~misc: misc :: List.of(xml.Misc) = [])
){

 Represents an XML document, which always contains a single element. A
 document optionally contains a document-type descriptor in the prolog,
 and it may have miscellaneous comments and processing instructions
 after the element.

}

@doc(
  class xml.Element(~name: name :: String,
                    ~attributes: attributes :: List.of(xml.Attribute) = [],
                    ~content: content :: List.of(xml.Content) = [],
                    ~srcloc: srcloc :: maybe(xml.SrclocRange) = #false)

  class xml.Attribute(~name: name :: String,
                      ~value: value :: String || xml.OtherPermitted,
                      ~srcloc: srcloc :: maybe(xml.SrclocRange) = #false)

  annot.macro 'xml.Content'
){

 An @rhombus(xml.Element) represents an XML term of them form
 @litchar{<}@italic{tag}…@litchar{>}…@litchar{</}@italic{tag}@litchar{>},
 where @rhombus(name) field corresponds to @italic{tag},
 @rhombus(attributes) correspond to attributes within
 @litchar{<}@italic{tag}…@litchar{>}, and @rhombus(content) is the
 content between @litchar{<}@italic{tag}…@litchar{>} and
 @litchar{</}@italic{tag}@litchar{>}.

 The @rhombus(xml.Content, ~annot) annotation recognizes allowed content
 values:

@itemlist(

 @item{@rhombus(xml.PCData, ~class): Normal text.}

 @item{@rhombus(xml.Entity, ~class): Entities written with
  @litchar{&}…@litchar{;}.}

 @item{@rhombus(xml.CData, ~class): Text written with
  @litchar{<![CDATA[}…@litchar{]]>}.}

 @item{@rhombus(xml.Verbatim, ~class): Text, possibly non-conforming, that
  is written verbatim by @rhombus(xml.write). A @rhombus(xml.read) never
  produces this form of content.}

 @item{@rhombus(xml.Comment, ~class): A comment written with
  @litchar{<!--}…@litchar{-->}, produced by @rhombus(xml.read) only when
  @rhombus(xml.current_read_comment) is @rhombus(#true).}

 @item{@rhombus(xml.ProcessingInstruction, ~class): A processing
  instruction written with @litchar{<?}…@litchar{>}.}

 @item{@rhombus(xml.OtherPermitted, ~annot): Any other value, but only
  when @rhombus(xml.current_permissive) is @rhombus(#true).}


)

}

@doc(
  class xml.PCData(~text: text :: String,
                   ~srcloc: srcloc :: maybe(xml.SrclocRange) = #false)
){

 Represents normal text for the content of an @rhombus(xml.Element).

}

@doc(
  annot.macro 'xml.EntityInt'

  class xml.Entity(~text: text :: String || xml.EntityInt,
                   ~srcloc: srcloc :: maybe(xml.SrclocRange) = #false)
){

 Represents entities written with @litchar{&}…@litchar{;} as the content
 of an @rhombus(xml.Element).

}

@doc(
  class xml.CData(~text: text :: String && !satisfying(String.contains(_, "]]>")),
                  ~srcloc: srcloc :: maybe(xml.SrclocRange) = #false)

  class xml.Verbatim(~text: text :: String,
                     ~srcloc: srcloc :: maybe(xml.SrclocRange) = #false)

){

 @rhombus(xml.CData, ~class) represents text written with
 @litchar{<![CDATA[}…@litchar{]]>} as the content of an
 @rhombus(xml.Element).

 @rhombus(xml.Verbatim, ~class) represents text as the content of an
 @rhombus(xml.Element) that is written verbatim by @rhombus(xml.write).
 The text might not conform to XML syntax. A @rhombus(xml.read) never
 produces this form of content.

}

@doc(
  class xml.Comment(~text: text :: String)

  class xml.ProcessingInstruction(
    ~target_name: target_name :: String,
    ~instruction: instruction :: String,
    ~srcloc: srcloc :: maybe(xml.SrclocRange) = #false
  )

  annot.macro 'xml.Misc'
){

 The @rhombus(xml.Misc, ~annot) annotation recognizes
 @rhombus(xml.Comment, ~class) and
 @rhombus(xml.ProcessingInstruction, ~class) instances. These values can
 appear with an @rhombus(xml.Element) as content, or they can appear
 before or after the element of a @rhombus(xml.Document).

 @rhombus(xml.Comment, ~class) represents comment written with
 @litchar{<!--}…@litchar{-->}. Comments are discarded by
 @rhombus(xml.read) unless @rhombus(xml.current_read_comment) is
 @rhombus(#true).

 @rhombus(xml.ProcessingInstruction, ~class) represents a processing
 instruction written with @litchar{<?}…@litchar{>}.

}

@doc(
  annot.macro 'xml.OtherPermitted'

  Parameter.def xml.current_permissive :: Any.to_boolean:
    #false
){

 When @rhombus(xml.current_permissive) is set to @rhombus(#true), then
 @rhombus(xml.Element) content and @rhombus(xml.Attribute) values can be
 anything. Such values can be converted to and from XML syntax objects,
 but not read or written as XML.

}

@doc(
  class xml.Prolog(~pre_misc: post_misc :: List.of(xml.Misc) = [],
                   ~dtd: dtd :: maybe(xml.DTD) = #false,
                   ~post_misc: pst_misc :: List.of(xml.Misc) = [])

  class xml.DTD(~name: name :: String,
                ~system: system :: String,
                ~public: public :: maybe(String) = #false)
){

 Represents metadata for an XML document.

}

@doc(
  class xml.SrclocRange(start :: Srcloc, end :: Srcloc)
){

 Represents the source location of an element, attribute, or content in
 an XML document. The @rhombus(start) source location has a
 @rhombus(Srcloc.span) value to capture the difference between the start
 and end source locations for an XML component, but @rhombus(end)
 provides additional information about the ending line and column.

}
