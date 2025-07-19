(define-constant ERR_INVALID_TASK (err u100))
(define-constant ERR_NOT_AUTHORIZED (err u101))
(define-constant ERR_ALREADY_COMPLETED (err u102))
(define-constant ERR_NO_TASKS_FOUND (err u103))
(define-constant ERR_INVALID_COLLABORATOR (err u104))
(define-constant ERR_INVALID_PRIORITY (err u105))

(define-data-var task-counter uint u0)

(define-map tasks { task-id: uint } { description: (string-ascii 100), completed: bool, owner: principal, priority: uint })
(define-map task-collaborators { task-id: uint, collaborator: principal } { active: bool })

(define-public (create-task (description (string-ascii 100)))
  (let ((task-id (var-get task-counter)))
    (begin
      (map-insert tasks { task-id: task-id } { description: description, completed: false, owner: tx-sender, priority: u0 })
      (var-set task-counter (+ task-id u1))
      (ok task-id)
    )
  )
)

(define-public (complete-task (task-id uint))
  (let ((task (unwrap! (map-get? tasks { task-id: task-id }) ERR_INVALID_TASK)))
    (begin
      (asserts! (is-eq (get owner task) tx-sender) ERR_NOT_AUTHORIZED)
      (asserts! (not (get completed task)) ERR_ALREADY_COMPLETED)
      (map-set tasks { task-id: task-id } { description: (get description task), completed: true, owner: tx-sender, priority: (get priority task) })
      (ok true)
    )
  )
)

(define-public (update-task-description (task-id uint) (new-description (string-ascii 100)))
  (let ((task (unwrap! (map-get? tasks { task-id: task-id }) ERR_INVALID_TASK)))
    (begin
      (asserts! (is-eq (get owner task) tx-sender) ERR_NOT_AUTHORIZED)
      (asserts! (not (get completed task)) ERR_ALREADY_COMPLETED)
      (map-set tasks { task-id: task-id } { description: new-description, completed: (get completed task), owner: tx-sender, priority: (get priority task) })
      (ok true)
    )
  )
)

(define-public (delete-task (task-id uint))
  (let ((task (unwrap! (map-get? tasks { task-id: task-id }) ERR_INVALID_TASK)))
    (begin
      (asserts! (is-eq (get owner task) tx-sender) ERR_NOT_AUTHORIZED)
      (asserts! (not (get completed task)) ERR_ALREADY_COMPLETED)
      (map-delete tasks { task-id: task-id })
      (ok true)
    )
  )
)

(define-public (transfer-task-ownership (task-id uint) (new-owner principal))
  (let ((task (unwrap! (map-get? tasks { task-id: task-id }) ERR_INVALID_TASK)))
    (begin
      (asserts! (is-eq (get owner task) tx-sender) ERR_NOT_AUTHORIZED)
      (asserts! (not (get completed task)) ERR_ALREADY_COMPLETED)
      (map-set tasks { task-id: task-id } { description: (get description task), completed: (get completed task), owner: new-owner, priority: (get priority task) })
      (ok true)
    )
  )
)

(define-public (assign-task-collaborator (task-id uint) (collaborator principal))
  (let ((task (unwrap! (map-get? tasks { task-id: task-id }) ERR_INVALID_TASK)))
    (begin
      (asserts! (is-eq (get owner task) tx-sender) ERR_NOT_AUTHORIZED)
      (asserts! (not (is-eq collaborator tx-sender)) ERR_INVALID_COLLABORATOR)
      (asserts! (not (get completed task)) ERR_ALREADY_COMPLETED)
      (map-set task-collaborators { task-id: task-id, collaborator: collaborator } { active: true })
      (ok true)
    )
  )
)

(define-public (remove-task-collaborator (task-id uint) (collaborator principal))
  (let ((task (unwrap! (map-get? tasks { task-id: task-id }) ERR_INVALID_TASK)))
    (begin
      (asserts! (is-eq (get owner task) tx-sender) ERR_NOT_AUTHORIZED)
      (asserts! (not (get completed task)) ERR_ALREADY_COMPLETED)
      (map-delete task-collaborators { task-id: task-id, collaborator: collaborator })
      (ok true)
    )
  )
)

(define-public (set-task-priority (task-id uint) (priority uint))
  (let ((task (unwrap! (map-get? tasks { task-id: task-id }) ERR_INVALID_TASK)))
    (begin
      (asserts! (is-eq (get owner task) tx-sender) ERR_NOT_AUTHORIZED)
      (asserts! (not (get completed task)) ERR_ALREADY_COMPLETED)
      (asserts! (<= priority u2) ERR_INVALID_PRIORITY)
      (map-set tasks { task-id: task-id } { description: (get description task), completed: (get completed task), owner: tx-sender, priority: priority })
      (ok true)
    )
  )
)

(define-read-only (get-task (task-id uint))
  (map-get? tasks { task-id: task-id })
)

(define-read-only (get-tasks-by-owner (owner principal))
  (let ((task-ids (generate-range (var-get task-counter))))
    (ok (filter-tasks-by-owner task-ids owner))
  )
)

(define-read-only (get-tasks-by-priority (owner principal) (priority uint))
  (let ((task-ids (generate-range (var-get task-counter))))
    (ok (filter-tasks-by-priority task-ids owner priority))
  )
)

(define-private (generate-range (n uint))
  (if (> n u0)
    (unwrap-panic (as-max-len? 
      (fold generate-range-iter 
        (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19) 
        (list)) 
      u20))
    (list)
  )
)

(define-private (generate-range-iter (i uint) (acc (list 20 uint)))
  (if (< i (var-get task-counter))
    (unwrap-panic (as-max-len? (append acc i) u20))
    acc
  )
)

(define-private (filter-tasks-by-owner (task-ids (list 20 uint)) (owner principal))
  (fold filter-tasks-by-owner-iter task-ids (list))
)

(define-private (filter-tasks-by-owner-iter (task-id uint) (acc (list 20 { task-id: uint, description: (string-ascii 100), completed: bool, owner: principal, priority: uint })))
  (match (map-get? tasks { task-id: task-id })
    task (if (is-eq (get owner task) owner)
           (unwrap-panic (as-max-len? (append acc (merge task { task-id: task-id })) u20))
           acc)
    acc
  )
)

(define-private (filter-tasks-by-priority (task-ids (list 20 uint)) (owner principal) (priority uint))
  (fold filter-tasks-by-priority-iter task-ids (list))
)

(define-private (filter-tasks-by-priority-iter (task-id uint) (acc (list 20 { task-id: uint, description: (string-ascii 100), completed: bool, owner: principal, priority: uint })))
  (match (map-get? tasks { task-id: task-id })
    task (if (and (is-eq (get owner task) owner) (is-eq (get priority task) priority))
           (unwrap-panic (as-max-len? (append acc (merge task { task-id: task-id })) u20))
           acc)
    acc
  )
)
