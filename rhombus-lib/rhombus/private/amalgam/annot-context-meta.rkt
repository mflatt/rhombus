#lang racket/base
(require (for-syntax racket/base)
         "provide.rkt"
         "annot-context.rkt"
         "class-primitive.rkt"
         "function-arity-key.rkt"
         "index-result-key.rkt"
         (submod "map.rkt" for-info))

(provide (for-spaces (rhombus/namespace
                      #f
                      rhombus/bind
                      rhombus/annot)
                     annot_meta.Context)
         (for-syntax get-annotation-context-static-infos))

(define-primitive-class annot_meta.Context annotation-context
  #:existing
  #:transparent #:no-primitive
  #:fields
  ([(argument_names argument-names) #,(get-map-static-infos)]
   [(this_position this-pos)])
  #:properties
  ()
  #:methods
  ())
