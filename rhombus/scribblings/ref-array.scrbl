#lang scribble/rhombus/manual
@(import:
    "common.rhm" open
    "nonterminal.rhm" open)

@title{Arrays}

An expression followed by a square-bracketed sequence of expressions
is parsed as an implicit use of the @rhombus(#%ref) form, which is
normally bound to implement an array reference or assignment, as well
as other operations.  An array can be used as @tech{sequence}, in which case
it supplies its elements in order.

@dispatch_table(
  "array",
  @rhombus(Array),
  [arr.length(), Array.length(arr)]
)

@doc(
  fun Array(v :: Any, ...) :: Array
){

 Constructs a mutable array containing given arguments.

@examples(
  def a: Array(1, 2, 3)
  a
  a[0]
  a[0] := 0
  a
)

}

@doc(
  bind.macro 'Array($bind, ...)'
){

 Matches an array with as many elements as @rhombus(binding)s, where
 each element matches its corresponding @rhombus(binding).

@examples(
  def Array(1, x, y): Array(1, 2, 3)
  y
)

}

@doc(
  annot.macro 'Array'
  annot.macro 'Array.of($annot)'
){

 Matches any array in the form without @rhombus(of). The @rhombus(of)
 variant matches an array whose elements satisfy @rhombus(annotation).

}

@doc(
  reducer.macro 'Array'
  reducer.macro 'Array ~length $expr'
){

 A @tech{reducer} used with @rhombus(for), accumulates each result of a
 @rhombus(for) body into a result array.

 When a @rhombus(~length) clause is provided, an array of the specified
 length is created and mutated by iterations of the @rhombus(for) body.
 Iterations more than the specified length will trigger an exception,
 while iterations fewer than the length will leave @rhombus(0) values in
 the array.

}

@doc(
  fun Array.make(length :: Int, val = 0) :: Array
){

  Creates a fresh array with @rhombus(length) slots, where each slot
  is initialized to @rhombus(val).

@examples(
  Array.make(3, "x")
)

}

@doc(
  fun Array.length(arr :: Array) :: Int
){

 Returns the length of @rhombus(arr).

@examples(
  Array.make(3, "x").length()
)

}

