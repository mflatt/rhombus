#lang racket/base
(require (for-syntax racket/base
                     syntax/parse/pre)
         "static-info.rkt")

(provide (for-syntax extract-index-uniform-result
                     extract-index-result
                     shift-index-result
                     cons-index-result
                     or-index-results))

(define-static-info-key-syntax/provide #%index-result
  (static-info-key (lambda (a b)
                     (or-index-results a b))
                   (lambda (a b)
                     (and-index-results a b))))

(define-for-syntax (extract-index-uniform-result si)
  (cond
    [(not si) #f]
    [else
     (syntax-parse si
       [(#:at_index other-si (idx i-si) ...)
        (for/fold ([si #'other-si]) ([i-si (syntax->list #'(i-si ...))])
          (static-infos-or si i-si))]
       [else si])]))

(define-for-syntax (extract-index-result si key)
  (cond
    [(not si) #f]
    [else
     (syntax-parse si
       [(#:at_index other-si (idx i-si) ...)
        (or (for/or ([idx (syntax->list #'(idx ...))]
                     [i-si (syntax->list #'(i-si ...))])
              (and (equal? key (syntax-e idx))
                   i-si))
            #'other-si)]
       [else si])]))

(define-for-syntax (shift-index-result si di)
  (syntax-parse si
    [(#:at_index other-si (idx i-si) ...)
     #`(#:at_index other-si
        #,@(for/list ([idx* (syntax->list #'(idx ...))]
                      [i-si (syntax->list #'(i-si ...))]
                      #:do [(define idx (syntax-e idx*))]
                      #:when (and (exact-integer? idx)
                                  ((+ idx di) . >= . 0)))
             #`(#,(+ idx di) #,i-si)))]
    [else si]))

(define-for-syntax (cons-index-result si i0-isi)
  (syntax-parse si
    [(#:at_index other-si i-case ...)
     #`(#:at_index other-si (0 #,i0-isi) i-case ...)]
    [else
     #`(#:at_index #,si (0 #,i0-isi))]))

(define-for-syntax (parse-index-results si)
  (syntax-parse si
    [(#:at_index other (idx si) ...)
     (values #'other
             (for/hash ([idx (in-list #'(idx ...))]
                        [si (in-list #'(si ...))])
               (values (syntax-e idx) si)))]
    [_ (values si #hash())]))

(define-for-syntax (or-index-results a b)
  (define-values (a-default a-ht) (parse-index-results a))
  (define-values (b-default b-ht) (parse-index-results b))
  (define defaults (static-infos-or a-default b-default))
  (cond
    [(and (= 0 (hash-count a-ht))
          (= 0 (hash-count b-ht)))
     defaults]
    [else
     (define-values (new-defaults new-ht)
       (for/fold ([new-defaults defaults] [new-ht #hash()]) ([(key a-si) (in-hash a-ht)])
         (cond
           [(hash-ref b-ht key #f)
            => (lambda (b-si)
                 (values new-defaults (hash-set new-ht key (static-infos-or a-si b-si))))]
           [else
            (values (static-infos-or new-defaults a-si) new-ht)])))
     (define all-defaults
       (for/fold ([new-defaults new-defaults]) ([(key b-si) (in-hash b-ht)])
         (cond
           [(hash-ref a-ht key #f) new-defaults]
           [else (static-infos-or new-defaults b-si)])))
     (if (= 0 (hash-count new-ht))
         all-defaults
         #`(#:at_index #,all-defaults
            #,@(for/list ([(key si) (in-hash new-ht)])
                 #`(#,key #,si))))]))

(define-for-syntax (and-index-results a b)
  (define-values (a-default a-ht) (parse-index-results a))
  (define-values (b-default b-ht) (parse-index-results b))
  (define defaults (static-infos-and a-default b-default))
  (cond
    [(and (= 0 (hash-count a-ht))
          (= 0 (hash-count b-ht)))
     defaults]
    [else
     (define new-ht
       (for/fold ([new-ht #hash()]) ([(key a-si) (in-hash a-ht)])
         (cond
           [(hash-ref b-ht key #f)
            => (lambda (b-si)
                 (hash-set new-ht key (static-infos-and a-si b-si)))]
           [else
            (hash-set new-ht key (static-infos-and b-default a-si) new-ht)])))
     (define all-ht
       (for/fold ([new-ht new-ht]) ([(key b-si) (in-hash b-ht)])
         (cond
           [(hash-ref a-ht key #f) new-ht]
           [else
            (hash-set new-ht key (static-infos-and a-default b-si) new-ht)])))
     (if (= 0 (hash-count all-ht))
         defaults
         #`(#:at_index #,defaults
            #,@(for/list ([(key si) (in-hash all-ht)])
                 #`(#,key #,si))))]))
