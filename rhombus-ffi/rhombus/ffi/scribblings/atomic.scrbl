#lang rhombus/scribble/manual
@(import:
    "common.rhm" open
    meta_label:
      ffi/atomic)

@title(~tag: "atomic"){Atomic Mode and Uninterruptible Mode}

@docmodule(ffi/atomic)

@doc(
  fun atomic.start_atomic() :: Void
  fun atomic.end_atomic() :: Void
  expr.macro 'atomic.atomically:
                $body
                ...'
){

}

@doc(
  fun atomic.start_uninterruptible() :: Void
  fun atomic.end_uninterruptible() :: Void
  expr.macro 'atomic.uninterruptibly:
                $body
                ...'
){

}
