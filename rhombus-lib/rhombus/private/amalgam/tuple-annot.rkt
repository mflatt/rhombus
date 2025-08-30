#lang racket/base
(require (for-syntax racket/base
                     syntax/parse/pre
                     "srcloc.rkt"
                     "tag.rkt"
                     "annot-context.rkt")
         racket/treelist
         "binding.rkt"
         "parse.rkt"
         (submod "annotation.rkt" for-class)
         (only-in "annotation.rkt" ::)
         "static-info.rkt"
         "index-key.rkt"
         "call-result-key.rkt"
         "index-result-key.rkt"
         "parens.rkt"
         (rename-in "ellipsis.rkt"
                    [... rhombus...]))

(provide (for-syntax build-tuple-annotation))

(define-for-syntax (build-tuple-annotation src-stxes list-id anns last-ann treelist-static-infos)
  (define base-pred #`(lambda (v)
                        (and (treelist? v)
                             (#,(if last-ann #'>= #'=)
                              (treelist-length v)
                              #,(length (syntax->list anns))))))
  (define (make-si sis last-si)
    (or (for/fold ([si last-si]) ([a-si (in-list (syntax->list sis))]
                                  [i (in-naturals)])
          (add-index-result si i a-si))
        #'()))
  (define (build-predicate-annotation base-pred preds-stx sis last-pred last-si)
    (define si (make-si sis last-si))
    (define preds (syntax->list preds-stx))
    (with-syntax ([(pred ...) preds]
                  [(pred-id ...) (generate-temporaries preds)]
                  [(idx ...) (for/list ([p (in-list preds)]
                                        [i (in-naturals)])
                               i)])
      (define new-pred #`(let ([pred-id pred]
                               ...
                               #,@(if last-pred
                                      #`([last-pred-id #,last-pred])
                                      #'()))
                           (lambda (v)
                             (and (#,base-pred v)
                                  (pred-id (treelist-ref v idx))
                                  ...
                                  #,@(if last-pred
                                         #`((for/and ([i (in-range #,(length preds) (treelist-length v))])
                                              (last-pred-id (treelist-ref v i))))
                                         #'())))))      
      (annotation-predicate-form new-pred
                                 #`((#%index-result #,si)
                                    . #,treelist-static-infos))))
  (define (build-converter-annotation base-pred annots sis last-annot last-si)
    (define si (make-si sis last-si))
    (with-syntax ([(arg-id ...) (generate-temporaries annots)]
                  [(annot ...) annots]
                  [(last-id ...) (if last-annot
                                     (generate-temporaries '(last))
                                     '())]
                  [(last-annot ...) (if last-annot
                                        (list last-annot)
                                        null)]
                  [(last-dots ...) (if last-annot
                                       (list #'(group rhombus...))
                                       null)]
                  [List list-id])
      (syntax-parse #'(group List (brackets (group arg-id (op ::) (parsed #:rhombus/annot annot)) ...
                                            (group last-id (op ::) (parsed #:rhombus/annot last-annot)) ...
                                            last-dots ...))
        [all::binding
         (annotation-binding-form #'all.parsed
                                  #'(rhombus-expression (group List (brackets (group arg-id) ... (group last-id) ... last-dots ...)))
                                  #`((#%index-result #,si)
                                     . #,treelist-static-infos))])))
  (relocate+reraw
   (datum->syntax #f src-stxes)
   (cond
     [last-ann
      (syntax-parse anns
        [(ann::annotation-predicate-form ...)
         #:with last-ann::annotation-predicate-form last-ann
         (build-predicate-annotation base-pred
                                     #'(ann.predicate ...)
                                     #'(ann.static-infos ...)
                                     #'last-ann.predicate
                                     #'last-ann.static-infos)]
        [(ann::annotation-binding-form ...)
         #:with last-ann::annotation-binding-form last-ann
         (build-converter-annotation base-pred
                                     anns
                                     #'(ann.static-infos ...)
                                     #'last-ann
                                     #'last-ann.static-infos)])]
     [else
      (syntax-parse anns
        [(ann::annotation-predicate-form ...)
         (build-predicate-annotation base-pred
                                     #'(ann.predicate ...)
                                     #'(ann.static-infos ...)
                                     #f
                                     #f)]
        [(ann::annotation-binding-form ...)
         (build-converter-annotation base-pred
                                     anns
                                     #'(ann.static-infos ...)
                                     #f
                                     #f)])])))
