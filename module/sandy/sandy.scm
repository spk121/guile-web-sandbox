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

(repl-on-module '(sandy safe-r5rs))

;; (repl-on-sandbox all-pure-bindings)
