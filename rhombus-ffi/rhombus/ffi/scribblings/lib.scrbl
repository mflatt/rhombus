#lang rhombus/scribble/manual
@(import:
    "common.rhm" open
    meta_label:
      rhombus/custodian open)

@title(~tag: "ffi-lib"){Foreign Libraries}

@doc(
  class Lib()
){

 Represents a foreign library. Create a @rhombus(Lib) instance with
 @rhombus(Lib.load), and access exports of a loaded library using
 @rhombus(Lib.find).

}

@doc(
  fun Lib.load(
    path :: PathString || False,
    version :: String || List.of(String || False) || False = #false,
    ~fail: fail :: maybe(() -> maybe(Lib)) = #false,
    ~as_global: as_global :: Any.to_boolean = #false,
    ~custodian: cust :: maybe(Custodian) = #false
  ) :: maybe(Lib)
){

}

@doc(
  method Lib.find(
    name :: String || Bytes || Symbol,
    ~fail: fail :: maybe(() -> maybe(ptr_t)) = #false
  ) :: maybe(ptr_t)
){


}
