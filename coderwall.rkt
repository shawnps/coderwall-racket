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

; make a hash of user structs to list of badge structs for a team.
; example (shortened to one user for space):
; (define rackspace (make-team "4f271941973bf0000400037b"))
; (make-badges-hash rackspace)
; '#hash((#<user> . (#<badge> #<badge> #<badge> #<badge>)))
(define (make-badges-hash team)
  (define team-usernames
    (map (lambda (team-member) (team-member-username team-member))
         (team-team-members team)))
  (define team-users
    (map make-user team-usernames))
  (define users-to-badges-hash (make-hash))
  (for ([user team-users])
    (hash-set! users-to-badges-hash user (user-badges user)))
  users-to-badges-hash)

; make a hash of users names to badge names for a team.
; example (shortened to one user for space):
; (define rackspace (make-team "4f271941973bf0000400037b"))
; (user-names-to-badges rackspace)
; '#hash(("Shawn Smith" . ("Python 3" "Python" "Castor" "Charity")))
(define (user-names-to-badges team)
  (define user-names-to-badges-hash (make-hash))
  (hash-for-each (make-badges-hash team)
                 (lambda (user badges)
                   (hash-set! user-names-to-badges-hash
                              (user-name user)
                              (map (lambda (badge) (badge-name badge)) badges))))
  user-names-to-badges-hash)

; return a list of badge names that a user has
; example:
; (define shawn (make-user "shawnps"))
; (user-badge-names shawn)
; '("Python 3" "Python" "Castor" "Charity")
(define (user-badge-names user)
  (map (lambda (badge) (badge-name badge)) (user-badges user)))

; return a hash of badge names to badge descriptions for a user
; example:
; (define shawn (make-user "shawnps"))
; (badges-to-descriptions shawn)
; '#hash(("Charity" . "Fork and commit to someone's open source project
;         in need")
;        ("Castor" . "Made something awesome")
;        ("Python 3" . "Have at least three original repos where Python
;         is the dominant language")
;        ("Python" . "Would you expect anything less? Have at least one
;         original repo where Python is the dominant language"))
(define (badges-to-descriptions user)
  (define badge-hash (make-hash))
  (for ([badge (user-badges user)])
    (hash-set! badge-hash (badge-name badge) (badge-description badge)))
  badge-hash)
