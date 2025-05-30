;; MedSupplyTrack - Medical supply chain tracking and verification
;; Version: 1.0.0

;; Data structures
(define-map supply-items
  { item-id: (string-ascii 64) }
  { 
    product-name: (string-ascii 64),
    manufacturer: (string-ascii 64),
    manufacture-date: uint,
    expiry-date: uint,
    batch-number: (string-ascii 32),
    current-custodian: principal,
    status: (string-ascii 16)
  })

(define-map custody-events
  { item-id: (string-ascii 64), event-id: uint }
  {
    timestamp: uint,
    from: principal,
    to: principal,
    location: (string-ascii 64),
    temperature: int,
    humidity: int
  })

(define-data-var admin principal tx-sender)
(define-data-var event-counter uint u0)

;; Register a new medical supply item
(define-public (register-item
  (item-id (string-ascii 64))
  (product-name (string-ascii 64))
  (manufacturer (string-ascii 64))
  (manufacture-date uint)
  (expiry-date uint)
  (batch-number (string-ascii 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (not (is-some (map-get? supply-items { item-id: item-id }))) (err u409))
    (ok (map-set supply-items
      { item-id: item-id }
      { 
        product-name: product-name,
        manufacturer: manufacturer,
        manufacture-date: manufacture-date,
        expiry-date: expiry-date,
        batch-number: batch-number,
        current-custodian: tx-sender,
        status: "manufactured"
      }))))

;; Transfer custody of an item
(define-public (transfer-custody
  (item-id (string-ascii 64))
  (to principal)
  (location (string-ascii 64))
  (temperature int)
  (humidity int))
  (let ((item (map-get? supply-items { item-id: item-id }))
        (event-id (var-get event-counter)))
    (begin
      (asserts! (is-some item) (err u404))
      (asserts! (is-eq (get current-custodian (unwrap-panic item)) tx-sender) (err u403))
      (map-set custody-events
        { item-id: item-id, event-id: event-id }
        {
          timestamp: stacks-block-height,
          from: tx-sender,
          to: to,
          location: location,
          temperature: temperature,
          humidity: humidity
        })
      (map-set supply-items
        { item-id: item-id }
        (merge (unwrap-panic item) { current-custodian: to }))
      (var-set event-counter (+ event-id u1))
      (ok event-id))))

;; Update the status of an item
(define-public (update-status
  (item-id (string-ascii 64))
  (new-status (string-ascii 16)))
  (let ((item (map-get? supply-items { item-id: item-id })))
    (begin
      (asserts! (is-some item) (err u404))
      (asserts! (is-eq (get current-custodian (unwrap-panic item)) tx-sender) (err u403))
      (ok (map-set supply-items
        { item-id: item-id }
        (merge (unwrap-panic item) { status: new-status }))))))

;; Get item details
(define-read-only (get-item-details (item-id (string-ascii 64)))
  (map-get? supply-items { item-id: item-id }))

;; Get custody event
(define-read-only (get-custody-event (item-id (string-ascii 64)) (event-id uint))
  (map-get? custody-events { item-id: item-id, event-id: event-id }))

;; Check if an item is expired
(define-read-only (is-expired (item-id (string-ascii 64)))
  (let ((item (map-get? supply-items { item-id: item-id })))
    (if (is-some item)
      (>= stacks-block-height (get expiry-date (unwrap-panic item)))
      false)))
      