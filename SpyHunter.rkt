;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname SpyHunter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ())))
(require 2htdp/image)
(require test-engine/racket-tests)
(require 2htdp/universe)
#|
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Constant data

;;; Images:
-- player's car       ;;DONE
  -crash image
-- helper truck       ;;DONE
  - oil slick icon    ;;DONE
  - smoke screen icon ;;DONE
-- small enemy        ;;DONE
  -crash image
-- bullet-proof enemy ;;DONE

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
(define starting-spy (make-spy 300 400 5 0 0))

;; an object is one of
;; - FriendlyCar
;; - small-enemy
;; - large-enemy
;; - hlpr-truck
;; - oilslick
;; - smokescreen
;; - crash

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
(define-struct hlpr-truck [x y gadget vel xvel d])
;; gadget is a symbol representing which gadget the truck is carrying
;; gadgets --> 'smokescreen 'oilslick
;; d is the direction. if 't the truck goes down, if 'f truck goes up

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

;; a crash is a 
;; (make-crash Image Num Num Num Num)
(define-struct crash [img x y vel xvel])

;; a List-of[Objects] (LOO) is one of:
;; empty
;; (cons object LOO)
(define LOO1 (list (make-os 300 400)
                   (make-ss 200 500 1)
                   (make-small-enemy 300 790 2 0)
                   (make-large-enemy 300 200 2 0)
                   (make-hlpr-truck 200 150 'os 3 -2 'f)
                   (make-FriendlyCar 400 150 5)))
(define LOO2 (list (make-os 300 400)
                   (make-ss 200 500 1)
                   (make-small-enemy 300 790 2 0)
                   (make-large-enemy 300 200 2 0)
                   (make-hlpr-truck 200 150 'os 3 -2 'f)
                   (make-FriendlyCar 400 150 5)
                   (make-crash sml-enemy 200 460 25 -5)))

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

;; a Listof[enemy] LOE is either
;; empty
;; (cons small-enemy LOE) or
;; (cons large-enemy LOE)

;; a car is either a
;; FriendlyCar
;; small-enemy
;; spy or
;; large-enemy

;; a Listof[car] LOC is either
;; empty or
;; (cons car LOC)

;; a gadget is either a
;; ss or an os

;; a Listo-of[Gadget] (LOG) is either
;; empty or
;; (cons gadget LOG)

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
(define starting-shg (make-shg 3 0 starting-spy empty empty -10))
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

;;;;; compute-LTRB/inset: x-pos y-pos Image Number --> LTRB
;;produce an LTRB with an inset of given Number of pixels
;On each of the LTRB's four sides
(check-expect (compute-LTRB/inset 10 10
                                  (square 6 'solid 'red)
                                  2)
              (make-LTRB 9 9 11 11))
(check-expect (compute-LTRB/inset 0 0
                                  (square 10 'solid 'red)
                                  3)
              (make-LTRB -2 -2 2 2))

(define (compute-LTRB/inset x y img num)
  (make-LTRB (- x
                (+ (* -1 num) (* 1/2 (image-width img))))
             (- y
                (+ (* -1 num) (* 1/2 (image-height img))))
             (+ x
                (+ (* -1 num) (* 1/2 (image-width img))))
             (+ y
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
      - is an enemy hit by shot?   ;;;DONE!
      - is an enemy or a spy off the road? ;;;DONE!
      - is the spy inside a truck?         ;;;DONE!
      - is an enemy or spy touching?       ;;;DONE!
      - is an enemy touching an os         ;;;DONE!
      - is an enemy touching a ss          ;;;DONE!

|#

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
                                            (no-os (shg-objects sg))
                                            (draw-spy
                                             (shg-spy sg)
                                             (draw-os
                                              (shg-spy sg)
                                              (draw-ss
                                               (shg-spy sg)
                                               (draw-LOO
                                                (filter os? (shg-objects sg))
                                                (draw-shot
                                                 (shg-shots sg)
                                                 (draw-bg sg)))))))))]
        [(gameover? sg) (overlay (above (text "Spy Hunter" 36 'red)
                                        (text "GAME OVER" 48 'red)
                                        (text (number->string
                                               (gameover-score sg)) 48 'green))
                                 plain-bg)]))
;; no-os: LOO --> LOO
;; removes the oilslicks from the LOO
(define (no-os ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (if (os? (first ls))
                        (no-os (rest ls))
                        (cons (first ls) (no-os (rest ls))))]))
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
  (if (>= (+ (wrap-y sg) H)
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
                              bg)]
        [(crash? o) (place-image (crash-img o)
                                 (crash-x o)
                                 (crash-y o)
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
(check-expect (handle-key (make-splash splash-image) "w")
              starting-shg)
(check-expect (handle-key (make-splash splash-image) "s")
              starting-shg)
(check-expect (handle-key (make-splash splash-image) "d")
              starting-shg)
(check-expect (handle-key (make-splash splash-image) "a")
              starting-shg)
(check-expect (handle-key (make-splash splash-image) "o")
              starting-shg)
(check-expect (handle-key (make-gameover 100) "w")
              (make-splash splash-image))
(check-expect (handle-key (make-gameover 100) "s")
              (make-splash splash-image))
(check-expect (handle-key (make-gameover 100) "d")
              (make-splash splash-image))
(check-expect (handle-key (make-gameover 100) "a")
              (make-splash splash-image))
(check-expect (handle-key (make-gameover 100) "i")
              (make-splash splash-image))
(check-expect (handle-key shg1 "w")
              (make-shg 3 0 (make-spy 300 400 10 0 0) empty empty -10))
(check-expect (handle-key shg2 "s")
              (make-shg 2 45 (make-spy 200 400 10 2 3) LOO1 LOS1 -20))
(check-expect (handle-key shg1 "a")
              (make-shg 3 0 (make-spy 290 400 0 0 0) empty empty -10))
(check-expect (handle-key shg2 "d")
              (make-shg 2 45 (make-spy 210 400 11 2 3) LOO1 LOS1 -20))
(check-expect (handle-key shg1 "e")
              (make-shg 3 0 (make-spy 300 400 0 0 0) empty empty -10))
(check-expect (handle-key shg2 "e")
              (make-shg 2 45 (make-spy 200 400 11 1 3)
                        (cons (make-os 200 453) LOO1) LOS1 -20))
(check-expect (handle-key shg1 "q")
              (make-shg 3 0 (make-spy 300 400 0 0 0) empty empty -10))
(check-expect (handle-key shg2 "q")
              (make-shg 2 45 (make-spy 200 400 11 2 2)
                        (cons (make-ss 200 (+ 400 (/ (image-height spy-car) 2))
                                       MAX-SSD) LOO1) LOS1 -20))
(check-expect (handle-key shg1 " ")
              (make-shg 3 0 (make-spy 300 400 0 0 0) empty
                        (cons (make-shot 300 (- 400
                                                (/ (image-height spy-car) 2)
                                                )) empty) -10))
(check-expect (handle-key shg1 "p")
              shg1)
(check-expect (handle-key shg1 "h")
              shg1)
(define (handle-key sg k)
  (cond [(splash? sg) starting-shg] ;; on any-key it makes the starting shg
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
                                                         (- (spy-y (shg-spy sg)
                                                                   )
                                                            (/ (image-height
                                                                spy-car) 2)))
                                              (shg-shots sg))
                                        (shg-dtop sg))]
               [(key=? "r" k) (backup sg)]
               [else sg])]))
