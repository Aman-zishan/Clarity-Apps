
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
        duration: uint,
        message: (string-utf8 500)
    }
    ;; Tuple value:
    {
        owner: none,
        start-time: u0,
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
(define-public (rent-billboard (message (string-utf8 500)) (duration uint))
    (begin
        (asserts! (is-none (get-billboard-owner)) err-billboard-locked)
        ;;TODO: Implement the remaining logic
    )
)

;; read only functions
(define-read-only (get-billboard-owner) 
    (ok (get owner (var-get billboard)))
)

;; private functions
;;

