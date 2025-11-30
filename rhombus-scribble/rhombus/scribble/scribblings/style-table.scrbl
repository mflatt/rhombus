#lang rhombus/scribble/manual
@(import:
    "common.rhm" open
    "rkt.rkt" open
    "style.rhm" open)

@title(~tag: "style-table"){Table Styles}

@doc(  
  ~nonterminal_key: Table
  grammar table_style
){

@name_itemlist(
 @elem{a @tech{table}}

 @item{A @rhombus(String, ~annot): @html{Used as a CSS class name.}
  @latex{Used as the name of an environment used around the table
   content.}}

 @item{@symkey(#'boxed): @all{Renders as a definition. This style name
   is not intended for use on a table that is nested within another
   @rhombus(#'boxed) table; nested uses may look right for some renderers
   but not others.}}

 @item{@symkey(#'centered): @html{Centers the table horizontally with
   respect to its enclosing flow.}}

 @item{@symkey(#'block): @latex{Prevents pages breaks between the
   table's rows.}}

)

@property_itemlist(
 @elem{a @tech{table}}

 @item{A @rhombus(Style.TableColumns, ~annot): @all{Provides
   column-specific styles, but only
   @rhombus(Style.ColumnAttributes, ~annot) properties (if any) within the
   styles are used if a @rhombus(Style.TableCells, ~annot) structure is also
   included as a style property. See @rhombus(Style.TableCells, ~annot) for
   information about how a column style is used for each cell.}}

 @item{A @rhombus(Style.TableCells, ~annot): @all{Provides cell-specific
   styles. See @rhombus(Style.TableCells, ~annot) for information about how
   the styles are used.}}

 @item{A @rhombus(Style.Attributes, ~annot): @html{Provides additional
   attributes for the @tt{<table>} tag.}}

 @item{@symkey(#'aux): @html{Include the table in the table-of-contents
   display for the enclosing part.}}

 @item{@symkey(#'#{never-indents}): @latex{Adjusts the pargraph when in
   a @tech{compound paragraphs}. See the property description in
   @rhombus(compound_paragraph_style).}}

)

}
