;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname SpyHunter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f ())))
(require 2htdp/image)
(require 2htdp/universe)
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
(define START-VEL 30)

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
(define trailer (rectangle (* 1/20 W) (* 1/12 H) 'solid 'darkred))
(define connector (rectangle (* 1/100 W) (* 1/180 H) 'solid 'firebrick))
(define nose (above (rectangle (* 1/25 W) (* 1/130 H) 'solid 'red)
                    (rectangle (* 1/20 W) (* 1/25 H) 'solid 'darkred)))
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
(define-struct small-enemy [x y vel])
;; variables are same as FriendlyCar struct

;; a large-enemy is a 
;; (make-large-enemy Num Num Nat)
(define-struct large-enemy [x y vel])

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
                   (make-small-enemy 300 790 2)
                   (make-large-enemy 300 200 2)
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
;; (make-gameover Image Nat)

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
   - place friendly cars offscreen
   - place enemy cars offscreen
   - place helpertrucks offscreen
   - move everything
   - collisions

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
        [(gameover? sg) (make-splash splash-image)] ;; on any-key goes to splash
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
;; Tick handler!


















