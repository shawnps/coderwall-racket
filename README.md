coderwall_racket
================

A racket client for the Coderwall API

Example of how to get a hash of team members' names to badges:
```Racket
(define rackspace (make-team "4f271941973bf0000400037b"))
(define rackspace-users-to-badges (user-names-to-badges rackspace))
rackspace-users-to-badges
```

Get list of badge names for a user:
```Racket
> (define shawn (make-user "shawnps"))
> (user-badge-names shawn)
'("Python 3" "Python" "Castor" "Charity")
```

Get a hash of user badge names to descriptions:
```Racket
> (define shawn (make-user "shawnps"))
> (badges-to-descriptions shawn)
'#hash(("Charity" . "Fork and commit to someone's open source project in need")
       ("Castor" . "Made something awesome")
       ("Python 3" . "Have at least three original repos where Python is the dominant language")
       ("Python" . "Would you expect anything less? Have at least one original repo where Python is the dominant language"))
```
