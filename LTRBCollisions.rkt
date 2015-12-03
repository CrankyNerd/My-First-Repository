#lang racket
(require 2htdp/image
         test-engine/racket-tests
         lang/posn)
(provide all-defined-out)

;;;;; a LTRB is a (make-LTRB Number Number Number Number)
(define-struct LTRB (left-x top-y right-x bottom-y))

(define ltrb1 (make-LTRB 0 0 10 10)) ;; overlapping with ltrb3 and
;; overlapping on edge with ltrb4
(define ltrb2 (make-LTRB 10 20 15 400)) ;; not overlapping anything
(define ltrb3 (make-LTRB 5 0 35 20)) ;; overlapping with ltrb1 and ltrb4
(define ltrb4 (make-LTRB 10 3 15 15)) ;; completely inside ltrb3
(define ltrb5 (make-LTRB 9 18 13 34)) ;; intersects with top of ltrb2
(define ltrb6 (make-LTRB 10 3 15 15)) ;; coincides with ltrb4
(define ltrb7 (make-LTRB 50 20 70 100)) ;; doesn't touch anything

;; rectangles corresponding to their LTRB conternumbers
(define rect1 (rectangle 10 10 'solid 'red))
(define rect2 (rectangle 5 380 'solid 'red))
(define rect3 (rectangle 30 20 'solid 'red))
(define rect4 (rectangle 5 12 'solid 'red))

;;template for functions processing LTRB
#; (define (fun-for-LTRB LTRB) ;fun-for-LTRB LTRB --> ???
     (... (LTRB-left-x LTRB) ...
          (LTRB-top-y LTRB) ...
          (LTRB-right-x LTRB) ...
          (LTRB-bottom-y LTRB) ...))

;; compute-ltrb: Num Num img --> LTRB
;; makes an LTRB for an image. the numbers are the image-center's x and y coor.
(check-expect (compute-ltrb 5 5 rect1) ltrb1)
(check-expect (compute-ltrb 20 10 rect3) ltrb3)
(check-expect (compute-ltrb 10 10
                            (square 6 'solid 'red))
              (make-LTRB 7 7 13 13))
(check-expect (compute-ltrb 0 0
                            (square 15 'solid 'red))
              (make-LTRB -7.5 -7.5 7.5 7.5))

(define (compute-ltrb x y img)
  (make-LTRB (- x (* 1/2 (image-width img)))
             (- y (* 1/2 (image-height img)))
             (+ x (* 1/2 (image-width img)))
             (+ y (* 1/2 (image-height img)))))

;; inside?: LTRB LTRB --> Boolean
; determines if the first LTRB is contained completely inside of the second LTRB
(check-expect (inside? ltrb1 ltrb2) false)
(check-expect (inside? ltrb1 ltrb3) false)
(check-expect (inside? ltrb3 ltrb4) false) ;; ltrb4 is inside 3
(check-expect (inside? ltrb4 ltrb3) true)

(define (inside? l1 l2)
  (and (< (LTRB-left-x l2) (LTRB-left-x l1) (LTRB-right-x l1) (LTRB-right-x l2))
       (< (LTRB-top-y l2) (LTRB-top-y l1) (LTRB-bottom-y l1) (LTRB-bottom-y l2))
       ))

