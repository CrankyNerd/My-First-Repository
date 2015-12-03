;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname SpyHunter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ())))
(require 2htdp/image)
(require test-engine/racket-tests)
(require 2htdp/universe)
#;(require "LTRBCollisions.rkt")
#|
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Constant data

-- sound

;;; Images:
-- player's car       ;;DONE
  -crash image
-- helper truck       ;;DONE
  - oil slick icon    ;;DONE
  - smoke screen icon ;;DONE
-- small enemy        ;;DONE
  -crash image
-- bullet-proof enemy ;;DONE
  -crash image

-- Background         ;;DONE
-- splashscreen       ;;DONE
-- gameover           ;;DONE

-- Bullet             ;;DONE
-- oil slick          ;;DONE
-- smoke screen       ;;DONE

;;; others

-- velocity of friendly cars
-- number of smoke screens obtained from truck
-- duration of smoke screen
-- INITIAL time of oil slick
-- starting position of helper trucks

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Dynamic data

-- score

-- time left on oil slick (when oil slick activated, countdown starts. and it
        stops when oil slick deactivated)

;;; Velocities
-- bullet velocity ;; UNLESS IT IS JUST AN IMAGE ABOVE CAR
-- enemy velocity
-- velocity of the background (because of the player's car)
-- velocity of helper truck

|#

;;; Constant data defined

(define W 600)
(define H 800)

(define MAX-SSD 5)
(define START-VEL 25)
(define MAX-VEL 45)
(define MIN-VEL 5)
(define SHOT-VEL 50)
(define MAX-XVEL 10)
(define MIN-XVEL -10)

;; BG
(define BG (beside (rectangle (* 1/6 W) (* 3 H) 'solid 'green)
                   (rectangle (* 2/3 W) (* 3 H) 'solid 'black)
                   (rectangle (* 1/6 W) (* 3 H) 'solid 'green)))
;; plain-bg
;; this is like BG, but it is fit to the 600 800 screen already
(define plain-bg (beside (rectangle (* 1/6 W) H 'solid 'green)
                         (rectangle (* 2/3 W) H 'solid 'black)
                         (rectangle (* 1/6 W) H 'solid 'green)))

;; splash-screen image
(define splash-image (overlay (text "Spy Hunter" 36 'red)
                              plain-bg))
;; EXAMPLE --- gameover-screen image
;; GAMEOVER IMAGES ARE NOT STATIC SO THEY ARE MADE IN THE RENDER FUNCTION
(define gameover-image (overlay (above (text "Game Over" 48 'red)
                                       (text "Spy Hunter" 36 'blue)
                                       (text "100000" 48 'red))
                                plain-bg))
;; os-image
;; the image for an oilslick
(define os-image (rectangle (* 1/20 W) (* 1/15 H) 'solid 'gray))
;; ss-image
;; the image for smokescreen
(define ss-image (rectangle (* 1/6 W) (* 1/10 H) 'solid 'white))
;; mini-ss-image
;; a small ss-image used as an icon
(define mini-ss-image (rectangle (* 1/10 W) (* 1/20 H) 'solid 'white))


;; spy car -- BASE POS. OF STRIPES + ROOF OFF W AND H
(define spy-body (rectangle (* 1/20 W) (* 1/15 H) 'solid 'burlywood))
(define spy-roof (rectangle (* 1/30 W) (* 1/60 H) 'solid 'moccasin))
(define spy-stripes (beside(rectangle (* 1/80 W) (* 1/45 H) 'solid 'blue)
                           (empty-scene (* 1/80 W) 0)
                           (rectangle (* 1/80 W) (* 1/45 H) 'solid 'blue)))
(define spy-car (place-image spy-stripes (* 1/40 W) (* 3/160 H)
                             (place-image spy-roof (* 1/40 W) (* 7/160 H)
                                          spy-body)))

;; friendly car
; uses the same code as spy, but with different colors.
(define frnd (place-image (beside(rectangle (* 1/80 W) (* 1/45 H)
                                            'solid 'black)
                                 (empty-scene (* 1/80 W) 0)
                                 (rectangle (* 1/80 W) (* 1/45 H)
                                            'solid 'black))
                          (* 1/40 W) (* 3/160 H)
                          (place-image
                           (rectangle (* 1/30 W) (* 1/60 H) 'solid 'firebrick)
                           (* 1/40 W) (* 7/160 H)
                           (rectangle (* 1/20 W) (* 1/15 H) 'solid 'darkred))
                          ))

;; mini-car
;; used for the lives left icon
(define mini-car (rectangle (* 1/50 W) (* 1/60 H) 'solid 'beige))

;; helper truck
(define trailer (rectangle (* 1/18 W) (* 1/12 H) 'solid 'darkred))
(define connector (rectangle (* 1/100 W) (* 1/180 H) 'solid 'firebrick))
(define nose (above (rectangle (* 1/25 W) (* 1/130 H) 'solid 'red)
                    (rectangle (* 1/18 W) (* 1/25 H) 'solid 'darkred)))
(define truck (above nose connector trailer))

;; small enemy
;; used the same code as spy and frnd -- changed colors
(define sml-enemy (place-image (beside(rectangle (* 1/80 W) (* 1/45 H)
                                                 'solid 'orangered)
                                      (empty-scene (* 1/80 W) 0)
                                      (rectangle (* 1/80 W) (* 1/45 H)
                                                 'solid 'orangered))
                               (* 1/40 W) (* 3/160 H)
                               (place-image
                                (rectangle (* 1/30 W) (* 1/60 H) 'solid 'navy)
                                (* 1/40 W) (* 7/160 H)
                                (rectangle (* 1/20 W) (* 1/15 H) 'solid
                                           'mediumblue))
                               ))
;; bullet proof enemy
;; used some modified spy code
(define bumper (rectangle (* 1/13 W) (* 1/160 H) 'solid 'darkgray))
(define back-bumper (rectangle (* 1/13 W) (* 1/200 H) 'solid 'darkgray))
(define lrg-enemy (above bumper ;;above added
                         (place-image (beside(rectangle (* 1/80 W) (* 1/45 H)
                                                        'solid 'black)
                                             (empty-scene (* 1/80 W) 0)
                                             (rectangle (* 1/80 W) (* 1/45 H)
                                                        'solid 'black))
                                      (* 1/30 W) (* 3/160 H)
                                      (place-image
                                       (rectangle (* 1/20 W) (* 1/60 H)
                                                  'solid 'navy)
                                       (* 1/30 W) (* 7/160 H) ;; new car width
                                       (rectangle (* 1/15 W) (* 1/15 H)
                                                  'solid 'mediumblue))
                                      )
                         back-bumper))



;; bullet images

(define bullet (above (rectangle (* 1/80 W) (* 1/60 H) 'solid 'yellow)
                      (empty-scene 0 (* 1/180 H))))

(define player-shot (beside
                     bullet
                     (empty-scene (* 1/80 W) 0)
                     bullet))

#| decided to use shots instead of bullet image animation
(define bullets1 (above/align 'right bullet
                              (above two-bullet-beside two-bullet-beside
                                     two-bullet-beside two-bullet-beside
                                     two-bullet-beside two-bullet-beside)))
(define bullets2 (above/align 'left bullet
                              (above two-bullet-beside two-bullet-beside
                                     two-bullet-beside two-bullet-beside
                                     two-bullet-beside two-bullet-beside)))

;; animate bullet

(define (animate-bullet n)
  (if (odd? n) bullets1
      bullets2))

;; friendly car velocity px/sec
(define frnd-vel 20)
|#

; Terrain
(define terrain (beside (rectangle (* 1/6 W) (* 1/4 H) 'solid 'green)
                        (rectangle (* 2/3 W) (* 1/4 H) 'solid 'black)
                        (rectangle (* 1/6 W) (* 1/4 H) 'solid 'green)))

;; a spy is a
;; (make-spy Num Num Nat Num Num)
(define-struct spy [x y vel osleft ssleft])
;; where x is the spy's x coordinate,
;; y is the car's y coordinate,
;; vel is the spy's velocity,
;; osleft is the number of oilslicks the spy has,
;; and ssleft is the number of smokescreens the spy has left.
(define spy1 (make-spy 300 400 0 0 0))
(define spy2 (make-spy 200 400 11 2 3))

;; an object is one of
;; - FriendlyCar
;; - small-enemy
;; - large-enemy
;; - hlpr-truck
;; - oilslick
;; - smokescreen

;; a FriendlyCar is a
;; (make-FriendlyCar Nat Num Num)
(define-struct FriendlyCar [x y vel])
;; x is the car's x coordinate
;; y is the car's y coordinate and
;; vel is the car's x velocity

;; a small-enemy is a 
;; (make-small-enemy Num Num Nat)
(define-struct small-enemy [x y vel xvel])
;; variables are same as FriendlyCar struct

;; a large-enemy is a 
;; (make-large-enemy Num Num Nat)
(define-struct large-enemy [x y vel xvel])

;; a hlpr-truck is a
;; (make-hlpr-truck Nat Num Symbol Num)
(define-struct hlpr-truck [x y gadget vel])
;; gadget is a symbol representing which gadget the truck is carrying
;; gadgets --> 'smokescreen 'oilslick

;; shot is a
;; (make-shot Num Num
(define-struct shot [x y])
;; where x is the shots x coordinate,
;; x is the shots y coordinate
(define shot1 (make-shot 150 380))
(define shot2 (make-shot 150 360))
(define shot3 (make-shot 150 340))

;; oilslick is a 
;; (make-os Num Num)
(define-struct os [x y])
;; where x is the oilslick's x coordinate and
;;       y is the oilslick's y coordinate

;; smokescreen is a 
;; (make-ss x y Num)
(define-struct ss [x y duration])

;; a List-of[Objects] (LOO) is one of:
;; empty
;; (cons object LOO)
(define LOO1 (list (make-os 300 400)
                   (make-ss 200 500 1)
                   (make-small-enemy 300 790 2 0)
                   (make-large-enemy 300 200 2 0)
                   (make-hlpr-truck 200 150 'os 3)
                   (make-FriendlyCar 400 150 5)))

;; a Listof[Num] (LON) is either
;; empty
;; (cons Num LON)
#;(define (fun-for-LON ls)
    (cond [(empty? ls) ...]
          [(cons? ls) ...]))

;; a Listof[Shot] (LOS) is either
;; empty or
;; (cons shot LOS)
(define LOS1 (list shot1 shot2 shot3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;world defintion

;; A SpyGame is a
;; (make-splash Image) or
;; (make-shg Nat Nat Nat Nat spy List-of[Object Lis-of[Shot] Num]) or
;; (make-gameover Nat)

(define-struct splash [bg])
;; where bg is an image set as the splashscreen

(define-struct shg [lives score spy objects shots dtop])
;; where lives is the number of lives a player has left,
;; score is the player's score,
;; objects is a list of all the objects in the game, and
;; shots is the list of bullets fired by spy
;; and dtop is the y coordinate of the top of the background
;;     the top of the screen is at y=0
;; example shg
(define shg1 (make-shg 3 0 spy1 empty empty -10))
(define shg2 (make-shg 2 45 spy2 LOO1 LOS1 -20))
(define shg3 (make-shg 1 10 spy1 empty empty -1))
(define shg4 (make-shg 0 293 spy1 empty empty 900))
(define shg5 (make-shg 2 45 spy2 LOO1 LOS1 0))
(define shg6 (make-shg 1 95 spy2 empty empty 803))

(define-struct gameover [score])
;; where score is the score the player had when they died

;; fun-for-shg: shg --> ?
#; (define (fun-for-shg s)
     (... (shg-lives s) ...
          (shg-score s) ...
          (shg-spy s) ...
          (shg-objects s) ...
          (shg-shots s) ...
          (shg-dtop s) ...))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                                                        
;                                                                        
;     ;;;         ;;;    ;;;       ;             ;                       
;    ;   ;          ;      ;                                             
;   ;       ;;;     ;      ;     ;;;    ;;;    ;;;    ;;;   ; ;;    ;;;  
;   ;      ;; ;;    ;      ;       ;   ;   ;     ;   ;; ;;  ;;  ;  ;   ; 
;   ;      ;   ;    ;      ;       ;   ;         ;   ;   ;  ;   ;  ;     
;   ;      ;   ;    ;      ;       ;    ;;;      ;   ;   ;  ;   ;   ;;;  
;   ;      ;   ;    ;      ;       ;       ;     ;   ;   ;  ;   ;      ; 
;    ;   ; ;; ;;    ;      ;       ;   ;   ;     ;   ;; ;;  ;   ;  ;   ; 
;     ;;;   ;;;      ;;     ;;   ;;;;;  ;;;    ;;;;;  ;;;   ;   ;   ;;;  
;                                                                        
;                                                                        
;                                                                        

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#|

;;Wishlist

-- key handler    ;;; DONE!
   - shoot
   - deploy oilslick
   - deploy smokescreen
   - move left
   - move right
   - go forward
   - accelerate

-- draw handler   ;;; DONE!

-- tick handler
   - AI
   - place friendly cars offscreen ;;;DONE!
   - place enemy cars offscreen    ;;;DONE!
   - place helpertrucks offscreen  ;;;DONE!
   - move these things             ;;;DONE!
      - friendly cars
      - ss
      - BG
   - collisions
      - LTRBs                      ;;;DONE!
          - generate-ltrb
          - inside?
          - overlapping?
      - is an enemy hit by shot?
      - is an enemy or a spy off the road?
      - is the spy inside a truck?
      - is an enemy or spy touching?
      - is an enemy touching an os
      - is an enemy touching a ss

-- endgame?       ;;;DONE!

|#

;; endgame?: SpyGame --> Boolean
;; determines if the game should end
;; the game ends when lives < 0

;; checks for shg
(check-expect (endgame? shg1) false)

;; checks for splash (splash should always result false)
(check-expect (endgame? (make-splash spy-car)) ;; just chose a random image
              false)
(check-expect (endgame? (make-shg 0 5003 spy1 empty empty -20)) false)
(check-expect (endgame? (make-shg 2 563 spy1 empty LOS1 0)) false)
(check-expect (endgame? (make-shg -1 5003 spy1 '((make-os 400 400)
                                                 (make-os 420 380)
                                                 (make-FrendlyCar 200 600 40))
                                  empty -1)) true)

;; checks for gamover (gameover should always result false)
(check-expect (endgame? (make-gameover 100)) false)

(define (endgame? sg)
  (cond [(splash? sg) false]
        [(gameover? sg) false]
        [(shg? sg)
         (< (shg-lives sg) 0)]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Render Handler

;; render: SpyGame --> Image
;; renders all visual components of a SpyGame into an image
;check-expects for splash
(check-expect (render (make-splash splash-image)) splash-image)
(check-expect (render (make-splash spy-car)) splash-image)
; check-expects for gameover
(check-expect (render (make-gameover 0))
              (overlay (above (text "Spy Hunter" 36 'red)
                              (text "GAME OVER" 48 'red)
                              (text  "0" 48 'green))
                       plain-bg))
(check-expect (render (make-gameover 3))
              (overlay (above (text "Spy Hunter" 36 'red)
                              (text "GAME OVER" 48 'red)
                              (text  "3" 48 'green))
                       plain-bg))
(check-expect (render (make-gameover 211))
              (overlay (above (text "Spy Hunter" 36 'red)
                              (text "GAME OVER" 48 'red)
                              (text  "211" 48 'green))
                       plain-bg))
(check-expect (render (make-gameover 2000874))
              (overlay (above (text "Spy Hunter" 36 'red)
                              (text "GAME OVER" 48 'red)
                              (text  "2000874" 48 'green))
                       plain-bg))
; check-expects for shg
(check-expect (render shg1)
              (draw-score shg1
                          (draw-lives shg1
                                      (draw-spy
                                       (shg-spy shg1)
                                       (draw-os
                                        (shg-spy shg1)
                                        (draw-ss
                                         (shg-spy shg1)
                                         (draw-bg shg1)))))))
(check-expect (render shg5) 
              (draw-score shg5
                          (draw-lives shg5
                                      (draw-LOO
                                       (shg-objects shg5)
                                       (draw-spy
                                        (shg-spy shg5)
                                        (draw-os
                                         (shg-spy shg5)
                                         (draw-ss
                                          (shg-spy shg5)
                                          (draw-shot
                                           (shg-shots shg5)
                                           (draw-bg shg5)))))))))
(define (render sg)
  (cond [(splash? sg) splash-image]
        [(shg? sg) (draw-score sg
                               (draw-lives sg
                                           (draw-LOO
                                            (shg-objects sg)
                                            (draw-spy
                                             (shg-spy sg)
                                             (draw-os
                                              (shg-spy sg)
                                              (draw-ss
                                               (shg-spy sg)
                                               (draw-shot
                                                (shg-shots sg)
                                                (draw-bg sg))))))))]
        [(gameover? sg) (overlay (above (text "Spy Hunter" 36 'red)
                                        (text "GAME OVER" 48 'red)
                                        (text (number->string
                                               (gameover-score sg)) 48 'green))
                                 plain-bg)]))

;; draw-bg: shg --> Image
;; draws the bg with proper dimensions using the BG
(check-expect (draw-bg shg1) (above (crop 0 (- (image-height BG) 10) W 10
                                          BG)
                                    (crop 0 0 W (- H 10) BG)))
(check-expect (draw-bg shg4) (crop 0 900 W H BG))
(check-expect (draw-bg shg5) (crop 0 0 W H BG))
;helper function wrap: shg --> Num+
; finds the y value where you want the screen to start from
; the dtop parameter of an shg
(define (wrap-y sg) (remainder (+ (image-height BG) (shg-dtop sg))
                               (image-height BG)))
(define (draw-bg sg)
  (if (> (+ (wrap-y sg) H)
         (image-height BG))
      (above (crop 0 (wrap-y sg) W (- (image-height BG) (wrap-y sg)) BG)
             (crop 0 0 W (- H (- (image-height BG) (wrap-y sg))) BG))
      (crop 0 (shg-dtop sg) W H BG)))
;; draw-score: shg Image --> Image
;; draws the player's score in top right
(check-expect (draw-score shg1 plain-bg)
              (place-image (text "0" 30 'white)
                           (* 7/8 W) 25
                           plain-bg))

(define (draw-score sg bg)
  (place-image (text (number->string (shg-score sg)) 30 'white)
               (* 7/8 W) 25
               bg))

;; draw-livesleft: shg --> Image
;; draws a small car for each life the player has left
(define mini-car-spacer (rectangle (* 1/60 W) 0 'solid 'beige))
(check-expect (draw-livesleft shg1) (beside mini-car mini-car-spacer
                                            mini-car mini-car-spacer
                                            mini-car mini-car-spacer
                                            (empty-scene 0 0)))
(check-expect (draw-livesleft shg2) (beside mini-car mini-car-spacer
                                            mini-car mini-car-spacer
                                            (empty-scene 0 0)))
(check-expect (draw-livesleft shg3) (beside mini-car mini-car-spacer
                                            (empty-scene 0 0)))
(check-expect (draw-livesleft shg4) (empty-scene 0 0))


(define (draw-livesleft sg)
  (cond [(= 0 (shg-lives sg)) (empty-scene 0 0)]
        [else (beside mini-car
                      mini-car-spacer
                      (draw-livesleft (make-shg (- (shg-lives sg) 1)
                                                (shg-score sg)
                                                (shg-spy sg)
                                                (shg-objects sg)
                                                (shg-shots sg)
                                                (shg-dtop sg))))]))
;; draw-lives shg Image --> Image
;; draws the livesleft image onto the bg
(check-expect (draw-lives shg1 splash-image)
              (place-image (draw-livesleft shg1)
                           (* 1/8 W) 25 splash-image))
(check-expect (draw-lives shg4 splash-image)
              (place-image (empty-scene 0 0) (* 1/8 W) 25 splash-image))

(define (draw-lives sg bg)
  (place-image (draw-livesleft sg) (* 1/8 W) 25 bg))

;; draw-spy: Spy Image --> Image
;; draws the spy as well as
(define (draw-spy s bg)
  (place-image spy-car (spy-x s) (spy-y s) bg))

;; draw-os: Spy Image --> Image
;; draws an oilslick icon if the number of oilslicks left is > 0 and
(define (draw-os s bg)
  (if (> (spy-osleft s) 0)
      (place-image os-image (* 9/10 W) (* 7/8 H) bg)
      bg))

;; draw-ss: Spy Image --> Image
;; draws a smokescreen icon if the number of smokescreens left is > 0
(define (draw-ss s bg)
  (if (> (spy-ssleft s) 0)
      (place-image mini-ss-image (* 9/10 W) (- (* 7/8 H) 80) bg)
      bg))

;; draw-object: Object Image --> Image
;; draws the given object onto the given image
(define (draw-object o bg)
  (cond [(FriendlyCar? o) (place-image frnd
                                       (FriendlyCar-x o)
                                       (FriendlyCar-y o)
                                       bg)]
        [(small-enemy? o ) (place-image sml-enemy
                                        (small-enemy-x o)
                                        (small-enemy-y o)
                                        bg)]
        [(large-enemy? o ) (place-image lrg-enemy
                                        (large-enemy-x o)
                                        (large-enemy-y o)
                                        bg)]
        [(hlpr-truck? o) (place-image truck
                                      (hlpr-truck-x o)
                                      (hlpr-truck-y o)
                                      bg)]
        [(os? o) (place-image os-image
                              (os-x o)
                              (os-y o)
                              bg)]
        [(ss? o) (place-image ss-image
                              (ss-x o)
                              (ss-y o)
                              bg)]))
;; draw-LOO: LOO Image --> Image
;; draws all of the objects contained in the SpyGame's LOO
(check-expect (draw-LOO empty plain-bg) plain-bg)
(check-expect (draw-LOO LOO1 plain-bg)
              (place-image os-image 300 400
                           (place-image ss-image 200 500
                                        (place-image sml-enemy
                                                     300 790
                                                     (place-image lrg-enemy 300
                                                                  200
                                                                  (place-image
                                                                   truck 200
                                                                   150
                                                                   (place-image
                                                                    frnd 400 
                                                                    150
                                                                    plain-bg)))
                                                     ))))
(define (draw-LOO ls bg)
  (cond [(empty? ls) bg]
        [(cons? ls) (draw-LOO (rest ls) (draw-object (first ls) bg))]))

;; draw-shot: LOS Image --> Image
;; draws the shot contained in the SpyGame's LOS
(check-expect (draw-shot LOS1 plain-bg)
              (place-image player-shot 150 380
                           (place-image player-shot 150 360
                                        (place-image player-shot 150 340 
                                                     plain-bg))))
(define (draw-shot ls bg)
  (cond [(empty? ls) bg]
        [(cons? ls) (draw-shot (rest ls)
                               (place-image player-shot
                                            (shot-x (first ls))
                                            (shot-y (first ls))
                                            bg))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Key Handler

;; a KeyEvent is one of
;; "w" accelerates spy
;; "s" deccelerates spy
;; "a" moves the spy left
;; "d" moves the spy right
;; "e" deploys an oilslick to the road
;; "q" deploys a smokescreen behind spy
;; " " fires shot from spy
;; or any other key which switches
; splash --> gameover
; gameover --> splash or
; does nothing if SpyGame is an shg

;; handle-key: key SpyGame --> SpyGame
;; performs a key's proper function to produce the next SpyGame
(check-expect (handle-key "w" (make-splash splash-image))
              shg1)
(check-expect (handle-key "s" (make-splash splash-image))
              shg1)
(check-expect (handle-key "d" (make-splash splash-image))
              shg1)
(check-expect (handle-key "a" (make-splash splash-image))
              shg1)
(check-expect (handle-key "o" (make-splash splash-image))
              shg1)
(check-expect (handle-key "w" (make-gameover 100))
              (make-splash splash-image))
(check-expect (handle-key "s" (make-gameover 100))
              (make-splash splash-image))
(check-expect (handle-key "d" (make-gameover 100))
              (make-splash splash-image))
(check-expect (handle-key "a" (make-gameover 100))
              (make-splash splash-image))
(check-expect (handle-key "i" (make-gameover 100))
              (make-splash splash-image))
(check-expect (handle-key "w" shg1)
              (make-shg 3 0 (make-spy 300 400 10 0 0) empty empty -10))
(check-expect (handle-key "s" shg2)
              (make-shg 2 45 (make-spy 200 400 1 2 3) LOO1 LOS1 -20))
(check-expect (handle-key "a" shg1)
              (make-shg 3 0 (make-spy 290 400 0 0 0) empty empty -10))
(check-expect (handle-key "d" shg2)
              (make-shg 2 45 (make-spy 210 400 11 2 3) LOO1 LOS1 -20))
(check-expect (handle-key "e" shg1)
              (make-shg 3 0 (make-spy 300 400 0 0 0) empty empty -10))
(check-expect (handle-key "e" shg2)
              (make-shg 2 45 (make-spy 200 400 11 1 3)
                        (cons (make-os 200 400) LOO1) LOS1 -20))
(check-expect (handle-key "q" shg1)
              (make-shg 3 0 (make-spy 300 400 0 0 0) empty empty -10))
(check-expect (handle-key "q" shg2)
              (make-shg 2 45 (make-spy 200 400 11 2 2)
                        (cons (make-ss 200 (+ 400 (/ (image-height spy-car) 2))
                                       MAX-SSD) LOO1) LOS1 -20))
(check-expect (handle-key " " shg1)
              (make-shg 3 0 (make-spy 300 400 0 0 0) empty
                        (cons (make-shot 300 (- 400
                                                (/ (image-height spy-car) 2)
                                                )) empty) -10))
(check-expect (handle-key "p" shg1)
              shg1)
(check-expect (handle-key "h" shg1)
              shg1)
(define (handle-key k sg)
  (cond [(splash? sg) shg1] ;; on any-key it makes the starting shg
        [(gameover? sg) (make-splash splash-image)] ;;on any-key goes to splash
        [(shg? sg)
         (cond [(key=? "w" k) (make-shg (shg-lives sg)
                                        (shg-score sg)
                                        (make-spy (spy-x (shg-spy sg))  
                                                  (spy-y (shg-spy sg))
                                                  (accelerate
                                                   (spy-vel (shg-spy sg)))
                                                  (spy-osleft (shg-spy sg))
                                                  (spy-ssleft (shg-spy sg)))
                                        (shg-objects sg)
                                        (shg-shots sg)
                                        (shg-dtop sg))]
               [(key=? "s" k) (make-shg (shg-lives sg)
                                        (shg-score sg)
                                        (make-spy (spy-x (shg-spy sg))  
                                                  (spy-y (shg-spy sg))
                                                  (decelerate
                                                   (spy-vel (shg-spy sg)))
                                                  (spy-osleft (shg-spy sg))
                                                  (spy-ssleft (shg-spy sg)))
                                        (shg-objects sg)
                                        (shg-shots sg)
                                        (shg-dtop sg))]
               [(key=? "a" k) (make-shg (shg-lives sg)
                                        (shg-score sg)
                                        (make-spy (- (spy-x (shg-spy sg))
                                                     10)
                                                  (spy-y (shg-spy sg))
                                                  (spy-vel (shg-spy sg))
                                                  (spy-osleft (shg-spy sg))
                                                  (spy-ssleft (shg-spy sg)))
                                        (shg-objects sg)
                                        (shg-shots sg)
                                        (shg-dtop sg))]
               [(key=? "d" k) (make-shg (shg-lives sg)
                                        (shg-score sg)
                                        (make-spy (+ (spy-x (shg-spy sg))
                                                     10)
                                                  (spy-y (shg-spy sg))
                                                  (spy-vel (shg-spy sg))
                                                  (spy-osleft (shg-spy sg))
                                                  (spy-ssleft (shg-spy sg)))
                                        (shg-objects sg)
                                        (shg-shots sg)
                                        (shg-dtop sg))]
               [(key=? "e" k) (add-os sg (shg-spy sg))]
               [(key=? "q" k) (add-ss sg (shg-spy sg))]
               [(key=? " " k) (make-shg (shg-lives sg)
                                        (shg-score sg)
                                        (make-spy (spy-x (shg-spy sg))  
                                                  (spy-y (shg-spy sg))
                                                  (spy-vel (shg-spy sg))
                                                  (spy-osleft (shg-spy sg))
                                                  (spy-ssleft (shg-spy sg)))
                                        (shg-objects sg)
                                        (cons (make-shot (spy-x (shg-spy sg))
                                                         (- (spy-y (shg-spy sg))
                                                            (/ (image-height
                                                                spy-car) 2)))
                                              (shg-shots sg))
                                        (shg-dtop sg))]
               [else sg])]))

;; accelerate: Nat --> Nat
;; increases Nat by 10 unless it is >= (START-VEL + 20)
(define (accelerate s)
  (if (>= s (+ START-VEL 20))
      s
      (+ s 10)))

;; decelerate: Nat --> Nat
;; decreases Nat by 10 unless it is < (START-VEL - 20)
(define (decelerate s)
  (if (<= s (- START-VEL 20))
      s
      (- s 10)))

;; add-os: shg spy --> shg
;; adds an oilslick to the beginning of the shg's loo and subs 1 from osleft
;; if the car has no oilslicks left add-os does nothing
;; the oilsick as the same coordinates as the spy
(define (add-os sg s)
  (if (> (spy-osleft s) 0)
      (make-shg (shg-lives sg)
                (shg-score sg)
                (make-spy (spy-x s) (spy-y s) (spy-vel s) (- (spy-osleft s) 1)
                          (spy-ssleft s))
                (cons (make-os (spy-x s) (spy-y s)) (shg-objects sg))
                (shg-shots sg) (shg-dtop sg))
      sg))

;; addss: shg spy --> shg
;; adds a smokescreen to the beginning of the shg's loo and subs 1 from ssleft
;; if the car has no smokescreens left add-ss does nothing
(define (add-ss sg s)
  (if (> (spy-ssleft s) 0)
      (make-shg (shg-lives sg)
                (shg-score sg)
                (make-spy (spy-x s) (spy-y s) (spy-vel s) (spy-osleft s)
                          (- (spy-ssleft s) 1))
                (cons (make-ss (spy-x s) (+ (spy-y s)
                                            (/ (image-height spy-car) 2))
                               MAX-SSD) (shg-objects sg))
                (shg-shots sg) (shg-dtop sg))
      sg))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tick Handler
;                                     
;                        ;            
;  ;;;;;;;    ;          ;        ;   
;     ;                  ;        ;   
;     ;     ;;;    ;;;   ;  ;     ;   
;     ;       ;   ;;  ;  ;  ;     ;   
;     ;       ;   ;      ; ;      ;   
;     ;       ;   ;      ;;;      ;   
;     ;       ;   ;      ; ;          
;     ;       ;   ;;     ;  ;         
;     ;     ;;;;;  ;;;;  ;   ;    ;;  
;                                     
;                                     
;                                     

;; handle-tick: SpyGame --> Spygame
#;(define (handle-tick sg)
    (cond [(splash? sg) sg]
          [(gameover? sg) sg]
          [(shg? sg)
           ...]))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; removal code

;; offroad?: any car or truck --> Boolean
;; determines if a car is off of the road. Any car is off the road if
;; its x coordinate > 5/6 * W or x < 1/6 * W
(define (offroad? o)
  (cond [(FriendlyCar? o) (or (< (FriendlyCar-x o) (* 1/6 W))
                              (> (FriendlyCar-x o) (* 5/6 W)))]
        [(small-enemy? o) (or (< (small-enemy-x o) (* 1/6 W))
                              (> (small-enemy-x o) (* 5/6 W)))]
        [(large-enemy? o) (or (< (large-enemy-x o) (* 1/6 W))
                              (> (large-enemy-x o) (* 5/6 W)))]
        [(spy? o) (or (< (spy-x o) (* 1/6 W))
                      (> (spy-x o) (* 5/6 W)))]
        [(hlpr-truck? o) (or (< (hlpr-truck-x o) (* 1/6 W))
                             (> (hlpr-truck-x o) (* 5/6 W)))]))

;; sml-enemy-hit?: small-enemy LOS --> Boolean
;; determines if the sml-enemy was struck by any bullet in LOS
(check-expect (sml-enemy-hit? (make-small-enemy 1 2 3 4) empty) false)
(check-expect (sml-enemy-hit? (make-small-enemy 1 2 3 10)
                              LOS1)
              false)
(check-expect (sml-enemy-hit? (make-small-enemy 40 20 5 10)
                              (list (make-shot 30 25)))
              true)
(check-expect (sml-enemy-hit? (make-small-enemy 40 20 5 0)
                              (list (make-shot 40 45)
                                    (make-shot 20 10)
                                    (make-shot 40 20)))
              true)
(define (sml-enemy-hit? se ls)
  (cond [(empty? ls) false]
        [(cons? ls)
         (or (overlapping?
              (compute-ltrb (small-enemy-x se) (small-enemy-y se) sml-enemy)
              (compute-ltrb (shot-x (first ls)) (shot-y (first ls)) player-shot)
              )
             (sml-enemy-hit? se (rest ls)))]))

;; remove-sml-enemies: LOO LOS --> LOO
;; removes all small enemies that have been hit by shot from a list of objects
(check-expect (remove-sml-enemies LOO1 LOS1) LOO1)
(check-expect (remove-sml-enemies LOO1 (list (make-shot 300 700)
                                             (make-shot 308 800)))
              (list (make-os 300 400)
                    (make-ss 200 500 1)
                    (make-large-enemy 300 200 2 0)
                    (make-hlpr-truck 200 150 'os 3)
                    (make-FriendlyCar 400 150 5)))

(define (remove-sml-enemies lso lss)
  (cond [(empty? lso) empty]
        [(cons? lso)
         (if (and (small-enemy? (first lso))
                  (or (offroad? (first lso)) (sml-enemy-hit? (first lso) lss)))
             (remove-sml-enemies (rest lso) lss)
             (cons (first lso) (remove-sml-enemies (rest lso) lss)))]))

;; lrg-enemy-hit?: large-enemy LOS --> Boolean
;; determines if the large enemy was struck by any bullet in LOS
(check-expect (lrg-enemy-hit? (make-large-enemy 1 2 3 0) empty) false)
(check-expect (lrg-enemy-hit? (make-large-enemy 1 2 3 10)
                              LOS1)
              false)
(check-expect (lrg-enemy-hit? (make-large-enemy 40 20 5 4)
                              (list (make-shot 30 25)))
              true)
(check-expect (lrg-enemy-hit? (make-large-enemy 40 20 5 7)
                              (list (make-shot 40 45)
                                    (make-shot 20 10)
                                    (make-shot 40 20)))
              true)
(define (lrg-enemy-hit? le ls)
  (cond [(empty? ls) false]
        [(cons? ls)
         (or (overlapping?
              (compute-ltrb (large-enemy-x le) (large-enemy-y le) lrg-enemy)
              (compute-ltrb (shot-x (first ls)) (shot-y (first ls)) player-shot)
              )
             (lrg-enemy-hit? le (rest ls)))]))

;; remove-lrg-enemies: LOO LOS --> LOO
;; removes all large enemies that have been hit by shot or are offroad
;; from a list of objects
(check-expect (remove-lrg-enemies LOO1 LOS1) LOO1)
(check-expect (remove-lrg-enemies LOO1 (list (make-shot 300 700)
                                             (make-shot 285 225)
                                             (make-shot 308 800)))
              (list (make-os 300 400)
                    (make-ss 200 500 1)
                    (make-small-enemy 300 790 2 0)
                    (make-hlpr-truck 200 150 'os 3)
                    (make-FriendlyCar 400 150 5)))

(define (remove-lrg-enemies lso lss)
  (cond [(empty? lso) empty]
        [(cons? lso)
         (if (and (large-enemy? (first lso))
                  (or (offroad? (first lso))
                      (lrg-enemy-hit? (first lso) lss)))
             (remove-lrg-enemies (rest lso) lss)
             (cons (first lso) (remove-lrg-enemies (rest lso) lss)))]))
;; remove-enemies: shg --> shg
;; removes the enemies from the LOO in the shg
(define (remove-eneies sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (remove-lrg-enemies (remove-sml-enemies (shg-objects sg)
                                                    (shg-shots sg))
                                (shg-shots sg))
            (shg-shots sg)
            (shg-dtop sg)))


;; remove?: spy object --> Boolean
;; determines if an object should be removed from the game
;; objects should be removed in these situations
;  - cars: have gone offscreen by 200 pixels in either direction
;  - oilslick: has gone fully offscreen (* 1/2 (image-height os-image))
;  - smokescreen: runs out of time
(define (remove? s o)
  (cond [(FriendlyCar? o) (or (<= (FriendlyCar-y o) (- (spy-y s) (* 1/2 H) 200))
                              (>= (FriendlyCar-y o) (+ (spy-y s) (* 1/2 H) 200))
                              )]
        [(small-enemy? o) (or (<= (small-enemy-y o) (- (spy-y s) (* 1/2 H) 200))
                              (>= (small-enemy-y o) (+ (spy-y s) (* 1/2 H) 200))
                              )]
        [(large-enemy? o) (or (<= (large-enemy-y o) (- (spy-y s) (* 1/2 H) 200))
                              (>= (large-enemy-y o) (+ (spy-y s) (* 1/2 H) 200))
                              )]
        [(hlpr-truck? o) (or (<= (hlpr-truck-y o) (- (spy-y s) (* 1/2 H) 200))
                             (>= (hlpr-truck-y o) (+ (spy-y s) (* 1/2 H) 200))
                             )]
        [(os? o) (>= (os-y o) (+ (spy-y s) (* 1/2 H) (* 1/2 (image-height
                                                             os-image))))]
        [(ss? o) (= 0 (ss-duration o))]))

;; remove-objects: spy LOO --> LOO
;; removes all offscreen objects in LOO that are not approaching spy
;; (from front or back)
(define (remove-objects s ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (if (remove? s (first ls))
                        (remove-objects s (rest ls))
                        (cons (first ls) (remove-objects s (rest ls))))]))

;; remove-offscreen: shg --> shg
;; removes objects from shg according to preivous parameters
(check-expect (remove-offscreen shg1)
              shg1)
(check-expect (remove-offscreen shg2)
              shg2)
(check-expect (remove-offscreen (make-shg 2 3 spy2
                                          (cons (make-FriendlyCar 300 1000 3)
                                                LOO1)
                                          empty
                                          4))
              (make-shg 2 3 spy2 LOO1 empty 4))
(check-expect (remove-offscreen (make-shg 1 44 (make-spy 344 700 1 2 2)
                                          (list (make-hlpr-truck 212 1354 'os 4)
                                                (make-FriendlyCar 245 1299 4)
                                                (make-small-enemy 5 100 2 0)
                                                (make-os 4 1300))
                                          empty 3))
              (make-shg 1 44 (make-spy 344 700 1 2 2)
                        (list (make-FriendlyCar 245 1299 4)) empty 3))

(define (remove-offscreen sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (remove-objects (shg-spy sg) (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; inside-truck?: Spy hlpr-truck --> Boolean
;; determines if the spy is inside truck
(check-expect (inside-truck? (make-spy 10 10 3 4 5)
                             (make-hlpr-truck 10 10 'os 3))
              true)
(check-expect (inside-truck? (make-spy 15 10 3 4 5)
                             (make-hlpr-truck 10 10 'os 4))
              false)
(define (inside-truck? s h)
  (inside? (compute-ltrb (spy-x s) (spy-y s) spy-car)
           (compute-ltrb (hlpr-truck-x h) (hlpr-truck-y h) truck)))

;; add-power: spy hlpr-truck --> spy
;; if the spy is inside the hlpr-truck, it adds the trucks powers to spy
(check-expect (add-power (make-spy 15 10 3 4 5)
                         (make-hlpr-truck 10 10 'os 4))
              (make-spy 15 10 3 4 5))
(check-expect (add-power (make-spy 10 10 3 4 5)
                         (make-hlpr-truck 10 10 'os 3))
              (make-spy 10 10 3 14 5))
(check-expect (add-power (make-spy 10 10 3 4 5)
                         (make-hlpr-truck 10 10 'ss 3))
              (make-spy 10 10 3 4 10))
(define (add-power s h)                 ;; kinda worried about all the if expr.
  (if (inside-truck? s h)
      (if (symbol=? (hlpr-truck-gadget h) 'os)
          (make-spy (spy-x s) (spy-y s) (spy-vel s) (+ (spy-osleft s) 10)
                    (spy-ssleft s))
          (make-spy (spy-x s) (spy-y s) (spy-vel s) (spy-osleft s)
                    (+ (spy-ssleft s) 5)))
      s))
;;handle-spy: shg --> shg
(check-expect (handle-spy (make-shg 1 342 (make-spy 10 10 3 4 5)
                                    (list (make-os 150 344)
                                          (make-FriendlyCar 1 2 45)
                                          (make-hlpr-truck 10 10 'os 5)
                                          (make-small-enemy 356 321 20 0))
                                    empty 10))
              (make-shg 1 342 (make-spy 10 7 3 14 5)
                        (list (make-os 150 344)
                              (make-FriendlyCar 1 2 45)
                              (make-hlpr-truck 10 10 'os 5)
                              (make-small-enemy 356 321 20 0))
                        empty 10))
(check-expect (handle-spy (make-shg 1 342 (make-spy 10 10 3 4 5)
                                    (list (make-os 150 344)
                                          (make-FriendlyCar 1 2 45)
                                          (make-small-enemy 356 321 20 0))
                                    empty 10))
              (make-shg 1 342 (make-spy 10 7 3 4 5)
                        (list (make-os 150 344)
                              (make-FriendlyCar 1 2 45)
                              (make-small-enemy 356 321 20 0))
                        empty 10))
(define (handle-spy sg)
  (move-spy (make-shg (shg-lives sg)
                      (shg-score sg)
                      (if (empty? (filter hlpr-truck? (shg-objects sg)))
                          (shg-spy sg)
                          (add-power (shg-spy sg) (first
                                                   (filter hlpr-truck?
                                                           (shg-objects sg)))))
                      (shg-objects sg)
                      (shg-shots sg)
                      (shg-dtop sg))))

;; move-spy: shg --> shg
;; moves the spy up according to its velocity
(check-expect (move-spy shg1)
              shg1) ;; spy velocity is 0 so nothing changes
(check-expect (move-spy shg2)
              (make-shg 2 45 (make-spy 200 389 11 2 3) LOO1 LOS1 -20))
(check-expect (move-spy shg6)
              (make-shg 1 95 (make-spy 200 389 11 2 3) empty empty 803))
(define (move-spy sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (make-spy (spy-x (shg-spy sg))
                      (- (spy-y (shg-spy sg)) (spy-vel (shg-spy sg)))
                      (spy-vel (shg-spy sg))
                      (spy-osleft (shg-spy sg))
                      (spy-ssleft (shg-spy sg)))
            (shg-objects sg)
            (shg-shots sg)
            (shg-dtop sg)))

;; move-window: shg --> shg
;; moves the screen's window up according to the spy's velocity
(check-expect (move-window shg1)
              (make-shg 3 0 spy1 empty empty -10)) ;; spy velocity is 0
(check-expect (move-window shg2)
              (make-shg 2 45 spy2 LOO1 LOS1 -31))
(check-expect (move-window shg6)
              (make-shg 1 95 spy2 empty empty 792))
(define (move-window sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (shg-objects sg)
            (shg-shots sg)
            (- (shg-dtop sg) (spy-vel (shg-spy sg)))))

;; move-frnd: FriendlyCar --> FriendlyCar
;; moves a single FrienclyCar according to its velocity
(define (move-frnd f) ;; a helper used in move-frndinobjects
  (cond [(FriendlyCar? f)
         (make-FriendlyCar (FriendlyCar-x f)
                           (- (FriendlyCar-y f) (FriendlyCar-vel f))
                           (FriendlyCar-vel f))]
        [else f]))

;; move-frndinobjects: LOO --> LOO
;; makes the same LOO, but with all friendly cars moved
;; helper used in move-passives
(check-expect (move-frndinobjects empty) empty)
(check-expect (move-frndinobjects (cons (make-FriendlyCar 150 200 3) empty))
              (cons (make-FriendlyCar 150 197 3) empty))
(check-expect (move-frndinobjects (list (make-os 134 592)
                                        (make-os 140 32)
                                        (make-small-enemy 13 5 23 0)
                                        (make-hlpr-truck 22 44 'os 4)))
              (list (make-os 134 592)
                    (make-os 140 32)
                    (make-small-enemy 13 5 23 0)
                    (make-hlpr-truck 22 44 'os 4)))
(check-expect (move-frndinobjects LOO1)
              (list (make-os 300 400)
                    (make-ss 200 500 1)
                    (make-small-enemy 300 790 2 0)
                    (make-large-enemy 300 200 2 0)
                    (make-hlpr-truck 200 150 'os 3)
                    (make-FriendlyCar 400 145 5)))
(check-expect (move-frndinobjects (cons (make-FriendlyCar 145 6 2) LOO1))
              (list (make-FriendlyCar 145 4 2)
                    (make-os 300 400)
                    (make-ss 200 500 1)
                    (make-small-enemy 300 790 2 0)
                    (make-large-enemy 300 200 2 0)
                    (make-hlpr-truck 200 150 'os 3)
                    (make-FriendlyCar 400 145 5)))
(check-expect (move-frndinobjects (list (make-FriendlyCar 145 6 2)
                                        (make-FriendlyCar 15 86 35)
                                        (make-FriendlyCar 45 656 4)))
              (list (make-FriendlyCar 145 4 2)
                    (make-FriendlyCar 15 51 35)
                    (make-FriendlyCar 45 652 4)))
(check-expect (move-frndinobjects (list (make-FriendlyCar 145 6 2)
                                        (make-hlpr-truck 200 150 'os 3)
                                        (make-large-enemy 300 200 2 0)
                                        (make-FriendlyCar 15 86 35)
                                        (make-FriendlyCar 45 656 4)))
              (list (make-FriendlyCar 145 4 2)
                    (make-hlpr-truck 200 150 'os 3)
                    (make-large-enemy 300 200 2 0)
                    (make-FriendlyCar 15 51 35)
                    (make-FriendlyCar 45 652 4)))
(define (move-frndinobjects ls)
  (cond [(empty? ls) empty]
        [(cons? ls)
         (cons (move-frnd (first ls)) (move-frndinobjects (rest ls)))]))

;; move-passives: shg --> shg
;; moves all of the friendly cars in shg's LOP
(check-expect (move-passives shg1)
              shg1)
(check-expect (move-passives shg2)
              (make-shg 2 45 spy2
                        (list (make-os 300 400)
                              (make-ss 200 500 1)
                              (make-small-enemy 300 790 2 0)
                              (make-large-enemy 300 200 2 0)
                              (make-hlpr-truck 200 150 'os 3)
                              (make-FriendlyCar 400 145 5))
                        LOS1
                        -20))
(check-expect (move-passives (make-shg 1 20 spy1
                                       (list (make-os 134 592)
                                             (make-os 140 32)
                                             (make-small-enemy 13 5 23 0)
                                             (make-hlpr-truck 22 44 'os 4))
                                       empty
                                       2))
              (make-shg 1 20 spy1 (list (make-os 134 592)
                                        (make-os 140 32)
                                        (make-small-enemy 13 5 23 0)
                                        (make-hlpr-truck 22 44 'os 4))
                        empty
                        2))
(check-expect (move-passives (make-shg 3 544 spy2
                                       (list (make-FriendlyCar 145 6 2)
                                             (make-FriendlyCar 15 86 35)
                                             (make-FriendlyCar 45 656 4))
                                       LOS1
                                       45))
              (make-shg 3 544 spy2
                        (list (make-FriendlyCar 145 4 2)
                              (make-FriendlyCar 15 51 35)
                              (make-FriendlyCar 45 652 4))
                        LOS1
                        45))
(define (move-passives sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (move-frndinobjects (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))

;; move-singless spy object --> ss
;; moves a ss to the back of the spy
(define (move-singless sp o)
  (if (ss? o)(make-ss (spy-x sp)
                      (+ (spy-y sp)
                         (* 1/2 (image-height spy-car))
                         (* 1/2 (image-height ss-image)))
                      (ss-duration o))
      o))
;; move-ssinobjects: spy LOO --> LOO
;; produces the same list, but with the smokescreens moved
(define (move-ssinobjects s ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (cons (move-singless s (first ls))
                          (move-ssinobjects s (rest ls)))]))
;; move-ss: shg --> shg
;; keeps the smokescreens in objects at the back of spy while spy moves
(check-expect (move-ss shg1)
              shg1)
(check-expect (move-ss shg2)
              (make-shg 2 45 spy2 (list (make-os 300 400)
                                        (make-ss 200 (+ 400
                                                        (* 1/2
                                                           (image-height
                                                            spy-car))
                                                        (* 1/2
                                                           (image-height
                                                            ss-image)))
                                                 1)
                                        (make-small-enemy 300 790 2 0)
                                        (make-large-enemy 300 200 2 0)
                                        (make-hlpr-truck 200 150 'os 3)
                                        (make-FriendlyCar 400 150 5))
                        LOS1 -20))
(define (move-ss sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (move-ssinobjects (shg-spy sg) (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))

;; move-shot: shot --> shot
;; moves a single shot according to its velocity
(define (move-shot s)
  (make-shot (shot-x s) (- (shot-y s) SHOT-VEL)))

;; move-shots: LOS --> LOS
;; moves all shot is a list of shot
(check-expect (move-shots LOS1)
              (list (make-shot 150 330)
                    (make-shot 150 310)
                    (make-shot 150 290)))
(define (move-shots ls)
  (cond [(empty? ls) empty]
        [(cons? ls)
         (cons (move-shot (first ls)) (move-shots (rest ls)))]))

;; remove-shot?: spy shot --> Boolean
;; produces true if the shot is 200 or more pixels ahead of spy, otherwise false
(define (remove-shot? sp sh)
  (<= (shot-y sh) (- (spy-y sp) 200)))

;; remove-shots: s LOS --> LOS
;; removes shot from LOS according tp remove-shot?
(check-expect (remove-shots (make-spy 150 335 2 2 2) LOS1)
              LOS1)
(check-expect (remove-shots (make-spy 150 541 3 5 2) LOS1)
              (list (make-shot 150 380) (make-shot 150 360)))
(define (remove-shots s ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (if (remove-shot? s (first ls))
                        (remove-shots s (rest ls))
                        (cons (first ls) (remove-shots s (rest ls))))]))

;; handle-shot: shg --> shg
;; moves shots and removes them from the list of shot
(check-expect (handle-shot shg1)
              shg1)
(check-expect (handle-shot (make-shg 2 533 (make-spy 150 491 1 2 3)
                                     empty LOS1 3))
              (make-shg 2 533 (make-spy 150 491 1 2 3) empty 
                        (list (make-shot 150 330)
                              (make-shot 150 310))
                        3))
(define (handle-shot sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (shg-objects sg)
            (remove-shots (shg-spy sg) (move-shots (shg-shots sg)))
            (shg-dtop sg)))

;; count-frnds: LOO --> Num
;; counts the number of friends in the list of objects
(check-expect (count-frnds empty)
              0)
(check-expect (count-frnds (list (make-small-enemy 4 5 2 0)
                                 (make-small-enemy 5 25 6 0)
                                 (make-large-enemy 2 6 1 0)))
              0)
(check-expect (count-frnds LOO1)
              1)
(check-expect (count-frnds (cons (make-FriendlyCar 2 5 3) LOO1))
              2)

(define (count-frnds ls)
  (length (filter FriendlyCar? ls)))

;; random-car: shg --> FriendlyCar
;; makes a random car. if the random = 0, then the random car will be
;; ahead of the spy. otherwise it will be behind the spy
(define (random-car sg)
  (if (= 0 (random 2))
      (make-FriendlyCar (+ (random 390) 110)
                        (+ (spy-y (shg-spy sg)) (* 1/2 H) 53)
                        (- (spy-vel (shg-spy sg)) 3))   ;;subject to change
      (make-FriendlyCar (+ (random 390) 110)
                        (- (spy-y (shg-spy sg)) (* 1/2 H) 53)
                        (+ (spy-vel (shg-spy sg)) 5)))) ;;subject to change
;; generate-frnd: shg --> shg
;; places friendly cars off the screen based on random generation.
;; the cars can be in front or behind of spy. If the cars are in front,
;; they will have a slower velocity than spy. If they are behind, they will
;; be faster than spy.
;; The probability of generation decreases the more frnds are in shg-objects
(define (generate-frnd sg)
  (if (<= (random (+ 10 (count-frnds sg))) 4)
      (make-shg (shg-lives sg)
                (shg-score sg)
                (shg-spy sg)
                (cons (random-car sg)
                      (shg-objects sg))
                (shg-shots sg)
                (shg-dtop sg))
      sg))

;; random-truck: shg --> hlpr-truck
;; makes a random hlpr-truck
(define (random-truck sg)
  (make-hlpr-truck (+ (random 390) 110)
                   (- (spy-y (shg-spy sg)) (* 1/2 H) 109)
                   (if (= 0 (random 2)) 'os 'ss)
                   (+ (spy-vel (shg-spy sg)) 10))) ;; subject to change

;; alreadytruck?: LOO --> Boolean
;; determines if there is a truck in LOO
(define (alreadytruck? ls)
  (ormap hlpr-truck? ls))

;; generate-truck: shg --> shg
;; generates a truck if there is not already a truck in objects
(define (generate-truck sg) ;;; MIGHT BE BETTER TO JUST KEEP TRACK OF TICKS
  (cond [(alreadytruck? sg) sg]
        [(< (random 10) 2) (make-shg (shg-lives sg)
                                     (shg-score sg)
                                     (shg-spy sg)
                                     (cons (random-truck sg)
                                           (shg-objects sg))
                                     (shg-shots sg)
                                     (shg-dtop sg))]
        [else sg]))

;; generate-small-enemy: shg --> shg
;; places a small-enemy offscreen either infront of or behind the spy.
;; they will always start with x=(* 1/6 W) and velocity 10, but the AI
;; functions will change those values appropriately
(define (generate-small-enemy sg)
  (if (<= (random 5) 2) ;;; change for more or fewer enemies
      (make-shg (shg-lives sg)
                (shg-score sg)
                (shg-spy sg)
                (cons (make-small-enemy (* 1/6 W)
                                        (- (spy-y (shg-spy sg)) (* 1/2 H) 109)
                                        10 0) (shg-objects sg))
                (shg-shots sg)
                (shg-dtop sg))
      sg))

;; generate-large-enemy: shg --> shg
;; places a small-enemy offscreen either infront of or behind the spy.
;; they will always start with x=(* 1/6 W) and velocity 10, but the AI
;; functions will change those values appropriately
(define (generate-large-enemy sg)
  (if (<= (random 5) 1) ;;; change for more or fewer enemies
      (make-shg (shg-lives sg)
                (shg-score sg)
                (shg-spy sg)
                (cons (make-large-enemy (* 1/6 W)
                                        (- (spy-y (shg-spy sg)) (* 1/2 H) 109)
                                        10 0) (shg-objects sg))
                (shg-shots sg)
                (shg-dtop sg))
      sg))

;; generate-enemies: shg --> shg
;; generates large and small enemies from generate-small-enemy and
;; generate-large-enemy
(define (generate-enemies sg)
  (generate-small-enemy (generate-large-enemy sg)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       
;                       
;     ;;   ;;;;;        
;     ;;     ;          
;     ;;     ;          
;    ;  ;    ;          
;    ;  ;    ;          
;    ;  ;    ;          
;    ;;;;    ;          
;   ;    ;   ;          
;   ;    ; ;;;;;        
;                       
;                       
;                       
;; small enemies
;; large enemies
;; trucks


;; adjust-vel: spy enemy --> enemy
;; takes either a small or large enemy
;; it adjusts the enemie's vertical velocity so they can level with the spy
(check-expect (adjust-vel spy1 (make-small-enemy 300 790 23 0))
              (make-small-enemy 300 790 45 0))
(check-expect (adjust-vel spy2 (make-small-enemy 300 200 6 10))
              (make-small-enemy 300 200 5 10))
(check-expect (adjust-vel spy2 (make-large-enemy 300 396 10 4))
              (make-large-enemy 300 396 6 4))
(define (adjust-vel s e)
  (if (small-enemy? e)
      (make-small-enemy (small-enemy-x e)
                        (small-enemy-y e)
                        (clamp MIN-VEL
                               (- (small-enemy-vel e)
                                  (- (spy-y s) (small-enemy-y e)))
                               MAX-VEL)
                        (small-enemy-xvel e))
      (make-large-enemy (large-enemy-x e)
                        (large-enemy-y e)
                        (clamp MIN-VEL
                               (- (large-enemy-vel e)
                                  (- (spy-y s) (large-enemy-y e)))
                               MAX-VEL)
                        (large-enemy-xvel e))))
;;helper
(define (clamp mn x mx)
  (max mn (min x mx)))
;; adjust-xvel: spy enemy --> enemy
;; adjusts the x velocity of an enemy so that it can come up adjacent to spy
;; and then begin attacking spy
(check-expect (adjust-vel spy1 (make-small-enemy 300 790 23 0))
              (make-small-enemy 300 790 23 -10))
(check-expect (adjust-vel spy2 (make-small-enemy 200 200 6 10))
              (make-small-enemy 200 200 6 10))
(check-expect (adjust-vel spy2 (make-large-enemy 100 396 10 4))
              (make-large-enemy 100 396 10 2))
(define (adjust-xvel s e)
  (if (small-enemy? e)
      (make-small-enemy (small-enemy-x e)
                        (small-enemy-y e)
                        (small-enemy-xvel e)
                        (clamp MIN-XVEL
                               (- (- (spy-x s) (* 1/2 (image-width spy-car)))
                                  (- (small-enemy-x e)
                                     (* 1/2 (image-width sml-enemy))))
                               MAX-XVEL))
      (make-large-enemy (large-enemy-x e)
                        (large-enemy-y e)
                        (large-enemy-xvel e)
                        (clamp MIN-XVEL
                               (- (- (spy-x s) (* 1/2 (image-width spy-car)))
                                  (- (large-enemy-x e)
                                     (* 1/2 (image-width lrg-enemy))))
                               MAX-XVEL))))