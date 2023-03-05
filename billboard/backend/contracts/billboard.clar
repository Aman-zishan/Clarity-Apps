
;; title: billboard
;; version: 1.0.0
;; description: billboard smart contact that people can 'rent' by paying 100 stx per day. Duration can be 1,2 or 3 days


;; constants
(define-constant admin 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(define-constant err-admin-only (err u100))
(define-constant err-billboard-locked (err u101))
(define-constant err-insufficient-balance (err u102))

;; data vars & maps
(define-data-var message-history (list 10 {renter: principal, message: (string-utf8 500)}) (list))

(define-data-var billboard-locked bool false)
(define-data-var billboard-expiry uint u0)
(define-data-var billboard
    ;; Tuple type definition:
    {
        owner: principal,
        start-time: uint,
        duration: uint,
        message: (string-utf8 500),
    }
    ;; Tuple value:
    {
        owner: admin,
        start-time: block-height,
        duration: u0,
        message: u"Your BillBoard Message Here!",
    }
)
(define-data-var rent uint u100)

;; public functions

;; Function to update rent price -> accessible only by the admin
;; #[allow(unchecked_data)]
(define-public (set-new-rent (price uint)) 
    (begin 
        (asserts! (is-eq tx-sender admin) err-admin-only)
        (var-set rent price)
        (ok "Rent price updated successfully!")
    )
)

;; Function to rent billboard
;; #[allow(unchecked_data)]
(define-public (rent-billboard (billboard_message (string-utf8 500)) (billboard_duration uint))
    (let 
        (
        (start-timestamp block-height)
        ;; block time considered as 1 block mined per sec
        (end-timestamp (+ start-timestamp (* billboard_duration u1440)))
        )
        ;; if block height >= end-time of current billboard change lock status to false for new rental
        (if (>= block-height (var-get billboard-expiry))
            (var-set billboard-locked false)
            (var-set billboard-locked true)
        )
        (asserts! (is-eq (var-get billboard-locked) false) err-billboard-locked)
        (asserts! (>= (stx-get-balance tx-sender) (* ( var-get rent) billboard_duration) ) err-insufficient-balance)
        (try! (stx-transfer? (* ( var-get rent) billboard_duration) tx-sender (as-contract tx-sender)))
        (var-set billboard 
            (merge (var-get billboard) {  
                owner: tx-sender,
                start-time: start-timestamp,
                duration: billboard_duration,
                message: billboard_message,
                }
            )
        )
        (var-set billboard-expiry end-timestamp)
        (var-set billboard-locked true)  
        ;;implement message history
        (append (var-get message-history) {renter: tx-sender, message: billboard_message})
                
        (ok "Billboard rented!")
        
    ) 
)

;; read only functions
(define-read-only (get-block-height) 
    block-height
)

(define-read-only (get-billboard-expiry) 
    (var-get billboard-expiry)
)

(define-read-only (get-billboard-owner) 
    (get owner (var-get billboard))
)

(define-read-only (get-rent) 
    (var-get rent)
)

(define-read-only (get-billboard) 
    (var-get billboard)   
)

(define-read-only (get-contract-balance) 
    (stx-get-balance (as-contract tx-sender))
)

(define-read-only (get-billboard-history) 
    (var-get message-history)
)






