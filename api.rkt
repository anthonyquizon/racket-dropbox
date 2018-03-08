#lang racket

(require (prefix-in c: net/http-client)
         (prefix-in j: json))

(provide run)

(define .+ string-append)
(define HOST "api.dropboxapi.com")

(define current-token (make-parameter null))

(define (header)
  (list (.+ "Authorization: Bearer " (current-token))
        "Content-Type: application/json"))

(define (api-call uri data #:output-json? [output-json? #t])
  (define-values (status headers in) 
    (c:http-sendrecv
      HOST
      uri
      #:ssl? #t
      #:method #"POST"
      #:headers (header)
      #:data (j:jsexpr->string data)))

  (if output-json?
    (j:read-json in)
    in))

(define (files_list_folder folder)
  (define data (make-hash `((path . ,folder))))
  (api-call "/2/files/list_folder" data))

(define (run token f)
  (current-token token)
  (f)
  ;;close connection
  )