;; backup: shg --> shg
(define (backup sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (backupLOO (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))
;; backupLOO: LOO --> LO
(define (backupLOO ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (if (hlpr-truck? (first ls))
                        (cons (change-d (first ls))
                              (backupLOO (rest ls)))
                        (cons (first ls) (backupLOO (rest ls))))]))
;; change-d: hlpr-truck --> hlpr-truck
(define (change-d t)
  (if (<= (hlpr-truck-y t) 300)
      (make-hlpr-truck (hlpr-truck-x t)
                       (hlpr-truck-y t)
                       (hlpr-truck-gadget t)
                       (hlpr-truck-vel t)
                       (hlpr-truck-xvel t)
                       't)
      (if (symbol=? 't (hlpr-truck-d t))
          (make-hlpr-truck (hlpr-truck-x t)
                           (hlpr-truck-y t)
                           (hlpr-truck-gadget t)
                           (hlpr-truck-vel t)
                           (hlpr-truck-xvel t)
                           't)
          (make-hlpr-truck (hlpr-truck-x t)
                           (hlpr-truck-y t)
                           (hlpr-truck-gadget t)
                           (hlpr-truck-vel t)
                           (hlpr-truck-xvel t)
                           'f))))
;; accelerate: Nat --> Nat
;; increases Nat by 10 unless it is >= (START-VEL + 20)
(define (accelerate s)
  (if (>= s (+ START-VEL 20))
      s
      (clamp MIN-SPYVEL (+ s 10) MAX-SPYVEL)))

;; decelerate: Nat --> Nat
;; decreases Nat by 10 unless it is < (START-VEL - 20)
(define (decelerate s)
  (if (<= s (- START-VEL 20))
      s
      (clamp MIN-SPYVEL (- s 10) MAX-SPYVEL)))

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
                (cons (make-os (spy-x s)
                               (+ (spy-y s) (+ (/ (image-height spy-car) 2)
                                               (/ (image-height os-image) 2))))
                      (shg-objects sg))
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
(define (handle-tick sg)
  (cond [(splash? sg) sg]
        [(gameover? sg) sg]
        [(shg? sg)
         (endgame
          (handle-collisions
           (handle-score
            (handle-spy
             (handle-enemies
              (move-window
               (move-friends
                (handle-crash
                 (handle-shot
                  (generate-frnd
                   (generate-truck
                    (generate-enemies
                     (remove-enemies
                      (remove-offscreen
                       (die
                        (handle-ss
                         (move-os
                          (handle-hlpr sg)))))
                      )))))))))))))]))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; endgame?: shg --> Boolean
;; determines if the game should end (when shg-live < 0
;; checks for shg
(check-expect (endgame? shg1) false)

(define (endgame? sg)
  (< (shg-lives sg) 0))

;; endgame: shg --> shg
;; if the game is over it makes shg a gameover
(define (endgame sg)
  (if (endgame? sg)
      (make-gameover (shg-score sg))
      sg))

;; offroad?: any car, truck, or crash --> Boolean
;; determines if a car is off of the road. Any car is off the road if
;; its x coordinate > 5/6 * W or x < 1/6 * W
;; or if its y coor. is > 3/2 * H or y < -H/2
(define (offroad? o)
  (cond [(FriendlyCar? o) (or (< (FriendlyCar-x o) (* 1/6 W))
                              (> (FriendlyCar-x o) (* 5/6 W))
                              (< (FriendlyCar-y o) (* -1/2 H))
                              (> (FriendlyCar-y o) (* 3/2 H)))]
        [(small-enemy? o) (or (< (small-enemy-x o) (* 1/6 W))
                              (> (small-enemy-x o) (* 5/6 W))
                              (< (small-enemy-y o) (* -1/2 H))
                              (> (small-enemy-y o) (* 3/2 H)))]
        [(large-enemy? o) (or (< (large-enemy-x o) (* 1/6 W))
                              (> (large-enemy-x o) (* 5/6 W))
                              (< (large-enemy-y o) (* -1/2 H))
                              (> (large-enemy-y o) (* 3/2 H)))]
        [(spy? o) (or (< (spy-x o) (* 1/6 W))
                      (> (spy-x o) (* 5/6 W)))]
        [(hlpr-truck? o) (or (< (hlpr-truck-x o) (* 1/6 W))
                             (> (hlpr-truck-x o) (* 5/6 W))
                             (< (hlpr-truck-y o) (* -1/2 H))
                             (> (hlpr-truck-y o) (* 3/2 H)))]
        [(crash? o) (or (< (crash-x o) (* 1/6 W))
                        (> (crash-x o) (* 5/6 W)))]
        [else false]))

;; die: shg --> shg
;; resets the shg if the spy dies
(define (die sg)
  (if (offroad? (shg-spy sg))
      (make-shg (- (shg-lives sg) 1)
                (shg-score sg)
                (make-spy (* 1/2 W) 400 START-VEL 0 0)
                (shg-objects sg)
                empty
                (shg-dtop sg))
      sg))

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
              (compute-ltrb (shot-x (first ls)) (shot-y (first ls))
                            player-shot)
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
                    (make-hlpr-truck 200 150 'os 3 -2 'f)
                    (make-FriendlyCar 400 150 5)))

(define (remove-sml-enemies lso lss)
  (cond [(empty? lso) empty]
        [(cons? lso)
         (if (and (small-enemy? (first lso))
                  (or (offroad? (first lso)) (sml-enemy-hit? (first lso) lss)))
             (remove-sml-enemies (rest lso) lss)
             (cons (first lso) (remove-sml-enemies (rest lso) lss)))]))
#| I decided to make large enemies bullet proof so this code became superfluous
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
|#
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
                    (make-large-enemy 300 200 2 0)
                    (make-hlpr-truck 200 150 'os 3 -2 'f)
                    (make-FriendlyCar 400 150 5)))

(define (remove-lrg-enemies lso lss)
  (cond [(empty? lso) empty]
        [(cons? lso)
         (if (and (large-enemy? (first lso))
                  (offroad? (first lso))) ;; if they can be shot -> add or exp.
             (remove-lrg-enemies (rest lso) lss)
             (cons (first lso) (remove-lrg-enemies (rest lso) lss)))]))
;; remove-enemies: shg --> shg
;; removes the enemies from the LOO in the shg
(define (remove-enemies sg)
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
        [(ss? o) (= 0 (ss-duration o))]
        [(crash? o) (or (<= (crash-y o) (- (spy-y s) (* 1/2 H) 200))
                        (>= (crash-y o)  (+ (spy-y s) (* 1/2 H) 200)))]
        ))

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
                                          (list (make-hlpr-truck 212 1354 'os
                                                                 4 5 'f)
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

;; crashed?: object gadget --> Boolean
;; determines if the object collided with a gadget
(define (crashed? o g)
  (cond [(small-enemy? o) (if (os? g)
                              (touching? (compute-ltrb (small-enemy-x o)
                                                       (small-enemy-y o)
                                                       sml-enemy)
                                         (compute-ltrb (os-x g)
                                                       (os-y g)
                                                       os-image))
                              (touching? (compute-ltrb (small-enemy-x o)
                                                       (small-enemy-y o)
                                                       sml-enemy)
                                         (compute-ltrb (ss-x g)
                                                       (ss-y g)
                                                       ss-image)))]
        [(large-enemy? o) (if (os? g)
                              (touching? (compute-ltrb (large-enemy-x o)
                                                       (large-enemy-y o)
                                                       lrg-enemy)
                                         (compute-ltrb (os-x g)
                                                       (os-y g)
                                                       os-image))
                              (touching? (compute-ltrb (large-enemy-x o)
                                                       (large-enemy-y o)
                                                       sml-enemy)
                                         (compute-ltrb (ss-x g)
                                                       (ss-y g)
                                                       ss-image)))]
        [(FriendlyCar? o) (if (os? g)
                              (touching? (compute-ltrb (FriendlyCar-x o)
                                                       (FriendlyCar-y o)
                                                       frnd)
                                         (compute-ltrb (os-x g)
                                                       (os-y g)
                                                       os-image))
                              (touching? (compute-ltrb (FriendlyCar-x o)
                                                       (FriendlyCar-y o)
                                                       frnd)
                                         (compute-ltrb (ss-x g)
                                                       (ss-y g)
                                                       ss-image)))]
        [else false]))

;; apply-crash: spy gadget LOO --> LOO
;; replaces hit objects with a crash
(check-within (apply-crash (make-spy 200 400 11 2 3) (make-os 300 200)
                           (list (make-small-enemy 300 790 2 0)
                                 (make-large-enemy 300 200 2 0)
                                 (make-hlpr-truck 200 150 'os 3 -2 'f)
                                 (make-FriendlyCar 400 150 5)))
              (list
               (make-small-enemy 300 790 2 0)
               (make-crash lrg-enemy 300 200 11 0)
               (make-hlpr-truck 200 150 'os 3 -2 'f)
               (make-FriendlyCar 400 150 5))
              5)
(check-within (apply-crash (make-spy 200 400 11 2 3) (make-os 300 780)
                           (list (make-small-enemy 300 790 2 0)
                                 (make-large-enemy 300 200 2 0)
                                 (make-hlpr-truck 200 150 'os 3 -2 'f)
                                 (make-FriendlyCar 400 150 5)))
              (list
               (make-crash sml-enemy 300 790 11 0)
               (make-large-enemy 300 200 2 0)
               (make-hlpr-truck 200 150 'os 3 -2 'f)
               (make-FriendlyCar 400 150 5))
              5)
(check-expect (apply-crash (make-spy 200 400 11 2 3) (make-os 200 150)
                           (list (make-small-enemy 300 790 2 0)
                                 (make-large-enemy 300 200 2 0)
                                 (make-hlpr-truck 200 150 'os 3 -2 'f)
                                 (make-FriendlyCar 400 150 5)))
              (list
               (make-small-enemy 300 790 2 0)
               (make-large-enemy 300 200 2 0)
               (make-hlpr-truck 200 150 'os 3 -2 'f)
               (make-FriendlyCar 400 150 5)))
(check-within (apply-crash (make-spy 200 400 11 2 3) (make-os 400 150)
                           (list (make-small-enemy 300 790 2 0)
                                 (make-large-enemy 300 200 2 0)
                                 (make-hlpr-truck 200 150 'os 3 -2 'f)
                                 (make-FriendlyCar 400 150 5)))
              (list
               (make-small-enemy 300 790 2 0)
               (make-large-enemy 300 200 2 0)
               (make-hlpr-truck 200 150 'os 3 -2 'f)
               (make-crash frnd 400 150 11 0))
              5)
(check-within (apply-crash (make-spy 200 400 11 2 3) (make-os 400 150)
                           (list (make-small-enemy 425 130 2 0)
                                 (make-large-enemy 300 200 2 0)
                                 (make-hlpr-truck 200 150 'os 3 -2 'f)
                                 (make-FriendlyCar 400 150 5)))
              (list
               (make-crash sml-enemy 425 130 11 0)
               (make-large-enemy 300 200 2 0)
               (make-hlpr-truck 200 150 'os 3 -2 'f)
               (make-crash frnd 400 150 11 0))
              5)
(define (apply-crash s g ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (if (crashed? (first ls) g)
                        (cons
                         (cond [(small-enemy? (first ls))
                                (make-crash sml-enemy
                                            (small-enemy-x (first ls))
                                            (small-enemy-y (first ls))
                                            (clamp 5 (spy-vel s) MAX-VEL)
                                            (- (random 11) 5))]
                               [(large-enemy? (first ls))
                                (make-crash lrg-enemy
                                            (large-enemy-x (first ls))
                                            (large-enemy-y (first ls))
                                            (clamp 5 (spy-vel s) MAX-VEL)
                                            (- (random 11) 5))]
                               [(FriendlyCar? (first ls))
                                (make-crash frnd
                                            (FriendlyCar-x (first ls))
                                            (FriendlyCar-y (first ls))
                                            (clamp 5 (spy-vel s) MAX-VEL)
                                            (- (random 11) 5))])
                         (apply-crash s g (rest ls)))
                        (cons (first ls)
                              (apply-crash s g (rest ls))))]))

;; apply-crashes: spy LOG LOO --> LOO
;; replaces all objects hit by gadgets with crashes
(check-expect (apply-crashes spy2
                             empty
                             (list (make-small-enemy 300 790 2 0)
                                   (make-large-enemy 300 200 2 0)
                                   (make-hlpr-truck 200 150 'os 3 -2 'f)
                                   (make-FriendlyCar 400 150 5)))
              (list (make-small-enemy 300 790 2 0)
                    (make-large-enemy 300 200 2 0)
                    (make-hlpr-truck 200 150 'os 3 -2 'f)
                    (make-FriendlyCar 400 150 5)))
(check-within (apply-crashes spy2
                             (list (make-os 297 210))
                             (list (make-small-enemy 300 790 2 0)
                                   (make-large-enemy 300 200 2 0)
                                   (make-hlpr-truck 200 150 'os 3 -2 'f)
                                   (make-FriendlyCar 400 150 5)))
              (list (make-small-enemy 300 790 2 0)
                    (make-crash lrg-enemy 300 200 11 0)
                    (make-hlpr-truck 200 150 'os 3 -2 'f)
                    (make-FriendlyCar 400 150 5))
              5)

(check-within (apply-crashes spy2
                             (list (make-ss 300 790 4)
                                   (make-os 297 210))
                             (list (make-small-enemy 300 790 2 0)
                                   (make-large-enemy 300 200 2 0)
                                   (make-hlpr-truck 200 150 'os 3 -2 'f)
                                   (make-FriendlyCar 400 150 5)))
              (list
               (make-crash sml-enemy 300 790 11 0)
               (make-crash lrg-enemy 300 200 11 0)
               (make-hlpr-truck 200 150 'os 3 -2 'f)
               (make-FriendlyCar 400 150 5))
              5)
(define (apply-crashes s lg lo)
  (cond [(empty? lg) lo]
        [(cons? lg)
         (apply-crashes s (rest lg) (apply-crash s (first lg) lo))]))

;; handle-applycrash: shg --> shg
;; applies crahses in an shg

;helper 
(define (gadget? o)
  (or (os? o)
      (ss? o)))
(define (handle-applycrash sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (apply-crashes (shg-spy sg) (filter gadget? (shg-objects sg))
                           (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))

;; move-crash: crash --> crash
;; moves a crash according to its velocities.
(define (move-crash c)
  (make-crash (crash-img c)
              (+ (crash-x c) (crash-xvel c))
              (+ (crash-y c) (crash-vel c))
              (crash-vel c)
              (crash-xvel c)))
;; move-crashinLOO: LOO --> LOO
;; moves all the crashes in the LOO
(define (move-crashinLOO ls)
  (cond [(empty? ls) empty]
        [(cons? ls)
         (if (crash? (first ls))
             (cons (move-crash (first ls))
                   (move-crashinLOO (rest ls)))
             (cons (first ls) (move-crashinLOO (rest ls))))]))
;; remove-crash: LOO --> LOO
;; removes the crashes that have gone offroad
(define (remove-crash ls)
  (cond [(empty? ls) empty]
        [(cons? ls)
         (if (offroad? (first ls))
             (remove-crash (rest ls))
             (cons (first ls) (remove-crash (rest ls))))]))
;; handle-crash: shg --> shg
;; applie, moves, and REMOVES crashes in shg
(define (handle-crash sg)
  (handle-applycrash
   (make-shg (shg-lives sg)
             (shg-score sg)
             (shg-spy sg)
             (remove-crash (move-crashinLOO (shg-objects sg)))
             (shg-shots sg)
             (shg-dtop sg))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; handle-score: shg --> shg
;; increases the score by 5 for each tick
(define (handle-score sg)
  (make-shg (shg-lives sg)
            (+ (shg-score sg) 5)
            (shg-spy sg)
            (shg-objects sg)
            (shg-shots sg)
            (shg-dtop sg)))

;; inside-truck?: Spy hlpr-truck --> Boolean
;; determines if the spy is inside truck
(check-expect (inside-truck? (make-spy 10 10 3 4 5)
                             (make-hlpr-truck 10 10 'os 3 0 'f))
              true)
(check-expect (inside-truck? (make-spy 15 10 3 4 5)
                             (make-hlpr-truck 10 10 'os 4 0 'f))
              false)
(define (inside-truck? s h)
  (inside? (compute-ltrb (spy-x s) (spy-y s) spy-car)
           (compute-LTRB/inset (hlpr-truck-x h) (hlpr-truck-y h) truck -1)))

;; add-power: spy hlpr-truck --> spy
;; if the spy is inside the hlpr-truck, it adds the trucks powers to spy
(check-expect (add-power (make-spy 15 10 3 4 5)
                         (make-hlpr-truck 10 10 'os 4 1 't))
              (make-spy 15 10 3 4 5))
(check-expect (add-power (make-spy 10 10 3 4 5)
                         (make-hlpr-truck 10 10 'os 3 3 't))
              (make-spy 10 10 3 14 5))
(check-expect (add-power (make-spy 10 10 3 4 5)
                         (make-hlpr-truck 10 10 'ss 3 5 't))
              (make-spy 10 10 3 4 10))
(define (add-power s h)                 ;; kinda worried about all the if expr.
  (if (and (inside-truck? s h)
           (symbol=? 't (hlpr-truck-d h)))
      (if (symbol=? (hlpr-truck-gadget h) 'os)
          (make-spy (spy-x s) (spy-y s) (spy-vel s) (+ (spy-osleft s) 10)
                    (spy-ssleft s))
          (make-spy (spy-x s) (spy-y s) (spy-vel s) (spy-osleft s)
                    (+ (spy-ssleft s) 5)))
      s))
;;handle-spy: shg --> shg
#;#;(check-expect (handle-spy (make-shg 1 342 (make-spy 10 10 3 4 5)
                                        (list (make-os 150 344)
                                              (make-FriendlyCar 1 2 45)
                                              (make-hlpr-truck 10 10 'os 5 0 'f)
                                              (make-small-enemy 356 321 20 0))
                                        empty 10))
                  (make-shg 1 342 (make-spy 10 7 3 14 5)
                            (list (make-os 150 344)
                                  (make-FriendlyCar 1 2 45)
                                  (make-hlpr-truck 10 10 'os 5 0 'f)
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
  (make-shg (shg-lives sg) ;; removed the move spy part
            (shg-score sg)
            (if (empty? (filter hlpr-truck? (shg-objects sg)))
                (shg-spy sg)
                (add-power (shg-spy sg) (first
                                         (filter hlpr-truck?
                                                 (shg-objects sg)))))
            (shg-objects sg)
            (shg-shots sg)
            (shg-dtop sg)))

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

;; move-enemy: enemy --> enemy
;; moves the enemy in both the x and y direction according to its velocity
(check-expect (move-enemy (make-small-enemy 100 200 3 5))
              (make-small-enemy 105 197 3 5))
(check-expect (move-enemy (make-small-enemy 100 200 0 -2))
              (make-small-enemy 98 200 0 -2))
(check-expect (move-enemy (make-large-enemy 100 200 3 5))
              (make-large-enemy 105 197 3 5))
(check-expect (move-enemy (make-large-enemy 100 200 0 -2))
              (make-large-enemy 98 200 0 -2))
(define (move-enemy e)
  (if (small-enemy? e)
      (make-small-enemy (+ (small-enemy-x e) (small-enemy-xvel e))
                        (- (small-enemy-y e) (small-enemy-vel e))
                        (small-enemy-vel e) (small-enemy-xvel e))
      (make-large-enemy (+ (large-enemy-x e) (large-enemy-xvel e))
                        (- (large-enemy-y e) (large-enemy-vel e))
                        (large-enemy-vel e) (large-enemy-xvel e))))
;; move-window: shg --> shg
;; moves the screen's window up according to the spy's velocity
(check-expect (move-window shg1)
              (make-shg 3 0 spy1 empty empty -10)) ;; spy velocity is 0
(check-expect (move-window shg2)
              (make-shg 2 45 spy2 LOO1 LOS1 -9))
(check-expect (move-window shg6)
              (make-shg 1 95 spy2 empty empty 814))
(define (move-window sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (shg-objects sg)
            (shg-shots sg)
            (if (<= 2400 (+ (shg-dtop sg) (spy-vel (shg-spy sg))))
                1600
                (+ (shg-dtop sg) (spy-vel (shg-spy sg))))))

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
                                        (make-hlpr-truck 22 44 'os 4 0 'f)))
              (list (make-os 134 592)
                    (make-os 140 32)
                    (make-small-enemy 13 5 23 0)
                    (make-hlpr-truck 22 44 'os 4 0 'f)))
(check-expect (move-frndinobjects LOO1)
              (list (make-os 300 400)
                    (make-ss 200 500 1)
                    (make-small-enemy 300 790 2 0)
                    (make-large-enemy 300 200 2 0)
                    (make-hlpr-truck 200 150 'os 3 -2 'f)
                    (make-FriendlyCar 400 145 5)))
(check-expect (move-frndinobjects (cons (make-FriendlyCar 145 6 2) LOO1))
              (list (make-FriendlyCar 145 4 2)
                    (make-os 300 400)
                    (make-ss 200 500 1)
                    (make-small-enemy 300 790 2 0)
                    (make-large-enemy 300 200 2 0)
                    (make-hlpr-truck 200 150 'os 3 -2 'f)
                    (make-FriendlyCar 400 145 5)))
(check-expect (move-frndinobjects (list (make-FriendlyCar 145 6 2)
                                        (make-FriendlyCar 15 86 35)
                                        (make-FriendlyCar 45 656 4)))
              (list (make-FriendlyCar 145 4 2)
                    (make-FriendlyCar 15 51 35)
                    (make-FriendlyCar 45 652 4)))
(check-expect (move-frndinobjects (list (make-FriendlyCar 145 6 2)
                                        (make-hlpr-truck 200 150 'os 3 0 'f)
                                        (make-large-enemy 300 200 2 0)
                                        (make-FriendlyCar 15 86 35)
                                        (make-FriendlyCar 45 656 4)))
              (list (make-FriendlyCar 145 4 2)
                    (make-hlpr-truck 200 150 'os 3 0 'f)
                    (make-large-enemy 300 200 2 0)
                    (make-FriendlyCar 15 51 35)
                    (make-FriendlyCar 45 652 4)))
(define (move-frndinobjects ls)
  (cond [(empty? ls) empty]
        [(cons? ls)
         (cons (move-frnd (first ls)) (move-frndinobjects (rest ls)))]))

;; move-friends: shg --> shg
;; moves all of the friendly cars in shg's LOO
(check-expect (move-friends shg1)
              shg1)
(check-expect (move-friends shg2)
              (make-shg 2 45 spy2
                        (list (make-os 300 400)
                              (make-ss 200 500 1)
                              (make-small-enemy 300 790 2 0)
                              (make-large-enemy 300 200 2 0)
                              (make-hlpr-truck 200 150 'os 3 -2 'f)
                              (make-FriendlyCar 400 145 5))
                        LOS1
                        -20))
(check-expect (move-friends (make-shg 1 20 spy1
                                      (list (make-os 134 592)
                                            (make-os 140 32)
                                            (make-small-enemy 13 5 23 0)
                                            (make-hlpr-truck 22 44 'os 4 0 'f))
                                      empty
                                      2))
              (make-shg 1 20 spy1 (list (make-os 134 592)
                                        (make-os 140 32)
                                        (make-small-enemy 13 5 23 0)
                                        (make-hlpr-truck 22 44 'os 4 0 'f))
                        empty
                        2))
(check-expect (move-friends (make-shg 3 544 spy2
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
(define (move-friends sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (move-frndinobjects (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))
;; move-singleos: spy object --> os
;; moves an os down according to the spy's velocity
(define (move-singleos s o)
  (if (os? o) (make-os (os-x o) (+ (os-y o) (spy-vel s)))
      o))
;; move-osinobjects: spy LOO --> LOO
;; produces the same list, but with the oilslicks moved
(define (move-osinobjects s ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (cons (move-singleos s (first ls))
                          (move-osinobjects s (rest ls)))]))
;; move-os: shg --> shg
;; moves all the os in an shg
(define (move-os sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (move-osinobjects (shg-spy sg) (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))
;; move-singless spy object --> ss
;; moves a ss to the back of the spy
(define (move-singless sp o)
  (if (ss? o) (make-ss (spy-x sp)
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
;; move-ss: shg --> shg    ;;; use handle-ss in handle-tick
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
                                        (make-hlpr-truck 200 150 'os 3 -2 'f)
                                        (make-FriendlyCar 400 150 5))
                        LOS1 -20))
(define (move-ss sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (move-ssinobjects (shg-spy sg) (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))
;; sub-duration: LOO --> LOO
;; decreases the duration of the ss
(define (sub-duration ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (if (ss? (first ls))
                        (cons (make-ss (ss-x (first ls)) (ss-y (first ls))
                                       (- (ss-duration (first ls)) 1))
                              (sub-duration (rest ls)))
                        (cons (first ls) (sub-duration (rest ls))))]))
;; handle-ss: shg --> shg
;; moves and subtracts the duration of an ss in an shg
(define (handle-ss sg)
  (move-ss (make-shg (shg-lives sg)
                     (shg-score sg)
                     (shg-spy sg)
                     (sub-duration (shg-objects sg))
                     (shg-shots sg)
                     (shg-dtop sg))))
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

;; count-x: f LOO --> Num
;; counts the number of x that is in a given LOO
;; f is a Boolean function that identifies structs
(check-expect (count-x FriendlyCar? empty)
              0)
(check-expect (count-x FriendlyCar? (list (make-small-enemy 4 5 2 0)
                                          (make-small-enemy 5 25 6 0)
                                          (make-large-enemy 2 6 1 0)))
              0)
(check-expect (count-x small-enemy? LOO1)
              1)
(check-expect (count-x small-enemy? (cons (make-small-enemy 2 5 3 2) LOO1))
              2)
(define (count-x f ls)
  (length (filter f ls)))
;; random-car: shg --> FriendlyCar
;; makes a random car. if the random = 0, then the random car will be
;; ahead of the spy. otherwise it will be behind the spy
(define (random-car sg)
  (if (= 0 (random 2))
      (make-FriendlyCar (+ (random 390) 110)
                        (+ (spy-y (shg-spy sg)) (* 1/2 H) 53)
                        (- 40 (spy-vel (shg-spy sg))))   ;;subject to change
      (make-FriendlyCar (+ (random 390) 110)
                        (- (spy-y (shg-spy sg)) (* 1/2 H) 53)
                        (* -1 (+ (spy-vel (shg-spy sg)) 10)))));;sbjct to change
;; generate-frnd: shg --> shg
;; places friendly cars off the screen based on random generation.
;; the cars can be in front or behind of spy. If the cars are in front,
;; they will have a slower velocity than spy. If they are behind, they will
;; be faster than spy.
;; The probability of generation decreases the more frnds are in shg-objects
(define (generate-frnd sg)
  (if (<= (random (+ 200 (count-x FriendlyCar? (shg-objects sg)))) 4)
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
                   (+ (spy-y (shg-spy sg)) (* 1/2 H) 109)
                   (if (= 0 (random 2)) 'os 'ss)
                   (+ (spy-vel (shg-spy sg)) 10) ;; subject to change
                   0
                   'f))

;; alreadytruck?: LOO --> Boolean
;; determines if there is a truck in LOO
(define (alreadytruck? ls)
  (ormap hlpr-truck? ls))

;; generate-truck: shg --> shg
;; generates a truck if there is not already a truck in objects
(define (generate-truck sg) ;;; MIGHT BE BETTER TO JUST KEEP TRACK OF TICKS
  (cond [(alreadytruck? (shg-objects sg)) sg]
        [(< (random 1000) 2) (make-shg (shg-lives sg) ;;random 1000
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
  (local ((define numcars (count-x small-enemy? (shg-objects sg))))
  (if (and (<= (+ (random 130)
                  (* 25 numcars)) 2) ;;; change for more or fewer enemies
           (< numcars 3)) ;; 3 enemies max
      (make-shg (shg-lives sg)
                (shg-score sg)
                (shg-spy sg)
                (cons (make-small-enemy (+ (random 390) 110)
                                        (+ (spy-y (shg-spy sg)) (* 1/2 H) 109)
                                        10 0) (shg-objects sg))
                (shg-shots sg)
                (shg-dtop sg))
      sg)))
;; aready-sml?: LOO --> Boolean
;; function used for testing purposes
;; determines if there is a small-enemy in the ls
(define (already-sml? ls)
  (cond [(empty? ls) false]
        [(cons? ls) (or (small-enemy? (first ls))
                        (already-sml? (rest ls)))]))

;; generate-large-enemy: shg --> shg
;; places a small-enemy offscreen either infront of or behind the spy.
;; they will always start with x=(* 1/6 W) and velocity 10, but the AI
;; functions will change those values appropriately
(define (generate-large-enemy sg)
  (local ((define numcars (count-x large-enemy? (shg-objects sg))))
  (if (and (<= (+ (random 500) numcars) 1) ;;; change for more or fewer enemies
           (< (count-x large-enemy? (shg-objects sg)) 2)) ;; 2 enemies max
      (make-shg (shg-lives sg)
                (shg-score sg)
                (shg-spy sg)
                (cons (make-large-enemy (+ (random 390) 110)
                                        (- (spy-y (shg-spy sg)) (* 1/2 H) 109)
                                        10 0) (shg-objects sg))
                (shg-shots sg)
                (shg-dtop sg))
      sg)))

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

;; adjust-hlpr-xvel: spy hlpr-truck --> hlpr-truck
(define (adjust-hlpr-xvel s t)
  (if (and (symbol=? 't (hlpr-truck-d t))
           (= 380 (hlpr-truck-y t)))
      (make-hlpr-truck (hlpr-truck-x t)
                       (hlpr-truck-y t)
                       (hlpr-truck-gadget t)
                       (hlpr-truck-vel t)
                       -10
                       (hlpr-truck-d t))
      (make-hlpr-truck (hlpr-truck-x t)
                       (hlpr-truck-y t)
                       (hlpr-truck-gadget t)
                       (hlpr-truck-vel t)
                       (clamp MIN-XVEL
                              (- (- (spy-x s) (* 1/2 (image-width spy-car)))
                                 (- (hlpr-truck-x t)
                                    (* 1/2 (image-width truck))))
                              MAX-XVEL)
                       (hlpr-truck-d t))))
;; adjust-hlpr-vel: spy hlpr-truck --> truck
(define (adjust-hlpr-vel s t)
  (if (and (symbol=? 't (hlpr-truck-d t))
           (<= (hlpr-truck-x t) (* 1/6 W)))
      (make-hlpr-truck (hlpr-truck-x t)
                       (hlpr-truck-y t)
                       (hlpr-truck-gadget t)
                       -10
                       0
                       (hlpr-truck-d t))
      
      (if (symbol=? 't (hlpr-truck-d t))
          (if (= 380 (hlpr-truck-y t))
              (make-hlpr-truck (hlpr-truck-x t)
                               (hlpr-truck-y t)
                               (hlpr-truck-gadget t)
                               0
                               (hlpr-truck-xvel t)
                               (hlpr-truck-d t))
              (make-hlpr-truck (hlpr-truck-x t)
                               (+ 5 (hlpr-truck-y t))
                               (hlpr-truck-gadget t)
                               -5
                               (hlpr-truck-xvel t)
                               (hlpr-truck-d t)))
          (make-hlpr-truck (hlpr-truck-x t)
                           (hlpr-truck-y t)
                           (hlpr-truck-gadget t)
                           (+ (spy-vel s) 2)
                           (hlpr-truck-xvel t)
                           (hlpr-truck-d t)))))

;; move-hlpr-truck: spy hlpr-truck --> hlpr-truck
(define (move-hlpr-truck s t)
  (if (and (< (- (spy-y s) 25) (hlpr-truck-y t))
           (symbol=? 'f (hlpr-truck-d t)))
      (make-hlpr-truck (clamp (- (spy-x s)
                                 (* 1/2 (image-width spy-car))
                                 (* 1/2 (image-width truck)))
                              (+ (hlpr-truck-x t) (hlpr-truck-xvel t))
                              (+ (spy-x s)
                                 (* 1/2 (image-width spy-car))
                                 (* 1/2 (image-width truck))))
                       (- (hlpr-truck-y t) (hlpr-truck-vel t))
                       (hlpr-truck-gadget t)
                       (hlpr-truck-vel t)
                       (hlpr-truck-xvel t)
                       (hlpr-truck-d t))
      (if (<= (hlpr-truck-y t) 300)
          (make-hlpr-truck (+ (hlpr-truck-x t) (hlpr-truck-xvel t))
                           300
                           (hlpr-truck-gadget t)
                           (hlpr-truck-vel t)
                           (hlpr-truck-xvel t)
                           (hlpr-truck-d t))
          
          (make-hlpr-truck (+ (hlpr-truck-x t) (hlpr-truck-xvel t))
                           (- (hlpr-truck-y t) (hlpr-truck-vel t))
                           (hlpr-truck-gadget t)
                           (hlpr-truck-vel t)
                           (hlpr-truck-xvel t)
                           (hlpr-truck-d t)))))
;; change-truck-vel-pos: spy hlpr-truck --> hlpr-truck
(define (change-truck-vel-pos s t)
  (adjust-hlpr-vel s (adjust-hlpr-xvel s (move-hlpr-truck s t))))
;; move-hlpr-inLOO: Spy LOO --> LOO
(define (move-hlpr-inLOO s ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (if (hlpr-truck? (first ls))
                        (cons (change-truck-vel-pos s (first ls))
                              (rest ls))
                        (cons (first ls) (move-hlpr-inLOO s (rest ls))))]))
;; handle-hlpr: shg --> shg
(define (handle-hlpr sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (move-hlpr-inLOO (shg-spy sg) (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))

;; adjust-vel: spy enemy --> enemy
;; takes either a small or large enemy
;; it adjusts the enemie's vertical velocity so they can level with the spy
(check-expect (adjust-vel spy1 (make-small-enemy 300 790 23 0))
              (make-small-enemy 300 790 10 0))
(check-expect (adjust-vel spy2 (make-small-enemy 300 200 6 10))
              (make-small-enemy 300 200 -15 10))
(check-expect (adjust-vel spy2 (make-large-enemy 300 396 10 4))
              (make-large-enemy 300 396 6 4))
(define (adjust-vel s e)
  (if (small-enemy? e)
      (make-small-enemy (small-enemy-x e)
                        (small-enemy-y e)
                        (clamp MIN-VEL
                               (- (small-enemy-vel e)
                                  (- (spy-y s) (small-enemy-y e)))
                               MAX-ENEMYVEL)
                        (small-enemy-xvel e))
      (make-large-enemy (large-enemy-x e)
                        (large-enemy-y e)
                        (clamp MIN-VEL
                               (- (large-enemy-vel e)
                                  (- (spy-y s) (large-enemy-y e)))
                               MAX-ENEMYVEL)
                        (large-enemy-xvel e))))
;;helper
(define (clamp mn x mx)
  (max mn (min x mx)))
;; adjust-xvel: spy enemy --> enemy
;; adjusts the x velocity of an enemy so that it can come up adjacent to spy
;; and then begin attacking spy
(check-expect (adjust-xvel spy1 (make-small-enemy 300 790 23 0))
              (make-small-enemy 300 790 23 0))
(check-expect (adjust-xvel spy2 (make-small-enemy 200 200 6 10))
              (make-small-enemy 200 200 6 0))
(check-expect (adjust-xvel spy2 (make-large-enemy 100 396 10 4))
              (make-large-enemy 100 396 10 2))
(define (adjust-xvel s e)
  (if (small-enemy? e)
      (make-small-enemy (small-enemy-x e)
                        (small-enemy-y e)
                        (small-enemy-vel e)
                        (clamp MIN-XVEL
                               (- (- (spy-x s) (* 1/2 (image-width spy-car)))
                                  (- (small-enemy-x e)
                                     (* 1/2 (image-width sml-enemy))))
                               MAX-XVEL))
      (make-large-enemy (large-enemy-x e)
                        (large-enemy-y e)
                        (large-enemy-vel e)
                        (clamp MIN-XVEL
                               (- (- (spy-x s) (* 1/2 (image-width spy-car)))
                                  (- (large-enemy-x e)
                                     (* 1/2 (image-width lrg-enemy))))
                               MAX-XVEL))))

;; change-enemy-vel-pos: spy enemy --> enemy
;; moves and adjusts the velocities of the enemy
(define (change-enemy-vel-pos s e)
  (adjust-vel s (adjust-xvel s (move-enemy e))))

;; move-enemiesinLOO: spy LOO --> LOO
;; moves and adjusts the velocity of every enemy in the LOO
(check-expect (move-enemiesinLOO spy1 empty)
              empty)
(check-expect (move-enemiesinLOO spy1 (list (make-small-enemy 100 30 4 -1)
                                            (make-small-enemy 504 636 11 0)
                                            (make-large-enemy 708 432 1 10)))
              (list (make-small-enemy 99 26 -15 2)
                    (make-small-enemy 504 625 10 -10)
                    (make-large-enemy 718 431 10 -10)))
(define (move-enemiesinLOO s ls)
  (cond [(empty? ls) empty]
        [(cons? ls)
         (if (or (small-enemy? (first ls)) (large-enemy? (first ls)))
             (cons (change-enemy-vel-pos s (first ls)) (move-enemiesinLOO
                                                        s (rest ls)))
             (cons (first ls) (move-enemiesinLOO s (rest ls))))]))

;; handle-enemies: shg --> shg
(define (handle-enemies sg)
  (make-shg (shg-lives sg)
            (shg-score sg)
            (shg-spy sg)
            (move-enemiesinLOO (shg-spy sg) (shg-objects sg))
            (shg-shots sg)
            (shg-dtop sg)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Collisions between cars

;;bounce-left: car --> car
;; moves the car 10 pixels to the left
(check-expect (bounce-left spy1) (make-spy 290 400 0 0 0))
(check-expect (bounce-left (make-small-enemy 120 899 20 10))
              (make-small-enemy 110 899 20 10))
(check-expect (bounce-left (make-large-enemy 328 391 -15 0))
              (make-large-enemy 318 391 -15 0))
(check-expect (bounce-left (make-FriendlyCar 110 367 -15))
              (make-FriendlyCar 100 367 -15))
(check-expect (bounce-left (make-hlpr-truck 330 355 'ss 7 0 'f))
              (make-hlpr-truck 320 355 'ss 7 0 'f))
(define (bounce-left c)
  (cond [(spy? c) (make-spy (- (spy-x c) 10) (spy-y c) (spy-vel c)
                            (spy-osleft c)
                            (spy-ssleft c))]
        [(small-enemy? c) (make-small-enemy (- (small-enemy-x c) 10)
                                            (small-enemy-y c)
                                            (small-enemy-vel c)
                                            (small-enemy-xvel c))]
        [(large-enemy? c) (make-large-enemy (- (large-enemy-x c) 10)
                                            (large-enemy-y c)
                                            (large-enemy-vel c)
                                            (large-enemy-xvel c))]
        [(FriendlyCar? c) (make-FriendlyCar (- (FriendlyCar-x c) 10)
                                            (FriendlyCar-y c)
                                            (FriendlyCar-vel c))]
        [(hlpr-truck? c) (make-hlpr-truck (- (hlpr-truck-x c) 10)
                                          (hlpr-truck-y c)
                                          (hlpr-truck-gadget c)
                                          (hlpr-truck-vel c)
                                          (hlpr-truck-xvel c)
                                          (hlpr-truck-d c))]))
;; bounce-right: car --> car
;; moves the car 10 pixels to the right
(check-expect (bounce-right spy1) (make-spy 310 400 0 0 0))
(check-expect (bounce-right (make-small-enemy 120 899 20 10))
              (make-small-enemy 130 899 20 10))
(check-expect (bounce-right (make-large-enemy 328 391 -15 0))
              (make-large-enemy 338 391 -15 0))
(check-expect (bounce-right (make-FriendlyCar 110 367 -15))
              (make-FriendlyCar 120 367 -15))
(check-expect (bounce-right (make-hlpr-truck 330 355 'ss 7 0 'f))
              (make-hlpr-truck 340 355 'ss 7 0 'f))
(define (bounce-right c)
  (cond [(spy? c) (make-spy (+ (spy-x c) 10) (spy-y c) (spy-vel c)
                            (spy-osleft c)
                            (spy-ssleft c))]
        [(small-enemy? c) (make-small-enemy (+ (small-enemy-x c) 10)
                                            (small-enemy-y c)
                                            (small-enemy-vel c)
                                            (small-enemy-xvel c))]
        [(large-enemy? c) (make-large-enemy (+ (large-enemy-x c) 10)
                                            (large-enemy-y c)
                                            (large-enemy-vel c)
                                            (large-enemy-xvel c))]
        [(FriendlyCar? c) (make-FriendlyCar (+ (FriendlyCar-x c) 10)
                                            (FriendlyCar-y c)
                                            (FriendlyCar-vel c))]
        [(hlpr-truck? c) (make-hlpr-truck (+ (hlpr-truck-x c) 10)
                                          (hlpr-truck-y c)
                                          (hlpr-truck-gadget c)
                                          (hlpr-truck-vel c)
                                          (hlpr-truck-xvel c)
                                          (hlpr-truck-d c))]))
;; bounce-up: car --> car
;; moves the car up 10 pixels
(check-expect (bounce-up spy1) (make-spy 300 390 0 0 0))
(check-expect (bounce-up (make-small-enemy 120 899 20 10))
              (make-small-enemy 120 889 20 10))
(check-expect (bounce-up (make-large-enemy 328 391 -15 0))
              (make-large-enemy 328 381 -15 0))
(check-expect (bounce-up (make-FriendlyCar 110 367 -15))
              (make-FriendlyCar 110 357 -15))
(check-expect (bounce-up (make-hlpr-truck 330 355 'ss 7 0 'f))
              (make-hlpr-truck 330 345 'ss 7 0 'f))
(define (bounce-up c)
  (cond [(spy? c) (make-spy (spy-x c) (- (spy-y c) 10) (spy-vel c)
                            (spy-osleft c)
                            (spy-ssleft c))]
        [(small-enemy? c) (make-small-enemy (small-enemy-x c)
                                            (- (small-enemy-y c) 10)
                                            (small-enemy-vel c)
                                            (small-enemy-xvel c))]
        [(large-enemy? c) (make-large-enemy (large-enemy-x c)
                                            (- (large-enemy-y c) 10)
                                            (large-enemy-vel c)
                                            (large-enemy-xvel c))]
        [(FriendlyCar? c) (make-FriendlyCar (FriendlyCar-x c)
                                            (- (FriendlyCar-y c) 10)
                                            (FriendlyCar-vel c))]
        [(hlpr-truck? c) (make-hlpr-truck (hlpr-truck-x c)
                                          (- (hlpr-truck-y c) 10)
                                          (hlpr-truck-gadget c)
                                          (hlpr-truck-vel c)
                                          (hlpr-truck-xvel c)
                                          (hlpr-truck-d c))]))
;; bounce-down: car --> car
;; moves the car down 10 pixels
(check-expect (bounce-down spy1) (make-spy 300 410 0 0 0))
(check-expect (bounce-down (make-small-enemy 120 899 20 10))
              (make-small-enemy 120 909 20 10))
(check-expect (bounce-down (make-large-enemy 328 391 -15 0))
              (make-large-enemy 328 401 -15 0))
(check-expect (bounce-down (make-FriendlyCar 110 367 -15))
              (make-FriendlyCar 110 377 -15))
(check-expect (bounce-down (make-hlpr-truck 330 355 'ss 7 0 'f))
              (make-hlpr-truck 330 365 'ss 7 0 'f))
(define (bounce-down c)
  (cond [(spy? c) (make-spy (spy-x c) (+ (spy-y c) 10) (spy-vel c)
                            (spy-osleft c)
                            (spy-ssleft c))]
        [(small-enemy? c) (make-small-enemy (small-enemy-x c)
                                            (+ (small-enemy-y c) 10)
                                            (small-enemy-vel c)
                                            (small-enemy-xvel c))]
        [(large-enemy? c) (make-large-enemy (large-enemy-x c)
                                            (+ (large-enemy-y c) 10)
                                            (large-enemy-vel c)
                                            (large-enemy-xvel c))]
        [(FriendlyCar? c) (make-FriendlyCar (FriendlyCar-x c)
                                            (+ (FriendlyCar-y c) 10)
                                            (FriendlyCar-vel c))]
        [(hlpr-truck? c) (make-hlpr-truck (hlpr-truck-x c)
                                          (+ (hlpr-truck-y c) 10)
                                          (hlpr-truck-gadget c)
                                          (hlpr-truck-vel c)
                                          (hlpr-truck-xvel c)
                                          (hlpr-truck-d c))]))
;; spy-collision: spy car --> spy
;; if spy collides with car, it bounces spy
;; spy will bounce in the opposite direction of the car it collides with
(check-expect (spy-collision spy1 (make-small-enemy 300 400 0 0))
              (make-spy 310 400 0 0 0))
(check-expect (spy-collision spy1 (make-large-enemy 299 400 0 0))
              (make-spy 310 400 0 0 0))
(check-expect (spy-collision spy1 (make-FriendlyCar 301 400 0))
              (make-spy 290 400 0 0 0))
(check-expect (spy-collision spy1 (make-FriendlyCar 500 400 0))
              (make-spy 300 400 0 0 0))
(check-expect (spy-collision spy1 (make-hlpr-truck 3 2 'os 2 4 't))
              spy1)
(define (spy-collision s c)
  (cond [(small-enemy? c) (if (overlapping? (compute-ltrb (spy-x s)
                                                          (spy-y s)
                                                          spy-car)
                                            (compute-ltrb (small-enemy-x c)
                                                          (small-enemy-y c)
                                                          sml-enemy))
                              (if (>= (spy-x s) (small-enemy-x c))
                                  (bounce-right s)
                                  (bounce-left s))
                              s)]
        [(large-enemy? c) (if (overlapping? (compute-ltrb (spy-x s)
                                                          (spy-y s)
                                                          spy-car)
                                            (compute-ltrb (large-enemy-x c)
                                                          (large-enemy-y c)
                                                          lrg-enemy))
                              (if (>= (spy-x s) (large-enemy-x c))
                                  (bounce-right s)
                                  (bounce-left s))
                              s)]
        [(FriendlyCar? c) (if (overlapping? (compute-ltrb (spy-x s)
                                                          (spy-y s)
                                                          spy-car)
                                            (compute-ltrb (FriendlyCar-x c)
                                                          (FriendlyCar-y c)
                                                          frnd))
                              (if (>= (spy-x s) (FriendlyCar-x c))
                                  (bounce-right s)
                                  (bounce-left s))
                              s)]
        [(hlpr-truck? c) s]
        [else s]))
;; spy-collisionLOO: spy LOC --> spy
;; bounces spy if it collides with any car in the shg's LOO (filtered to LOC)
(define (spy-collisionLOO s ls)
  (cond [(empty? ls) s]
        [(cons? ls) (spy-collisionLOO (spy-collision s (first ls))
                                      (rest ls))]))
;; collision-spyLOO: spy LOO --> LOO
;; bounces all cars in LOO hit by spy
(define (collision-spyLOO s ls)
  (cond [(empty? ls) empty]
        [(cons? ls) (cons (collision-wspy (first ls) s)
                          (collision-spyLOO s (rest ls)))]))
;;collision-cars: object LOO --> object
;; collides the car with all the cars in LOO
(define (collision-cars o ls)
  (cond [(empty? ls) o]
        [(cons? ls) (collision-cars (collision-car o (first ls)) (rest ls))]))
;; collision-LOO: LOC --> LOC
;; bounces cars in the LOO (filtered to LOC)
;; by the cars further down in the list
#;(define (collision-LOO ls)
    (cond [(empty?  ls) empty]
          [(empty? (rest ls)) ls]
          [(cons? (rest ls)) (cons (collision-car (first ls) (second ls))
                                   (collision-LOO (rest ls)))]))
(define (collision-LOO ls)
  (cond [(empty?  ls) empty]
        [(cons? ls) (cons (collision-cars (first ls) (rest ls))
                          (collision-LOO (rest ls)))]))
;; handle-collision: shg --> shg
;; handles all the collisions in an shg
#;(define (handle-collisions sg)
    (make-shg (shg-lives sg)
              (shg-score sg)
              (spy-collisionLOO (shg-spy sg) (shg-objects sg))
              (collision-spyLOO (shg-spy sg) (collision-LOO (shg-objects sg)))
              (shg-shots sg)
              (shg-dtop sg)))
(define (handle-collisions sg)
  (local ((define bSpy (spy-collisionLOO (shg-spy sg) (shg-objects sg))))
    (make-shg (shg-lives sg)
              (shg-score sg)
              bSpy
              (collision-spyLOO (shg-spy sg) (collision-LOO (shg-objects sg)))
              (shg-shots sg)
              (shg-dtop sg))))
;; helper
;; car?: any --> Boolean
(define (car? a)
  (or (small-enemy? a)
      (large-enemy? a)
      (FriendlyCar? a)
      (hlpr-truck? a)
      (spy? a)))
;; collision-wspy: object spy --> object
;; bounces the car if it touches spy
(define (collision-wspy c s)
  (if (hlpr-truck? c)
      c
      (local ((define sx (spy-x s))
              (define sy (spy-y s))
              (define cIMG (cond [(small-enemy? c)
                                  sml-enemy]
                                 [(large-enemy? c)
                                  lrg-enemy]
                                 [(FriendlyCar? c)
                                  frnd]
                                 [(hlpr-truck? c)
                                  truck]
                                 [else c]))
              (define theX (cond [(small-enemy? c)
                                  (small-enemy-x c)]
                                 [(large-enemy? c)
                                  (large-enemy-x c)]
                                 [(FriendlyCar? c)
                                  (FriendlyCar-x c)]
                                 [(hlpr-truck? c)
                                  (hlpr-truck-x c)]
                                 [else c]))
              (define theY (cond [(small-enemy? c)
                                  (small-enemy-y c)]
                                 [(large-enemy? c)
                                  (large-enemy-y c)]
                                 [(FriendlyCar? c)
                                  (FriendlyCar-y c)]
                                 [(hlpr-truck? c)
                                  (hlpr-truck-y c)]
                                 [else c])))
        (if (and (car? c)
                 (touching? (compute-ltrb sx sy spy-car)
                            (compute-ltrb theX theY cIMG)))
            (cond [(and (>= sx theX) (<= sy theY))
                   (bounce-down (bounce-left c))]
                  [(and (>= sx theX) (>= sy theY))
                   (bounce-up (bounce-left c))]
                  [(and (<= sx theX) (<= sy theY))
                   (bounce-down (bounce-right c))]
                  [(and (<= sx theX) (>= sy theY))
                   (bounce-up (bounce-right c))]
                  [else c])
            c))))

;; same-car?: car car --> Boolean
;; determines if they are the same car
(define (same-car? c1 c2)
  (or
   (and (small-enemy? c1) (small-enemy? c2)
        (= (small-enemy-x c1) (small-enemy-x c2))
        (= (small-enemy-y c1) (small-enemy-y c2))
        (= (small-enemy-vel c1) (small-enemy-vel c2))
        (= (small-enemy-xvel c1) (small-enemy-xvel c2)))
   
   (and (FriendlyCar? c1) (FriendlyCar? c2)
        (= (FriendlyCar-x c1) (FriendlyCar-x c2))
        (= (FriendlyCar-y c1) (FriendlyCar-y c2))
        (= (FriendlyCar-vel c1) (FriendlyCar-vel c2)))
   (and (hlpr-truck? c1) (hlpr-truck? c2))
   (and (spy? c1) (spy? c2))))


;; collision-car: object object --> object
;; bounces 1st car accordingto its position in relationship to 2nd car's pos.
(define (collision-car c1 c2)
  (local ((define c1IMG (cond [(small-enemy? c1)
                               sml-enemy]
                              [(large-enemy? c1)
                               lrg-enemy]
                              [(FriendlyCar? c1)
                               frnd]
                              [(hlpr-truck? c1)
                               truck]
                              [else c1]))
          (define c2IMG (cond [(small-enemy? c2)
                               sml-enemy]
                              [(large-enemy? c2)
                               lrg-enemy]
                              [(FriendlyCar? c2)
                               frnd]
                              [(hlpr-truck? c2)
                               truck]
                              [else c2]))
          (define c1X (cond [(small-enemy? c1)
                             (small-enemy-x c1)]
                            [(large-enemy? c1)
                             (large-enemy-x c1)]
                            [(FriendlyCar? c1)
                             (FriendlyCar-x c1)]
                            [(hlpr-truck? c1)
                             (hlpr-truck-x c1)]
                            [else c1]))
          (define c1Y (cond [(small-enemy? c1)
                             (small-enemy-x c1)]
                            [(large-enemy? c1)
                             (large-enemy-x c1)]
                            [(FriendlyCar? c1)
                             (FriendlyCar-x c1)]
                            [(hlpr-truck? c1)
                             (hlpr-truck-x c1)]
                            [else c1]))
          (define c2X (cond [(small-enemy? c2)
                             (small-enemy-x c2)]
                            [(large-enemy? c2)
                             (large-enemy-x c2)]
                            [(FriendlyCar? c2)
                             (FriendlyCar-x c2)]
                            [(hlpr-truck? c2)
                             (hlpr-truck-x c2)]
                            [else c2]))
          (define c2Y (cond [(small-enemy? c2)
                             (small-enemy-y c2)]
                            [(large-enemy? c2)
                             (large-enemy-y c2)]
                            [(FriendlyCar? c2)
                             (FriendlyCar-y c2)]
                            [(hlpr-truck? c2)
                             (hlpr-truck-y c2)]
                            [else c2])))
    (if (and (car? c1) (car? c2) (not (same-car? c1 c2))
             (touching? (compute-ltrb c1X c1Y c1IMG)
                        (compute-ltrb c2X c2Y c2IMG)))
        (cond [(and (>= c1X c2X) (<= c1Y c2Y))
               (bounce-down (bounce-left c1))]
              [(and (>= c1X c2X) (>= c1Y c2Y))
               (bounce-up (bounce-left c1))]
              [(and (<= c1X c2X) (<= c1Y c2Y))
               (bounce-down (bounce-right c1))]
              [(and (<= c1X c2X) (>= c1Y c2Y))
               (bounce-up (bounce-right c1))])
        c1)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                            
;                        ;                   
;   ;   ;                ;                   
;   ;   ;                ;                   
;   ;   ;   ;;;    ;;;   ;  ;   ;   ;  ;;;;  
;   ;   ;  ;; ;;  ;; ;;  ;  ;   ;   ;  ;; ;; 
;   ;;;;;  ;   ;  ;   ;  ; ;    ;   ;  ;   ; 
;   ;   ;  ;   ;  ;   ;  ;;;    ;   ;  ;   ; 
;   ;   ;  ;   ;  ;   ;  ; ;    ;   ;  ;   ; 
;   ;   ;  ;; ;;  ;; ;;  ;  ;   ;   ;  ;; ;; 
;   ;   ;   ;;;    ;;;   ;   ;   ;;;;  ;;;;  
;                                      ;     
;                                      ;     
;                                      ;     

(define (main shg)
  (big-bang shg
            [on-tick handle-tick]
            [on-key handle-key]
            [to-draw render]))
