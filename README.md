coderwall_racket
================

A racket client for the Coderwall API

Example of how to get a hash of team members' names to badges:
```Racket
(define rackspace (make-team "4f271941973bf0000400037b"))
(define rackspace-users-to-badges (user-names-to-badges rackspace))
rackspace-users-to-badges
```
