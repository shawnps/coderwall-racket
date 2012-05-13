#lang racket
(require net/url
         (planet dherman/json:4:0))

(define (get-json make-url-function team-id-or-username)
  (read-json (get-pure-port (make-url-function team-id-or-username))))

(define (get-team-json team-id)
  (define (make-team-url team-id)
    (string->url (string-append "http://coderwall.com/teams/" team-id ".json")))
  (get-json make-team-url team-id))

(define (get-user-json username)
  (define (make-user-url username)
    (string->url (string-append "http://coderwall.com/" username ".json")))
  (get-json make-user-url username))

(struct team (id score name rank neighbors team-members))
(struct neighbor (id score name rank))
(struct team-member (name username badges_count endorsements_count))

(define (make-neighbor neighbor-hash)
  (neighbor (hash-ref neighbor-hash 'id)
            (hash-ref neighbor-hash 'score)
            (hash-ref neighbor-hash 'name)
            (hash-ref neighbor-hash 'rank)))

(define (make-team-member member-hash)
  (team-member (hash-ref member-hash 'name)
               (hash-ref member-hash 'username)
               (hash-ref member-hash 'badges_count)
               (hash-ref member-hash 'endorsements_count)))

(define (make-team team-id)
  (define team-json (get-team-json team-id))
  (team (hash-ref team-json 'id)
        (hash-ref team-json 'score)
        (hash-ref team-json 'name)
        (hash-ref team-json 'rank)
        (map make-neighbor (hash-ref team-json 'neighbors))
        (map make-team-member (hash-ref team-json 'team_members))))