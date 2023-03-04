(define-map counters principal uint)

(map-set counters 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK u5)
(map-set counters 'ST20ATRN26N9P05V2F1RHFRV24X8C8M3W54E427B2 u10)

(define-read-only (get-counter-of (who principal))
	(unwrap! (map-get? counters who) u0)
)

;; These exist:
(print (get-counter-of 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK))
(print (get-counter-of 'ST20ATRN26N9P05V2F1RHFRV24X8C8M3W54E427B2))

;; This one does not:
(print (get-counter-of 'ST21HMSJATHZ888PD0S0SSTWP4J61TCRJYEVQ0STB))


(asserts! (is-eq (get-counter-of 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK) u5) "That does not seem to be right, try again...")
(asserts! (is-eq (get-counter-of 'ST20ATRN26N9P05V2F1RHFRV24X8C8M3W54E427B2) u10) "Almost there, keep going!")
(asserts! (is-eq (get-counter-of 'ST21HMSJATHZ888PD0S0SSTWP4J61TCRJYEVQ0STB) u0) "get-counter-of should return u0 if the principal does not exist in the map.")
