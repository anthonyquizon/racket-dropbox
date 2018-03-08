#lang racket/base

(require yaml
         (prefix-in api: "api.rkt"))

(module+ test
  (require rackunit))

(define (with-config f [file "config.yml"]) 
  (define in-config (open-input-file file))
  (define config (read-yaml in-config))

  (api:run 
    (hash-ref config "accessToken")
    f))

(module+ test
  ;; Tests to be run with raco test
  )

(module+ main
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
