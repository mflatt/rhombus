#lang rhombus/scribble/manual
@(import:
    "common.rhm" open)

@(def ffi_eval = make_rhombus_eval())
@examples(
  ~eval: ffi_eval
  ~hidden:
    import ffi open
)

@title(~tag: "ffi-compound-ffi-type"){Compound Foreign Types}

@doc(
  ~literal:
    ::
  ~nonterminal:
    id: block id
    field_id: block id
  type.macro 'struct $maybe_tag (
                $field_id :: $field_type,
                ...
              )'
  defn.macro 'foreign.struct $id (
                $field_id :: $field_type,
                ...
              )'
  grammar maybe_tag
  | $id
  | ϵ
){

 The @rhombus_t(struct) type form describes a type that is represented
 by a @tt{struct} declaration on the C side and a @tech{pointer} object
 in the Rhombus side. If @rhombus(maybe_tag) is an identifier, the name
 of the identifier is suffixed with @litchar{*} used as a @tech{tag} for
 pointers that represent instances of the @rhombus_t(struct) type,
 otherwise a generic @rhombus_t(ptr_t) pointer is used.

 Each @rhombus(field_id) must be distinct, and the corresponding
 @rhombus(field_type) describes the field's representation on the C side
 and the representation used on the Rhombus side if the field's value is
 extracted from a representation of the @rhombus_t(struct) type.

 The @rhombus(foreign.struct) form defines @rhombus(id) as an alias for
 the corresponding @rhombus_t(struct) type using @rhombus(id) like
 @rhombus(maybe_tag) for a pointer @tech{tag}. The @rhombus(id) is also
 defined for additional roles:

@itemlist(

 @item{The @rhombus(id) is defined as an annotation that recognizes
  pointers tagged with @rhombus(id).}

 @item{The @rhombus(id) is defined as a veneer. Each @rhombus(field_id)
  is bound as a field of the veneer that can be used to access or update
  the corresponding field in an instance of the @rhombus_t(struct).

  @itemlist(

   @item{When a field is accessed, the result is a representation of the
   corresponding C field value based on the conversion implied by the
   associated @rhombus(field_type).}

   @item{When the field is set using @rhombus(:=) to a Rhombus value, a
   value converted to C based on the associated @rhombus(field_type), and
   that C value is installed into the @rhombus_t(struct) instance.}

  )}

 @item{The @rhombus(id) is defined for use with @rhombus(new) allocate
  to an instance of the @rhombus(struct) with field values provided as
  arguments (in addition to the possibility of using @rhombus(id) by
  itself as a type to create an uninitialized instance).}
 
)


 Note that the Racket-side representation is the same for @rhombus_t(id)
 and @rhombus_t(id*), even though the C-side representation differs.

@examples(
  ~eval: ffi_eval
  ~defn:
    foreign.struct point_t(x :: double_t,
                           y :: double_t)
  ~repl:
    sizeof(point_t)
    sizeof(point_t*)
    def p1 = new point_t(1.0, 2.0)
    p1
    p1 is_a point_t
    p1 is_a foreign.type point_t*
    p1.x
    p1.y
    p1.x := 5.0
    p1.x
    point_t.x(p1)
    ~error:
      point_t.x(malloc(16))
)

 With this example's definition of @rhombus_t(point_t), a field in
 another @rhombus_t(struct) type would take up 16 bytes, while a
 @rhombus_t(point_t*) field would take up 8 bytes. Accessing the field in
 either case would produce a Racket representation that is a
 @tech{pointer} tagged as @litchar{point_t*}. In the case of a
 @rhombus_t(point_t) field, the returned pointer would refer to memory
 within the accessed @rhombus_t(struct) instance.

 Along similar lines, a pointer tagged with @litchar{point_t*} is
 suitable as an argument to a C function that has either a
 @rhombus_t(point_t) or @rhombus_t(point_t*) argument. In the case of a
 @rhombus_t(point_t) argument, the C function receives a copy of the
 content of the pointer. In the case of a @rhombus_t(point_t*) argument,
 the C function receives the same address as encapsulated by the pointer.

}

@//||{

