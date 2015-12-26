#lang racket/base

(provide W H        ;; scene dimensions
         MAX-SSD
         START-VEL
         MAX-SPYVEL
         MIN-SPYVEL
         MAX-VEL
         MIN-VEL
         SHOT-VEL
         MAX-XVEL
         MIN-XVEL
         MAX-ENEMYVEL
         )

;; TODO document what the constants defined here mean

;;; Constant data defined

(define W 600)
(define H 800)

(define MAX-SSD 15)
(define START-VEL 5)
(define MAX-SPYVEL 50)
(define MIN-SPYVEL 10)
(define MAX-VEL 45)
(define MIN-VEL -15)
(define SHOT-VEL 50)
(define MAX-XVEL 2) ;10
(define MIN-XVEL -10) ;-10
(define MAX-ENEMYVEL 10) ;20
