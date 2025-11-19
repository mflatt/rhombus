#lang racket/base
(require (prefix-in render: shrubbery/render)
         shrubbery/render/private/log
         scribble/racket
         (only-in scribble/core
                  element
                  element?
                  element-content
                  delayed-element
                  delayed-element?
                  delayed-element-plain
                  content?
                  content-width
                  content->string
                  paragraph
                  table
                  style
                  plain
                  nested-flow
                  resolve-get
                  resolve-get/tentative
                  color-property)
         (submod scribble/racket id-element)
         (only-in scribble/search
                  find-racket-tag)
         (for-template
          (only-in rhombus/private/name-root
                   portal-syntax->lookup))
         rhombus/syntax
         "typeset-key-help.rkt"
         "hspace.rkt"
         "defining-element.rkt"
         "spacer-binding.rkt")

(provide typeset-rhombus
         typeset-rhombusblock)

(define (element*? v)
  (let ([v (if (injected? v)
               (injected-e v)
               v)])
    (and (not (null? v))
         (not (string? v))
         (not (symbol? v))
         (content? v))))

(define tt-style (style 'tt null))

(struct target-style (prefix-len))

(define (element-shape e e-len e-style)
  (values (content-width e)
          (or e-style
              (let loop ([e e])
                (cond
                  [(pair? e) (loop (car e))]
                  [(defining-element? e) (target-style (defining-element-prefix-len e))]
                  [(element? e) (loop (element-content e))]
                  [(delayed-element? e) (loop ((delayed-element-plain e)))]
                  [else #f])))))

;; backward compatibility before v9.0.0.4
(define link-style-supported?
  (let-values ([(reqd allowed) (procedure-keywords make-id-element)])
    (and allowed (memq '#:link-style allowed))))

(define (make-id-element* id content as-define?
                          #:space space-name
                          #:link-style link-style
                          #:unlinked-ok? unlinked-ok?
                          #:suffix suffix)
  (if link-style-supported?
      (make-id-element id content as-define?
                       #:space space-name
                       #:link-style link-style
                       #:unlinked-ok? unlinked-ok?
                       #:suffix suffix)
      (make-id-element id (content->string content) as-define?
                       #:space space-name
                       #:unlinked-ok? unlinked-ok?
                       #:suffix suffix)))

(define-values (render_code
                render_code_block)
  (render:make
   #:render (lambda (kind str)
              (element (case kind
                         [(paren) paren-color]
                         [(variable) variable-color]
                         [(meta plain datum) tt-style]
                         [(value) value-color]
                         [(result) result-color]
                         [(error) error-color]
                         [(comment) comment-color]
                         [(lineno) (style 'smaller (list (color-property "blue")))]
                         [else tt-style])
                (if (eq? kind 'meta)
                    str
                    (keep-spaces (if (eq? kind 'lineno)
                                     (string-append str " ")
                                     str)))))
   #:render_in_space (lambda (space-name
                              #:prefix [prefix-str #f]
                              content
                              id
                              #:suffix [suffix-target #f]
                              #:suffix-space [suffix-space-name #f]
                              #:raw [raw? #f])
                       (define as-define? (syntax-property id 'typeset-define))
                       (define r
                         (element (and (not raw?) tt-style)
                           (let ()
                             (define main
                               (make-id-element* id content as-define?
                                                 #:space space-name
                                                 #:link-style (and raw? (style #f null))
                                                 #:unlinked-ok? #t
                                                 #:suffix (if suffix-target
                                                              (list (target-id-key-symbol suffix-target)
                                                                    suffix-space-name)
                                                              space-name)))
                             (if prefix-str
                                 (list prefix-str main)
                                 main))))
                       (cond
                         [as-define? (defining-element #f r (if prefix-str
                                                                (string-length prefix-str)
                                                                0))]
                         [else r]))
   #:render_via_result_annotation (let ([ns (make-base-namespace)])
                                    (define in-name-root-space (make-interned-syntax-introducer 'rhombus/namespace))
                                    (define in-annot-space (make-interned-syntax-introducer 'rhombus/annot))                                    
                                    (lambda (rev-root-names rev-root-ids rators field field-str)
                                      ;; A `rev-root-names` element is an identifier as in source, and a `rev-root-ids`
                                      ;; element is one an identifier is bound as a namespace.
                                      ;; Try to get a result from calling `root . root . ... rator() . rator() ... . field`.
                                      ;; The `root . root . . ... rator ` start might correspond to a
                                      ;; prefix used in the documentation, or it might start with a prefix used
                                      ;; locally for importing. Also, even though `root` is in principle a
                                      ;; namespace, it may be documented only as an annotation, so try that as a
                                      ;; fallback.
                                      (delayed-element
                                       (lambda (renderer sec ri)
                                         (define default (element tt-style field-str))
                                         (define (find-racket-tag* id rev-root-ids rev-root-names
                                                                   #:space [space #f]
                                                                   #:shift? shift?)
                                           (define id* (if (pair? rev-root-ids)
                                                           (in-name-root-space (or (car (reverse rev-root-ids)) #'fail) 'add)
                                                           id))
                                           (log-shrubbery-render-info "FIND-RACKET-TAG~a"
                                                                      (format-log
                                                                       'shift? shift?
                                                                       'id id*
                                                                       'id-scopes (hash-ref (syntax-debug-info id*) 'context #f)
                                                                       'space (if (pair? rev-root-ids) 'rhombus/namespace space)
                                                                       'suffix (and (pair? rev-root-names)
                                                                                    (list (format-suffix id rev-root-names)
                                                                                          space))
                                                                       'binding (identifier-binding
                                                                                 (if shift? (syntax-shift-phase-level id* #f) id*))))
                                           (define tag
                                             (find-racket-tag sec ri
                                                              (if shift? (syntax-shift-phase-level id* #f) id*)
                                                              #f
                                                              #:space (if (pair? rev-root-ids) 'rhombus/namespace space)
                                                              #:suffix (if (pair? rev-root-names)
                                                                           (list (format-suffix id rev-root-names)
                                                                                 space)
                                                                           space)
                                                              #:unlinked-ok? #t))
                                           (log-shrubbery-render-info "FIND-RACKET-TAG~a"
                                                                      (format-log
                                                                       'result tag))
                                           tag)
                                         (define (format-suffix id rev-root-names)
                                           (string->symbol
                                            (let ([names (reverse (cons id rev-root-names))])
                                              (apply string-append
                                                     (symbol->string (syntax-e (car names)))
                                                     (for/list ([name (in-list (cdr names))])
                                                       (format ".~a" (syntax-e name)))))))
                                         (let root-loop ([rators rators] [rev-root-names rev-root-names] [rev-root-ids rev-root-ids] [default default])
                                           ;; `rev-root-ids` can be shorted than `rev-root-names`; we use
                                           ;; `rev-root-names` for binding binsings, and `rev-root-ids` for trying non-prefixed
                                           (log-shrubbery-render-info "RESULT LOOP~a"
                                                                      (format-log
                                                                       'rev-root-names rev-root-names
                                                                       'rev-root-ids rev-root-ids
                                                                       'rators rators
                                                                       'field field))
                                           (define (start)
                                             (cond
                                               [(pair? rev-root-ids)
                                                (define ns-id (in-name-root-space (car rev-root-ids) 'add))
                                                (define annot-id (in-annot-space (car rev-root-ids) 'add))
                                                (prep-namespace-for-binding ns-id)
                                                (find-via-namespace-id ns-id annot-id rators #f rev-root-ids rev-root-names)]
                                               [else
                                                (define rator (car rators))
                                                (define tag (find-racket-tag* rator null null
                                                                              #:shift? #f))
                                                (parameterize ([current-namespace ns])
                                                  (find-via-rator-tag tag rator (cdr rators)))]))

                                           (define (find-via-rator-tag rator-tag rator more-rators)
                                             (define spacer-infos (and rator-tag
                                                                       (resolve-get/tentative sec ri (list 'spacer-infos rator-tag))))
                                             (define result-annot (and spacer-infos
                                                                       (hash-ref spacer-infos 'result_annotation #f)))
                                             (log-shrubbery-render-info "RATOR~a"
                                                                        (format-log
                                                                         'rator rator
                                                                         'rator-tag rator-tag))
                                             (cond
                                               [result-annot
                                                (find-via-annot-spacer-binding result-annot more-rators)]
                                               [else
                                                ;; try a class binding => constructor
                                                (define in-class-space (make-interned-syntax-introducer 'rhombus/class))
                                                (define class-id (in-class-space rator 'add))
                                                (log-shrubbery-render-info "CLASS~a"
                                                                           (format-log
                                                                            'class-id class-id
                                                                            'binding (identifier-binding class-id #f)))
                                                (cond
                                                  [(find-racket-tag* class-id null null
                                                                     #:shift? #f
                                                                     #:space 'rhombus/class)
                                                   => (lambda (tag)
                                                        (log-shrubbery-render-info "CLASS~a"
                                                                                   (format-log
                                                                                    'tag tag))
                                                        (root-loop (cdr rators) (list rator) (list rator) default))]
                                                  [else default])]))

                                           (define (find-via-annot-spacer-binding result-annot more-rators)
                                             (log-shrubbery-render-info "ANNOT-SPACER~a"
                                                                        (format-log
                                                                         'result-annot result-annot))
                                             (cond
                                               [(and result-annot
                                                     (or (spacer-binding? result-annot)
                                                         (and (hash? result-annot)
                                                              (spacer-binding? (hash-ref result-annot 'id #f))
                                                              (symbol? (hash-ref result-annot 'sym #f))
                                                              (let ([l (hash-ref result-annot 'root_ids #f)])
                                                                (and (pair? l) (list? l) (andmap spacer-binding? l)))
                                                              (let ([l (hash-ref result-annot 'root_syms #f)])
                                                                (and (pair? l) (list? l) (andmap symbol? l))))))
                                                (define sb (if (hash? result-annot)
                                                               (hash-ref result-annot 'id)
                                                               result-annot))
                                                (define root-sbs (and (hash? result-annot)
                                                                      (hash-ref result-annot 'root_ids)))
                                                (define root-syms (and (hash? result-annot)
                                                                       (hash-ref result-annot 'root_syms)))
                                                (define sym (if (hash? result-annot)
                                                                (hash-ref result-annot 'sym)
                                                                (spacer-binding-datum sb)))
                                                (define rev-names (map
                                                                   (lambda (sym) (datum->syntax #f sym))
                                                                   (if (hash? result-annot)
                                                                       (cons sym (reverse root-syms))
                                                                       (list sym))))
                                                (define rev-ids (map
                                                                 (lambda (sb sym)
                                                                   (binding->id sym (spacer-binding-annot-b sb)))
                                                                 (if (hash? result-annot)
                                                                     (cons sb (reverse root-sbs))
                                                                     (list sb))
                                                                 (if (hash? result-annot)
                                                                     (cons sym (reverse root-syms))
                                                                     (list sym))))
                                                (define ns-id (binding->id sym (spacer-binding-ns-b sb)))
                                                (define annot-id (binding->id sym (spacer-binding-annot-b sb)))
                                                (define root-annot-id (if root-sbs
                                                                          (binding->id (car root-syms) (spacer-binding-annot-b (car root-sbs)))
                                                                          annot-id))
                                                (find-via-namespace-id ns-id root-annot-id more-rators #t
                                                                       rev-ids
                                                                       rev-names)]
                                               [else default]))

                                           (define (find-via-namespace-id ns-id annot-id more-rators shift? rev-root-ids rev-root-names)
                                             (define (try-fallback)
                                               (cond
                                                 [annot-id
                                                  (define tag (find-racket-tag* (car rev-root-ids)
                                                                                (cdr rev-root-ids) (cdr rev-root-names)
                                                                                #:shift? shift?
                                                                                #:space 'rhombus/annot))
                                                  (define spacer-infos (and tag
                                                                            (resolve-get/tentative sec ri (list 'spacer-infos tag))))
                                                  (define fallback-annot (and spacer-infos
                                                                              (hash-ref spacer-infos 'method_fallback #f)))
                                                  (log-shrubbery-render-info "FALLBACK~a"
                                                                             (format-log
                                                                              'rev-root-name rev-root-names
                                                                              'shift? shift?
                                                                              'tag tag
                                                                              'spacer-infos spacer-infos))
                                                  (if fallback-annot
                                                      (find-via-annot-spacer-binding fallback-annot more-rators)
                                                      default)]
                                                 [else default]))
                                             (define p (and ns-id (with-handlers ([exn:fail? (lambda (x) #f)])
                                                                    (identifier-binding-portal-syntax ns-id (if shift? 0 #f)))))
                                             (define lookup (and p (portal-syntax->lookup p (lambda (self-id lookup) lookup) #f)))
                                             (define next-field (if (null? more-rators)
                                                                    field
                                                                    (car more-rators)))
                                             (define next-id (and lookup (lookup #f "identifier"
                                                                                 next-field
                                                                                 values)))
                                             (log-shrubbery-render-info "SEARCH~a"
                                                                        (format-log
                                                                         'ns-id ns-id
                                                                         'lookup lookup
                                                                         'rev-root-ids rev-root-ids
                                                                         'rev-root-names rev-root-names
                                                                         'next-field next-field
                                                                         'next-id next-id))
                                             (cond
                                               [next-id
                                                (cond
                                                  [(find-racket-tag* next-field rev-root-ids rev-root-names
                                                                     #:shift? shift?)
                                                   => (lambda (tag)
                                                        (cond
                                                          [(pair? more-rators)
                                                           (find-via-rator-tag tag next-id (cdr more-rators))]
                                                          [else
                                                           (define ns-id* (if (pair? rev-root-ids)
                                                                              (in-name-root-space (car (reverse rev-root-ids)) 'add)
                                                                              ns-id))
                                                           (define e
                                                             (make-id-element (if shift? (syntax-shift-phase-level ns-id* #f) ns-id*) field-str #f
                                                                              #:unlinked-ok? #t
                                                                              #:space 'rhombus/namespace
                                                                              #:suffix (list (format-suffix field rev-root-names)
                                                                                             #f)))
                                                           (element tt-style e)]))]
                                                  [else
                                                   ;; in case prefix is local to the import, try just ignoring it
                                                   (or (and #f
                                                            (pair? rev-root-ids)
                                                            (pair? more-rators)
                                                            (root-loop (cons next-id (cdr more-rators)) (cdr rev-root-names) (cdr rev-root-ids) #f))
                                                       (try-fallback))])]
                                               [else
                                                (try-fallback)]))

                                           (start)))
                                       (lambda () field-str)
                                       (lambda () field-str))))
   #:render_whitespace (lambda (n)
                         (element hspace-style (make-string n #\space)))
   #:render_indentation (lambda (n offset-in-orig orig-n orig-size style)
                          (cond
                            [(target-style? style)
                             (let* ([pre (min (max (- (target-style-prefix-len style)
                                                      offset-in-orig)
                                                   0)
                                              n)]
                                    [post (- n pre)])
                               (define bold-spaces
                                 (element 'tt (element value-def-color
                                                       (for/list ([i (in-range post)]) 'nbsp))))
                               (if (= pre 0)
                                   bold-spaces
                                   (list (element hspace-style (make-string pre #\space))
                                         bold-spaces)))]
                            [else
                             (element hspace-style (make-string n #\space))]))
   #:render_one_line (lambda (elems) elems)
   #:render_line (lambda (elems)
                   (paragraph plain elems))
   #:render_lines (lambda (lines)
                    (if (null? lines)
                        (element plain "")
                        (table plain (map list lines))))
   #:rendered_shape element-shape
   #:is_rendered element*?))

(define (typeset-rhombus stx
                         #:space [space-name-in #f]
                         #:content [content #f])
  (render_code stx #:space space-name-in #:content content))

(define (typeset-rhombusblock stx
                              #:inset [inset? #t]
                              #:indent [indent-amt 0]
                              #:prompt [prompt ""]
                              #:indent_from_block [indent-from-block? #t]
                              #:spacer_info_box [info-box #f]
                              #:number_from [number-from #f])
  (define output-block
    (render_code_block stx
                       #:indent indent-amt
                       #:prompt prompt
                       #:indent_from_block indent-from-block?
                       #:spacer_info_box info-box
                       #:number_from number-from))
  (if inset?
      (nested-flow (style 'code-inset null) (list output-block))
      output-block))

(define (binding->id root-sym b)
  (cond
    [(not b) #f]
    [else
     (define-values (mpi sym nom-mpi nom-sym phase import-phase export-phase)
       (apply values b))
     (load-mpi nom-mpi)
     (load-mpi mpi)
     (syntax-binding-set->syntax (syntax-binding-set-extend
                                  (syntax-binding-set)
                                  root-sym
                                  0
                                  mpi
                                  #:source-symbol sym
                                  #:source-phase phase
                                  #:nominal-module nom-mpi
                                  #:nominal-symbol nom-sym
                                  #:nominal-phase export-phase
                                  #:nominal-require-phase import-phase)
                                 root-sym)]))

(define (prep-namespace-for-binding id)
  (define b (identifier-binding id #f))
  (when b
    (define-values (mpi sym nom-mpi nom-sym phase import-phase export-phase) (apply values b))
    (load-mpi nom-mpi)
    (load-mpi mpi)))

(define (load-mpi mpi)
  (define (reset mpi)
    (define-values (sub base) (module-path-index-split mpi))
    (if (not sub)
        #f
        (module-path-index-join sub (and base (reset base)))))
  (with-handlers ([exn:fail? void])
    (module-path-index-resolve (reset mpi) #t)))
