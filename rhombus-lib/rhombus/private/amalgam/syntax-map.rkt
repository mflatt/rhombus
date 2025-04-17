#lang racket/base
(require (for-syntax racket/base
                     syntax/parse/pre)
         "key-comp-runtime.rkt"
         "annotation-failure.rkt")

;; Define the implementation part of `equal_name_and_scopes` so we
;; can use it in the annotation-macro protocol

(provide equal-name-and-scopes-map?
         wrap-equal-name-and-scopes-map
         empty-equal_name_and_scopes-map)

(define-syntax (define-bound-id-map stx)
  (syntax-parse stx
    [(_ id id? wrap-id)
     #`(begin
         #,@(build-key-comp-runtime #'id #'bound-id=? #'hash-bound-id= #'id? #'wrap-id))]))

(define (bound-id=? a b recur)
  (define who 'equal_name_and_scopes)
  (unless (identifier? a) (raise-annotation-failure who a "Identifier"))
  (unless (identifier? b) (raise-annotation-failure who b "Identifier"))
  (bound-identifier=? a b))

(define (hash-bound-id= a recur)
  (define who 'equal_name_and_scopes)
  (unless (identifier? a) (raise-annotation-failure who a "Identifier"))
  (recur (syntax-e a)))

(define-bound-id-map equal_name_and_scopes
  equal-name-and-scopes-map?
  wrap-equal-name-and-scopes-map)

(define empty-equal_name_and_scopes-map
  (wrap-equal-name-and-scopes-map (hash)))
