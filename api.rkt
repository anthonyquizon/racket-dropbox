#lang racket

(require (prefix-in c: net/http-client)
         (prefix-in j: json))

(provide 
  setup 
  files_list_folder
  files_download)

(define .+ string-append)
(define HOST "api.dropboxapi.com")

(define current-token (make-parameter null))

(define (base-headers)
  (list (.+ "Authorization: Bearer " (current-token))
        "Content-Type: application/json"))

(define (api-call uri 
                  #:data [data null] 
                  #:headers [headers null]
                  #:output-json? [output-json? #t])
  (define-values (res-status res-headers res-in) 
    (c:http-sendrecv
      HOST
      uri
      #:ssl? #t
      #:method #"POST"
      #:headers (append (base-headers) headers)
      #:data (j:jsexpr->string data)))

  (if output-json?
    (j:read-json res-in)
    res-in))

(define (files_list_folder path)
  (define data (make-hash `((path . ,path))))
  (api-call "/2/files/list_folder" #:data data))

(define (files_download path)
  (define data (make-hash `((path . ,path))))
  (define headers (list (.+ "Dropbox-API-Arg: " (j:jsexpr->string data))))
  (api-call "/2/files/download" 
            #:headers headers 
            #:output-json? #f))

(define (setup token)
  (current-token token))