;; touching?: LTRB LTRB --> Boolean
;; determines if LTRBs are touching. touching includes sharing a side or inside
(check-expect (touching? ltrb1 ltrb4) true)
(check-expect (touching? ltrb3 ltrb2) true)
(check-expect (touching? ltrb2 ltrb6) false)
(check-expect (touching? ltrb4 ltrb3) true)
(check-expect (touching? ltrb3 ltrb4) true)
(check-expect (touching? ltrb4 ltrb1) true)
(check-expect (touching? ltrb1 ltrb2) false)
(check-expect (touching? ltrb1 (make-LTRB 2 4 5 7)) true)
(check-expect (touching? ltrb1 ltrb1) true)
(check-expect (touching? ltrb1 (make-LTRB 5 10 199 22)) true)
(check-expect (touching? ltrb2 (make-LTRB 5 30 10 60)) true)
(check-expect (touching? ltrb2 (make-LTRB 14 10 17 20)) true)
(check-expect (touching? ltrb2 (make-LTRB 1 5 10 401)) true)
(check-expect (touching? (make-LTRB 1 5 10 380) ltrb2) true)
(check-expect (touching? (make-LTRB 8 400 20 401) ltrb2) true)
(check-expect (touching? (make-LTRB 5 20 30 50) (make-LTRB 10 10 20 20)) true)

(define (touching? l1 l2)
  (or (inside? l1 l2)
      (inside? l2 l1)
      (and (touching-y? l1 l2)
           (touching-x? l1 l2))))

;helper
;; touching-y?: LTRB LTRB --> Boolean
;; determines if the LTRBs are touching in the one dimensional y axis
(check-expect (touching-y? ltrb1 ltrb2) false)
(check-expect (touching-y? ltrb1 ltrb4) true)
(check-expect (touching-y? ltrb1 ltrb3) true)
(check-expect (touching-y? ltrb4 ltrb6) true)
(check-expect (touching-y? ltrb5 ltrb2) true)
(define (touching-y? l1 l2)
  (or (<= (LTRB-top-y l1) (LTRB-top-y l2) (LTRB-bottom-y l1))
      (<= (LTRB-top-y l2) (LTRB-top-y l1) (LTRB-bottom-y l2))))
;helper
;; touching-x?: LTRB LTRB --> Boolean
;; determines if the LTRBs are touching in the one dimensional x axis
(check-expect (touching-x? ltrb1 ltrb7) false)
(check-expect (touching-x? ltrb1 ltrb4) true)
(check-expect (touching-x? ltrb6 ltrb3) true)
(check-expect (touching-x? ltrb3 ltrb6) true)
(check-expect (touching-x? ltrb5 ltrb2) true)
(define (touching-x? l1 l2)
  (or (<= (LTRB-left-x l1) (LTRB-left-x l2) (LTRB-right-x l1))
      (<= (LTRB-left-x l2) (LTRB-left-x l1) (LTRB-right-x l2))))

;; overlapping? LTRB LTRB --> Boolean
; determine if two LTRBs are overlapping
(check-expect (overlapping? ltrb1 ltrb2) false)
(check-expect (overlapping? ltrb3 ltrb7) false)
(check-expect (overlapping? ltrb5 ltrb2) true)
(check-expect (overlapping? ltrb2 ltrb5) true)
(check-expect (overlapping? ltrb1 ltrb3) true)
(check-expect (overlapping? ltrb4 ltrb6) true)

(define (overlapping? l1 l2)
  (or (inside? l1 l2)
      (inside? l2 l1)
      (touching? l1 l2)))

;;;;; compute-LTRB/inset: Posn Image Number --> LTRB
;;produce an LTRB with an inset of given Number of pixels
;On each of the LTRB's four sides
(check-expect (compute-LTRB/inset (make-posn 10 10)
                                  (square 6 'solid 'red)
                                  2)
              (make-LTRB 9 9 11 11))
(check-expect (compute-LTRB/inset (make-posn 0 0)
                                  (square 10 'solid 'red)
                                  3)
              (make-LTRB -2 -2 2 2))

(define (compute-LTRB/inset p img num)
  (make-LTRB (- (posn-x p)
                (+ (* -1 num) (* 1/2 (image-width img))))
             (- (posn-y p)
                (+ (* -1 num) (* 1/2 (image-height img))))
             (+ (posn-x p)
                (+ (* -1 num) (* 1/2 (image-width img))))
             (+ (posn-y p)
                (+ (* -1 num) (* 1/2 (image-height img))))))









