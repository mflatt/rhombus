#lang rhombus/scribble/manual
@(import:
    meta_label:
      rhombus open
      html)

@title(~tag: "class"){HTML Document Representation}

@doc(
  class html.Document(
    ~content: content :: List = [],
    ~doctype: doctype :: maybe(html.DocumentType) = html.DocumentType(),
    ~quirks_mode: quirks_mode :: html.Document.QuirksMode = #'no_quirks
  )

  class html.DocumentType(
    ~name: name :: String = "html",
    ~public: public :: maybe(String) = #false,
    ~system: system :: maybe(String) = #false
  )

  enum html.Document.QuirksMode
  | no_quirks
  | quirks
  | limited_quirks
){

 Represents an HTML document.

}
