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
(struct user (location name team username endorsements accounts badges))
(struct badge (name description created image-url))

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

(define (make-badge badge-hash)
  (badge (hash-ref badge-hash 'name)
         (hash-ref badge-hash 'description)
         (hash-ref badge-hash 'created)
         (hash-ref badge-hash 'badge)))

(define (make-user username)
  (define user-json (get-user-json username))
  (user (hash-ref user-json 'location)
        (hash-ref user-json 'name)
        (hash-ref user-json 'team)
        (hash-ref user-json 'username)
        (hash-ref user-json 'endorsements)
        (hash-ref user-json 'accounts)
        (map make-badge (hash-ref user-json 'badges))))