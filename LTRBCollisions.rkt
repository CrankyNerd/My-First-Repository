;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname LTRBCollisions) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ())))
(require 2htdp/image)


;;;;; a LTRB is a (make-LTRB Number Number Number Number)
(define-struct LTRB (left-x top-y right-x bottom-y))

(define ltrb1 (make-LTRB 0 0 10 10))
(define ltrb2 (make-LTRB 10 20 15 400))

;;template for functions processing LTRB
#; (define (fun-for-LTRB LTRB) ;fun-for-LTRB LTRB --> ???
     (... (LTRB-left-x LTRB) ...
          (LTRB-top-y LTRB) ...
          (LTRB-right-x LTRB) ...
          (LTRB-bottom-y LTRB) ...))

;; inside-LTRB? posn LTRB --> Boolean
; determine whether a point is inside a LTRB
; does not determine if point is on edge of LTRB
(check-expect (inside-LTRB? (make-posn 10 4) ltrb1)
              false)
(check-expect (inside-LTRB? (make-posn 13 100) ltrb2)
              true)
(check-expect (inside-LTRB? (make-posn -1 1) (make-LTRB -3 -5 10 7))
              true)
(check-expect (inside-LTRB? (make-posn 20 4) (make-LTRB 10 2 90 11))
              true)
(check-expect (inside-LTRB? (make-posn 1/2 1/4) (make-LTRB 1/3 1/8 80/3 18/42))
              true)

(define (inside-LTRB? p l)
  (and (< (LTRB-left-x l) (posn-x p) (LTRB-right-x l))
       (> (LTRB-bottom-y l) (posn-y p) (LTRB-top-y l))))

;; overlapping? LTRB LTRB --> Boolean
; determine if two LTRBs are overlapping
; will not be overlapping if only their edges are toucing
(check-expect (overlapping? ltrb1 ltrb2)
              false)
(check-expect (overlapping? ltrb1 (make-LTRB 15 15 9 9))
              true)
(check-expect (overlapping? ltrb2 (make-LTRB 14 114 9 9))
              true)
(check-expect (overlapping? ltrb2 (make-LTRB 1 35 13 500))
              true)
(check-expect (overlapping? ltrb2 (make-LTRB 14 1 25 35))
              true)

(define (overlapping? l1 l2)
  (or (inside-LTRB? (make-posn (LTRB-left-x l2) (LTRB-top-y l2)) l1)
      (inside-LTRB? (make-posn (LTRB-left-x l2) (LTRB-bottom-y l2)) l1)
      (inside-LTRB? (make-posn (LTRB-right-x l2) (LTRB-top-y l2)) l1)
      (inside-LTRB? (make-posn (LTRB-right-x l2) (LTRB-bottom-y l2)) l1)
      (inside-LTRB? (make-posn (LTRB-left-x l1) (LTRB-top-y l1)) l2)
      (inside-LTRB? (make-posn (LTRB-left-x l1) (LTRB-bottom-y l1)) l2)
      (inside-LTRB? (make-posn (LTRB-right-x l1) (LTRB-bottom-y l1)) l2)
      (inside-LTRB? (make-posn (LTRB-right-x l1) (LTRB-top-y l1)) l2)))


;;;;; contains? LTRB LTRB --> Boolean
;; tells wether the first LTRB is entirely inside or coinciding with
; the second LTRB
(check-expect (contains? ltrb1 (make-LTRB 0 0 10 10))
              true)
(check-expect (contains? (make-LTRB 20 60 100 300)
                         (make-LTRB 30 70 90 124))
              true)
(check-expect (contains? (make-LTRB 20 60 100 300)
                         (make-LTRB 1002 3243 312 4311))
              false)
(check-expect (contains? (make-LTRB 10 20 39 12)
                         (make-LTRB 10 20 39 12))
              true)
(check-expect (contains? (make-LTRB -20 -40 12 -3)
                         (make-LTRB -9 -32 0 -4))
              true)

