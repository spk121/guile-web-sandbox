(define-module (sandy sandy)
  #:use-module (sandy scm-style-repl)
  #:use-module (ice-9 sandbox))

(define (repl-on-module name)
  (let ((m (resolve-module name)))
    (format #t "Starting repl for module ~S~%" name)
    (scm-style-repl m)))

(define (repl-on-sandbox bindings)
  (let* ((m (make-sandbox-module bindings)))
    (format #t "Starting repl for sandbox~%")
    (scm-style-repl m #t)))

;; PICK ONE

;; This first one is a repl that only provides the functions given
;; in the (sandy safe-r5rs) module.  But it still is for a trusted
;; user because there's nothing stopping the REPL user from
;; making infinite loops or using up all the memory.
(repl-on-module '(sandy safe-r5rs))

;; This one is more paranoid.  It has time and memory limits.
;; To see the functions that are actually in "all-pure-bindings"
;; look in (ice-9 sandbox).
;; (repl-on-sandbox all-pure-bindings)