@defform[#:kind "ffi2 type"
         (union maybe-tag
           [field-id field-type]
           ...)
         #:grammar ([maybe-tag id
                               ϵ])]{

Similar to @racket[struct], but for a type that uses @tt{union} on the
C side.

The interaction of @racket[define-ffi2-type] and @racket[union] is
like the interaction of @racket[define-ffi2-type] and @racket[struct],
except for the way the defined @racket[_name] is bound as an
expression form:

@itemlist[

 @item{@racket[_name] an expression expects a single field name
       followed by a single field subexpression, and it installs that
       field's value after allocating the @racket[union]
       representation. An optional allocation mode can be provided
       before the field name.}

]

@examples[
#:eval ffi2-eval
(define-ffi2-type grade_t (union
                            [score double_t]
                            [pass-fail bool_t]))
(ffi2-sizeof grade_t)
(define g1 (grade_t score 93.0))
(grade_t-score g1)
(define g2 (grade_t pass-fail #t))
(grade_t-pass-fail g2)
(define g3 (grade_t score 0.0))
(grade_t-pass-fail g3)
]

}

@defform[#:kind "ffi2 type"
         (array elem_type count)
         #:grammar ([count exact-nonnegative-integer
                           *])]{

Describes a type that is represented by an array or pointer
declaration on the C side and a @tech{pointer} object in the Racket
side. The array's @racket[count] must be a literal nonnegative exact
integer for a C array declaration, or it can be literally @racket[*]
to indicate a C pointer.

The Racket-side pointer representation uses a @tech{tag} formed by adding a
@litchar{*} suffix on the name of @racket[elem_type], as long as it
has a name. If 2rhombus[elem-type] is an immediate @racket[struct],
@racket[union], @racket[array], or @racket[->] for, then it has no
name, and the Racket-side representation is a generic pointer.

When @racket[array] is used as the @racket[_parent-type] in a
@racket[define-ffi2-type] definition of @racket[_name] without any
options (such as @racket[#:racket->c]) other than @racket[#:tag], then
@racket[array] and @racket[define-ffi2-type] influence each other:

@itemlist[

 @item{The @racket[#:tag] option of @racket[define-ffi2-type] can
       replace the tag used for pointer representations of the array,
       which is normally @litchar{*} added as suffix on the name of
       @racket[elem_type]. If the @racket[#:tag] option is not present,
       then @racket[_name] is added to the end of the Racket pointer
       representation's tag to create a @tech{pointer subtype}, where
       the array type is a subtype of an @racket[elem_type]-pointer type.}

 @item{@racketidfont{@racket[_name]/gcable} is also defined like
       @racketidfont{@racket[_name]*} if @racket[count] is @racket[*].
       It treats a C-to-Scheme conversion like @racket[ptr_t/gcable]
       by treating the C-side pointer as (potentialy) referencing
       memory that is managed by Racket's garbage collector.}

 @item{@racketidfont{@racket[_name]?} is defined to recognize
       suitably tagged Racket @tech{pointer} representations.}

 @item{@racketidfont{@racket[_name]-ref} is defined as an accessor: it
      takes a pointer for a @racket[array] instance and an exact
      integer, and it extracts a representation of the corresponding
      element value based on the conversion implied by
      @racket[elem-type]. If @racket[count] is not @racket[*], the
      integer passed to @racketidfont{@racket[_name]-ref} must be in the range
      @racket[0] (inclusive) to @racket[count] (exclusive).}

 @item{@racketidfont{@racket[_name]-ref} is defined as a mutator: it
      takes a pointer for a @racket[array] instance, an exact integer,
      and a field value; it installs a converted value
      (based @racket[elem-type]) into the @racket[array] instance.
      If @racket[count] is not @racket[*], the
      integer passed to @racketidfont{@racket[_name]-set!} is
      constrained in the same way as for @racketidfont{@racket[_name]-ref}.}

]

@examples[
#:eval ffi2-eval
(define-ffi2-type triple_t (array double_t 3))
(ffi2-sizeof triple_t)
(define p (ffi2-malloc triple_t))
p
(triple_t-set! p 0 0.0)
(triple_t-set! p 1 10.0)
(triple_t-set! p 2 20.0)
(eval:error (triple_t-set! p 3 30.0))
(triple_t-ref p 1)
]

}

@defform[#:kind "ffi2 type"
         (gcable ptr-type)]{

Describes a type that is the same as @racket[ptr-type], which must
describe a pointer type, except that conversion from C to Scheme creates
a reference to an address that is managed by the Racket garbage collector.
A @racket[gcable] adjustment has no effect on conversion from Scheme to C
or on predicates formed with @racket[ffi2-is-a?].

The type @racket[(gcable ptr_t)] is equivalent to
@racket[ptr_t/gcable]. More generally, when defining a pointer type with
@racket[define-ffi2-type], a type name with a @racketidfont{/gcable}
suffix is defined, and that name describes the same type as using
@racket[gcable]. The predicate @racket[ptr_t/gcable?] is @emph{not}
the same as @racket[(lambda (x) (ffi2-is-a? x ptr_t/gcable?))], because
@racket[ptr_t/gcable?] checks specifically for a pointer into a region
managed by the Racket garbage collector.

}

}||

@close_eval(ffi_eval)
