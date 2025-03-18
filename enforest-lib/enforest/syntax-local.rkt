#lang racket/base

(provide syntax-local-value*)

(define (syntax-local-value* id ref [intdef-ctx #f])  
  (define-values (v next) (syntax-local-value/immediate (if intdef-ctx
                                                            (internal-definition-context-add-scopes
                                                             intdef-ctx
                                                             id)
                                                            id)
                                                        (lambda () (values #f #f))
                                                        intdef-ctx))
  (cond
    [(ref v) => (lambda (v) v)]
    [next (syntax-local-value* next ref intdef-ctx)]
    [else #f]))
