#lang info

(define collection 'multi)

(define deps '("base"
               "rhombus-http-lib"))
(define implies '("rhombus-http-lib"))

(define build-deps
  '("http-easy"
    "rhombus"
    "rhombus-scribble-lib"))

(define pkg-desc "Rhombus HTTP library")

(define license '(Apache-2.0 OR MIT))