(define (contains? r1 r2)
  (or
   (and (inside-LTRB? (make-posn (LTRB-left-x r2) (LTRB-top-y r2)) r1)
        (inside-LTRB? (make-posn (LTRB-left-x r2) (LTRB-bottom-y r2)) r1)
        (inside-LTRB? (make-posn (LTRB-right-x r2) (LTRB-top-y r2)) r1)
        (inside-LTRB? (make-posn (LTRB-right-x r2) (LTRB-bottom-y r2)) r1))
   (and (= (LTRB-left-x r1) (LTRB-left-x r2))
        (= (LTRB-right-x r1) (LTRB-right-x r2))
        (= (LTRB-top-y r1) (LTRB-top-y r2))
        (= (LTRB-bottom-y r1) (LTRB-bottom-y r2)))))

;;;;; inbetween-y? LTRB LTRB --> Boolean
;; determines wether the y-value of either the
;;top or the bottom of the first LTRB is inbetween the other's top and bottom
(check-expect (inbetween-y? ltrb1 ltrb2) false)
(check-expect (inbetween-y? ltrb1 (make-LTRB 10 8 19 25)) true)

(define (inbetween-y? l1 l2)
  (or (> (LTRB-bottom-y l1) (LTRB-top-y l2) (LTRB-top-y l1))
      (> (LTRB-bottom-y l1) (LTRB-bottom-y l2) (LTRB-top-y l1))))

;;;;; inbetween-x? LTRB LTRB --> Boolean
;; determines wether the x-value of either the
;;top or the bottom of the first LTRB is
;;inbetween the other's left-x and right-x
(check-expect (inbetween-x? ltrb1 (make-LTRB 10 100 23 48)) false)
(check-expect (inbetween-x? (make-LTRB 3 100 23 48) ltrb1) true)
(check-expect (inbetween-x? ltrb2 (make-LTRB 3 100 14 48)) true)

(define (inbetween-x? l1 l2)
  (or (< (LTRB-left-x l1) (LTRB-right-x l2) (LTRB-right-x l1))
      (< (LTRB-right-x l1) (LTRB-left-x l2) (LTRB-right-x l1))))

;;;;; touching? LTRB LTRB --> Boolean
;; determine if two LTRBs are touching
;; by being within one another or sharing some edge
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
;;so many check-expects!!

(define (touching? l1 l2)
  (or
   (contains? l1 l2)
   (contains? l2 l1)
   (and (= (LTRB-right-x l2) (LTRB-left-x l1))
        (or (inbetween-y? l1 l2)
            (inbetween-y? l2 l1)))
   (and (= (LTRB-left-x l2) (LTRB-right-x l1))
        (inbetween-y? l2 l1)
        (inbetween-y? l1 l2))
   (and (= (LTRB-top-y l2) (LTRB-bottom-y l1))
        (or (inbetween-x? l2 l1)
            (inbetween-x? l1 l2))) ;argh, can't figure out proper check-expect
   (and (= (LTRB-bottom-y l2) (LTRB-top-y l1))
        (or (inbetween-x? l2 l1)
            (inbetween-x? l1 l2)))))

;;;;; compute-LTRB: Posn Image --> LTRB
;;produce an image's LTRB
(check-expect (compute-LTRB (make-posn 10 10)
                            (square 6 'solid 'red))
              (make-LTRB 7 7 13 13))
(check-expect (compute-LTRB (make-posn 0 0)
                            (square 15 'solid 'red))
              (make-LTRB -7.5 -7.5 7.5 7.5))

(define (compute-LTRB p img)
  (make-LTRB (- (posn-x p) (* 1/2 (image-width img)))
             (- (posn-y p) (* 1/2 (image-height img)))
             (+ (posn-x p) (* 1/2 (image-width img)))
             (+ (posn-y p) (* 1/2 (image-height img)))))

;;;;; comput-LTRB/inset: Posn Image Number --> LTRB
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









