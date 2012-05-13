#lang racket
(require net/url
         (planet dherman/json:4:0))

(define (make-team-url team-id)
  (string->url (string-append "http://coderwall.com/teams/" team-id ".json")))

(define (get-team-json team-id)
  (read-json (get-pure-port (make-team-url team-id))))
