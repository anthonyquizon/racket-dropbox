#lang racket

(require (prefix-in c: net/http-client)
         (prefix-in j: json))

(provide 
  setup 
  files_list_folder
  files_download)

(define .+ string-append)
(define CONTENT_HOST "content.dropboxapi.com")
(define API_HOST "api.dropboxapi.com")

(define current-token (make-parameter null))

(define (base-headers)
  (list (.+ "Authorization: Bearer " (current-token))))

(define (write-output path in)
  (when (file-exists? path)
    (delete-file path))

  (call-with-output-file path
    (lambda (out) 
      (write-string (port->string in) out))))

(define (api-call uri #:data [data null] )
  (define headers 
    (append (base-headers) 
            (list "Content-Type: application/json")))

  (define-values (res-status res-headers res-in) 
    (c:http-sendrecv
      API_HOST
      uri
      #:ssl? #t
      #:method #"POST"
      #:headers headers
      #:data (j:jsexpr->string data)))

  (cond
    [(equal? res-status #"HTTP/1.1 400 Bad Request") 
     (write-output "error.html" res-in)
     (raise "api call 400")]
    [else (j:read-json res-in)]))

(define (content-call uri #:data [data null] )
  (define headers 
    (append (base-headers)
            (list (.+ "Dropbox-API-Arg: " (j:jsexpr->string data)))))  

  (define-values (res-status res-headers res-in) 
    (c:http-sendrecv
      CONTENT_HOST
      uri
      #:ssl? #t
      #:method #"POST"
      #:headers headers))

  (cond
    [(equal? res-status #"HTTP/1.1 400 Bad Request") 
     (raise "content call 400")]
    [else res-in]))

(define (files_list_folder path)
  (define data (make-hash `((path . ,path))))
  (api-call "/2/files/list_folder" #:data data))

(define (files_download path)
  (define data (make-hash `((path . ,path))))
  (content-call "/2/files/download" #:data data))

(define (setup token)
  (current-token token))

