
;; title: stxmessage
;; version: 0.0.1
;; description: Smart contract to handle writing a message to the blockchain in exchange for a small fee in STX

;; constants
(define-constant reciever-address 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM )

;; data maps and vars
(define-data-var total-stxmessages uint u0)
(define-map messages principal (string-utf8 500))

;; public functions

;; #[allow(unchecked_data)]
(define-public (write-stxmessage (message (string-utf8 500)) (price uint)) 
    (begin 
        (try! (stx-transfer? price tx-sender reciever-address)) 

        (map-set messages tx-sender message)

        (var-set total-stxmessages (+ (var-get total-stxmessages) u1))

        (ok "Stx Message written Succesfully")
    )
)

;; read only functions
(define-read-only (get-stxmessages) 
    (var-get total-stxmessages))

(define-read-only (get-messages (who principal)) 
    (map-get? messages who))

;; private functions
;;

