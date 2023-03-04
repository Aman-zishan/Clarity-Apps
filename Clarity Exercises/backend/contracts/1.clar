(define-constant err-invalid-caller (err u1))

(define-map authorised-callers principal bool)
(define-map recipients principal bool)

(map-set recipients tx-sender true)
(map-set authorised-callers 'ST20ATRN26N9P05V2F1RHFRV24X8C8M3W54E427B2 true)

(define-private (is-valid-caller (caller principal))
   ;;IMPLEMENT
  (not (is-none(map-get? authorised-callers caller)))
  (unwrap! (map-get? authorised-callers caller) false)
  )
  
  

(define-public (delete-recipient (recipient principal))
  (if (is-valid-caller tx-sender)
     (ok (map-delete recipients recipient))
     err-invalid-caller))
  


(print (delete-recipient tx-sender))
(print tx-sender)
(print (is-valid-caller 'ST20ATRN26N9P05V2F1RHFRV24X8C8M3W54E427B2))
(asserts! (not (is-valid-caller tx-sender)) "That does not seem right, try again...")
(asserts! (is-valid-caller 'ST20ATRN26N9P05V2F1RHFRV24X8C8M3W54E427B2) "Almost there, try again!")