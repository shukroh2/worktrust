(define-map users principal
  { role: (string-ascii 16), profile-uri: (string-utf8 256), stake: uint, trust-score: uint })

(define-map jobs uint
  { client: principal, freelancer: principal, milestones: (list 10 uint), status: (string-ascii 16), paid: uint })

(define-map submissions (tuple (job-id uint) (ms-id uint)) (tuple (uri (string-utf8 256)) (status (string-ascii 16))))
(define-map ai-scores (tuple (job-id uint) (ms-id uint)) uint)

(define-map disputes (tuple (job-id uint)) 
  { jurors: (list 7 principal), votes: (list 7 bool), resolved: bool })

(define-map rep-nft principal {score: uint, wins: uint, fails: uint, disputes: uint})

(define-map freelancer-auctions principal {min-bid: uint, top-bidder: principal, amount: uint})

(define-map dao-proposals uint { proposer: principal, title: (string-utf8 100), votes-for: uint, votes-against: uint, executed: bool })

(define-map referrals principal (list 10 principal))
(define-map subscriptions principal {tier: (string-ascii 16), expiry: uint})

;; Helper function for max
(define-read-only (max (a uint) (b uint))
  (if (> a b) a b))

;; Helper function for min
(define-read-only (min (a uint) (b uint))
  (if (< a b) a b))

;; Add counters for jobs and users
(define-data-var total-jobs uint u0)
(define-data-var total-users uint u0)

;; Add a proposal counter
(define-data-var proposal-counter uint u0)

;; User Registration and Staking
(define-public (register (role (string-ascii 16)) (profile-uri (string-utf8 256)))
  (begin
    (map-insert users tx-sender {role: role, profile-uri: profile-uri, stake: u0, trust-score: u50})
    (var-set total-users (+ (var-get total-users) u1))
    (ok true)))

(define-public (stake-tokens (amount uint))
  (let ((transfer-result (stx-transfer? amount tx-sender (as-contract tx-sender))))
    (match transfer-result
      ok-value
        (let ((current (default-to {role: "                ", profile-uri: u"", stake: u0, trust-score: u0} (map-get? users tx-sender))))
          (map-set users tx-sender (merge current {stake: (+ (get stake current) amount)}))
          (ok true))
      err-value
        transfer-result)))

;; Job Management
(define-public (create-job (freelancer principal) (milestones (list 10 uint)) (total uint))
  (let (
    (job-id (+ (var-get total-jobs) u1))
    )
    (let ((transfer-result (stx-transfer? total tx-sender (as-contract tx-sender))))
      (match transfer-result
        ok-value
          (begin
            (map-insert jobs job-id {client: tx-sender, freelancer: freelancer, milestones: milestones, status: "active", paid: total})
            (var-set total-jobs job-id)
            (ok job-id))
        err-value
          (err transfer-result)))))

;; Milestone Submission & AI Grading
(define-public (submit-milestone (job-id uint) (ms-id uint) (uri (string-utf8 256)))
  (begin
    (map-set submissions {job-id: job-id, ms-id: ms-id} {uri: uri, status: "submitted"})
    (ok true)))

(define-public (oracle-grade (job-id uint) (ms-id uint) (score uint))
  (begin
    ;; (asserts! (is-eq tx-sender 'SP2C2PYZ6KX8QZQZQZQZQZQZQZQZQZQZQZQZQ) (err u500))
    (map-set ai-scores {job-id: job-id, ms-id: ms-id} score)
    (ok true)))

;; Disputes & DAO Jury
(define-public (raise-dispute (job-id uint) (ms-id uint))
  (begin
    (map-set disputes {job-id: job-id} {jurors: (list), votes: (list), resolved: false})
    (ok true)))

(define-public (vote-dispute (job-id uint) (ms-id uint) (decision bool))
  (let ((d (map-get? disputes {job-id: job-id})))
    (asserts! (is-some d) (err u404))
    ;; validate juror and append vote logic here
    (ok true)))

;; Reputation NFT and DID
(define-public (update-reputation (user principal) (delta int))
  (let ((r (default-to {score: u50, wins: u0, fails: u0, disputes: u0} (map-get? rep-nft user))))
    (begin
      (map-set rep-nft user
        {score: (max u0 (to-uint (+ (to-int (get score r)) delta))), wins: (get wins r), fails: (get fails r), disputes: (get disputes r)})
      (ok true))))

(define-read-only (get-did-score (user principal))
  (let (
        (u (default-to {role: "                ", profile-uri: u"", stake: u0, trust-score: u0} (map-get? users user)))
        (r (default-to {score: u0, wins: u0, fails: u0, disputes: u0} (map-get? rep-nft user)))
       )
    (ok (min u100 (+ (get trust-score u) (/ (get score r) u2))))))

;; Freelancer Auction
(define-public (start-auction (min-bid uint))
  (begin
    (map-set freelancer-auctions tx-sender {min-bid: min-bid, top-bidder: tx-sender, amount: u0})
    (ok true)))

(define-public (place-bid (freelancer principal) (amount uint))
  (let ((a (default-to {min-bid: u0, top-bidder: tx-sender, amount: u0} (map-get? freelancer-auctions freelancer))))
    (let ((current-amount (get amount a)))
      (asserts! (> amount current-amount) (err u403))
      (let ((transfer-result (stx-transfer? amount tx-sender (as-contract tx-sender))))
        (match transfer-result
          ok-value
            (begin
              (map-set freelancer-auctions freelancer {min-bid: (get min-bid a), top-bidder: tx-sender, amount: amount})
              (ok true))
          err-value
            transfer-result)))))

;; DAO Proposals
(define-public (submit-proposal (title (string-utf8 100)))
  (let ((id (var-get proposal-counter)))
    (map-insert dao-proposals id {proposer: tx-sender, title: title, votes-for: u0, votes-against: u0, executed: false})
    (var-set proposal-counter (+ id u1))
    (ok id)))

(define-public (vote-proposal (id uint) (vote bool))
  (let ((p (map-get? dao-proposals id)))
    ;; validate and update votes logic here
    (ok true)))

(define-public (execute-proposal (id uint))
  ;; implement proposal if passed logic here
  (ok true))

;; Referral and Subscription
(define-public (subscribe (tier (string-ascii 16)) (duration uint))
  (let ((transfer-result (stx-transfer? (* u10 duration) tx-sender (as-contract tx-sender))))
    (match transfer-result
      ok-value
        (begin
          (map-set subscriptions tx-sender {tier: tier, expiry: duration})
          (ok true))
      err-value
        transfer-result)))

(define-public (refer (new-user principal))
  (begin
    (map-set referrals tx-sender (list new-user))
    (ok true)))