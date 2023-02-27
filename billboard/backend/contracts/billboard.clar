
;; title: billboard
;; version: 1.0.0
;; description: billboard smart contact that people can 'rent' by paying 100 stx per day. Duration can be 1,2 or 3 days


;; constants
(define-constant admin 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(define-constant err-admin-only (err u100))
(define-constant err-billboard-locked (err u101))

;; data vars & maps
(define-map messages principal (string-utf8 500))
(define-data-var message-index uint u0)
(define-data-var billboard
    ;; Tuple type definition:
    {
        owner: (optional principal),
        start-time: uint,
        end-time: uint,
        duration: uint,
        message: (string-utf8 500)
    }
    ;; Tuple value:
    {
        owner: none,
        start-time: u0,
        end-time: u0,
        duration: u0,
        message: u"Your BillBoard Message Here!"
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
(define-public (rent-billboard (billboard_message (string-utf8 500)) (billboard_duration uint))
    (begin

        (asserts! (is-none (get-billboard-owner)) err-billboard-locked)
            (if (>= block-height (get end-time (var-get billboard))) 
                (begin 
                    (merge (var-get billboard) {  
                        owner: none,
                        start-time: u0,
                        end-time: u0,
                        duration: u0,
                        message: u"Your BillBoard Message Here!"})    
                        (ok "expired billboard cleared")
                ) 
    
            (let ((start-timestamp block-height))
                ;; block time considered as 1 block mined per sec
                (let ((end-timestamp (+ start-timestamp (* billboard_duration u1440))))
                    (asserts! (>= block-height end-timestamp) err-billboard-locked)
                    (try! (stx-transfer? (* ( var-get rent) billboard_duration) tx-sender admin))
                    (merge (var-get billboard) {  
                        owner: tx-sender,
                        start-time: start-timestamp,
                        end-time: end-timestamp,
                        duration: billboard_duration,
                        message: billboard_message})   
                    (ok "New billboard rented!")
                )
            )
        ) 
    )
)

;; read only functions
(define-read-only (get-billboard-owner) 
     (get owner (var-get billboard))
)

(define-read-only (get-block-height) 
    block-height    
)
;; private functions
;;

