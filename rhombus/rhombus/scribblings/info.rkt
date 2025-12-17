#lang info

(define scribblings
  '(("rhombus.scrbl" (depends-all-main no-depend-on) (language))
    ("getting-started/rhombus-getting-started.scrbl" (multi-page) ("Rhombus" 19.1))
    ("guide/rhombus-guide.scrbl" (multi-page) ("Rhombus" 19))
    ("reference/rhombus-reference.scrbl" (multi-page) ("Rhombus" 18))
    ("meta/rhombus-meta.scrbl" (multi-page) ("Rhombus" 17))
    ("model/rhombus-model.scrbl" (multi-page) ("Rhombus" 16))
    ("rhombus-racket/rhombus-racket.scrbl" (multi-page) (interop))))

(define test-omit-paths 'all)
