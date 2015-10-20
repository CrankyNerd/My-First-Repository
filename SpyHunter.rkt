;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname SpyHunter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require 2htdp/image)
(require 2htdp/universe)
#|
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Constant data

-- sound

;;; Images:
-- player's car       ;;DONE
  -crash image
-- helper truck       ;;DONE
  - oil slick icon
  - smoke screen icon
-- small enemy        ;;DONE
  -crash image
-- bullet-proof enemy ;;DONE
  -crash image

-- Background
-- splashscreen
-- gameover

-- Bullet             ;;DONE
-- oil slick
-- smoke screen

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

;; how to make background collisions?

;;; Constant data defined

(define W 600)
(define H 800)

#;(define straight-road (beside (rectangle (* 1/6 W) (* 3 800) 'solid 'green)
                                (rectangle (* 2/3 W) (* 3 800) 'solid 'black)
                                (rectangle (* 1/6 W) (* 3 800) 'solid 'green)))

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

;; an object is one of
;; - FriendlyCar
;; - EnemyCar
;; - hlpr-truck
;; - oilslick
;; - smokescreen

;; a List-of[Objects] (LOO) is one of:
;; empty
;; (cons object empty)

;; a FriendlyCar is a
;; (make-FriendlyCar Nat Num Num)
(define-struct FriendlyCar [vel x y])
;; vel is the car's x velocity and
;; x is the car's x coordinate
;; y is the car's y coordinate

;; an EnemyCar is a 
;; (make-EnemyCar Nat Num Num)
(define-struct EnemyCar [vel x y])
;; variables are same as FriendlyCar struct


;; a hlpr-truck is a
;; (make-hlpr-truck Symbol Nat Num Num)
(define-struct hlpr-truck [gadget vel x y])
;; gadget is a symbol representing which gadget the truck is carrying
;; gadgets --> 'smokescreen 'oilslick

;; shot is a
;; (make-shot Num Num Nat
(define-struct shot [x y vel])
;; where x is the shots x coordinate,
;; x is the shots y coordinate, and
;; vel is the shot's velocity

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;world defintion

;; A SpyGame is a
;; (make-splash Image) or  TODO: make splashscreen
;; (make-shg Nat Nat Nat Nat spy List-of[Object]) or
;; (make-firing-shg Nat Nat Nat spy List-of[Object] List-of[Bullets]) or a 
;; (make-gameover Image Nat)

(define-struct splash [bg])
;; where bg is an image set as the splashscreen

(define-struct shg [lives score spy LOO])
;; where lives is the number of lives a player has left and
;; score is the player's score,
;; LOO is a list of all the objects in the game
;; example shg
(define shg1 (make-shg 3 0 spy1 empty))

(define-struct firing-shg [lives score spy LOO LOB])
;;where lives is the number of lives a player has left and
;; score is the player's score,
;; LOO is a list of all the objects in the game
;; LOB is a list of the players shot

(define-struct gameover [bg score])
;; were bg is the gameover image

;; fun-for-shg: shg --> ?
#; (define (fun-for-shg s)
     (... (shg-lives s) ...
          (shg-score s) ...
          (shg-spy s) ...
          (shg-LOO s) ...))
;; fun-for-firing-shg: firing-shg --> ?
#; (define (fun-for-firing-shg f)
     (... (firing-shg-lives f) ...
          (firing-shg-score f) ...
          (firing-shg-spy f) ...
          (firing-shg-LOO f) ...
          (firing-shg LOB) ...))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|

;;Wishlist

-- key handler     ;; DOES RACKET HAVE SUSTAINED KEY PRESSING???
   - shoot
   - deploy oilslick
   - deploy smokescreen
   - move left
   - move right
   - go forward
   - accelerate

-- draw handler
   - generate background ;; WHERE TO INCLUDE THIS?

-- tick handler
   - AI
   - place friendly cars offscreen
   - place enemy cars offscreen
   - place helpertrucks offscreen

|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Render Handler

;; generate-road: Image --> Image ;; HOW TO REPRESENT ROAD
(define (generate-road img)
  ...)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Key Handler

;; handle-key: key SpyGame --> SpyGame
;; performs a keys proper action to produce the next SpyGame
(define (handle-key sg)
  ...)

;; start-game: key SpyGame --> SpyGame
;; if the SpyGame is a (make-splash ...) it starts the game with a
;; (make-shg ...). if not, then nothing occurs

(define (start-game k sg)
  (if (splash? sg)
      shg1
      sg))



















