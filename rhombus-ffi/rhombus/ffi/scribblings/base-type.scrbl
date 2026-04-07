#lang rhombus/scribble/manual
@(import:
    "common.rhm" open)

@title(~tag: "ffi-base-type"){Base Foreign Types}

@doc(
  foreign.type ptr_t
){

 A generic pointer. On the C side, a generic pointer is represented as an
 address with the same representation as @tt{void*}. On the Rhombus side,
 a generic pointer is represented as a @tech{pointer} object. See also
 @secref("pointer").

 When an address is converted from C to Rhombus, then
 @rhombus(ptr_t, ~at rhombus/ffi/type) produces a pointer object that
 references memory (assumed to be) not managed by Racket's garbage
 collector. The @rhombus(ptr_t/gcable, ~at rhombus/ffi/type) type implies
 that a pointer converted from C should be treated as (potentially)
 managed by Rhombus's garbage collector. In both cases, conversion from
 Rhombus to C allows any pointer object.

 The @rhombus(void_t*, ~at rhombus/ffi/type) type is equivalent to
 @rhombus(ptr_t, ~at rhombus/ffi/type), and the
 @rhombus((void_t*)/gcable, ~at rhombus/ffi/type) type is equivalent to
 @rhombus(ptr_t/gcable, ~at rhombus/ffi/type).

}

@doc(
  foreign.type int8_t
  foreign.type uint8_t
  foreign.type int16_t
  foreign.type uint16_t
  foreign.type int32_t
  foreign.type uint32_t
  foreign.type int64_t
  foreign.type uint64_t
){

 Signed and unsigned integer @tech{scalar} types of specific bit widths
 on the C side. All are represented as exact integers on the Rhombus side,
 constrained to a range that fits in the unsigned or two's complement bit
 representation.

}

@doc(
  foreign.type short_t
  foreign.type ushort_t
  foreign.type int_t
  foreign.type uint_t
  foreign.type long_t
  foreign.type ulong_t
  foreign.type intptr_t
  foreign.type uintptr_t
  foreign.type size_t
  foreign.type ssize_t
){

 Signed and unsigned integer @tech{scalar} types of platform-specific
 bit widths. For consistently, a @litchar{_t} is added to the end of C
 type names like @tt{int} to form a type name like
 @rhombus(int_t, ~at rhombus/ffi/type).

 All are represented as exact integers on the Rhombus side, constrained
 to a range that fits in the platform-specific C representation.

}

@doc(
  foreign.type float_t
  foreign.type double_t
){

 IEEE floating-point number @tech{scalar} types. On the C side, a
 @rhombus(float_t, ~at rhombus/ffi/type) is 8 bytes, and a
 @rhombus(double_t, ~at rhombus/ffi/type) is 16 bytes. On the Rhombus
 side, both are represented as @tech(~doc: ref_doc){flonums}.

}

@doc(
  foreign.type wchar_t
  foreign.type intwchar_t
){

 On the C side, both @rhombus(wchar_t, ~at rhombus/ffi/type) and
 @rhombus(intwchar_t, ~at rhombus/ffi/type) occupy the same number of
 bytes. On the Rhombus side, a @rhombus(wchar_t, ~at rhombus/ffi/type) is
 represented as a character, while a
 @rhombus(intwchar_t, ~at rhombus/ffi/type) is a @tech{scalar} type that
 is represented as an exact integer that fits into the platform-specific
 C representation.

 The range of @rhombus(wchar_t, ~at rhombus/ffi/type) on the C side may
 include integers that do not correspond to a Rhombus character, and it
 may omit values that do correspond to a Rhombus character. The Rhombus
 representation of a @rhombus(wchar_t, ~at rhombus/ffi/type) is
 constrained to characters that fit in the C representation, and values
 from C that are are not representable as Rhombus characters are
 converted to the Unicode replacement character, @rhombus(Char"\uFFFD").

}

@doc(
  foreign.type bool_t
  foreign.type boolint_t
){

 Boolean @tech{scalar} types. On the C side,
 @rhombus(bool_t, ~at rhombus/ffi/type) corresponds to the C @tt{bool}
 type from @tt{<stdbool.h>}, while
 @rhombus(boolint_t, ~at rhombus/ffi/type) corresponds to @tt{int} (which
 is often used for a boolean representation in C-based libraries). On the
 Rhombus side, both are represented by boolean values when received from
 C, and and Rhombus value is allowed when converting to C (where
 @rhombus(#false) is treated as false and all other values are treated as
 true).

}

@doc(
  foreign.type void_t
){

 A type with no representation on the C side and a @rhombus(#void)
 representation on the Rhombus side. The
 @rhombus(void_t, ~at rhombus/ffi/type) type can only be used for the
 result of a foreign procedure for foreign callback.

}

@doc(
  foreign.type string_t
  foreign.type bytes_t
  foreign.type bytes_ptr_t
  foreign.type path_t
){

 Types that are represented on the C side like
 @rhombus(ptr_t, ~at rhombus/ffi/type), but that are represented in
 Rhombus by conversion to and from strings, byte strings, and paths. The
 @rhombus(string_t, ~at rhombus/ffi/type) type converts a Rhombus string
 to a null-terminated byte string and passes the address of the start of
 the byte string. The @rhombus(bytes_t, ~at rhombus/ffi/type) type
 similarly copies a racket byte string to add a null terminator, while
 @rhombus(bytes_ptr_t, ~at rhombus/ffi/type) passes the start of a
 Rhombus byte string as-is, without adding a terminator (and where
 mutation of pointer content on the C side is reflected as changes to the
 byte string content). The @rhombus(path_t, ~at rhombus/ffi/type) is like
 @rhombus(string_t, ~at rhombus/ffi/type), but for paths in the sense of
 @rhombus(CrossPath, ~annot).

 When converting from C to Rhombus, the pointer received from C is
 treated as a reference to a null-terminated C string, and a fresh Racket
 byte string is created to hold the content up to the null terminator.
 The @rhombus(string_t, ~at rhombus/ffi/type) or
 @rhombus(path_t, ~at rhombus/ffi/type) types then convert that byte
 string to a string or path, respectively.

}


@doc(
  foreign.type racket_t
){

 A type that is represented on the C side like
 @rhombus(ptr_t, ~at rhombus/ffi/type), but on the Rhombus side by an
 arbitrary value. This type can only be used for a procedure argument or
 result, and it will make sense only when interacting with a foreign
 procedure that is specifically aware of the Rhombus/Racket runtime
 system and cooperating with it.

}
