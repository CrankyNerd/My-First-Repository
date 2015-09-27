;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname SpyHunter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require 2htdp/image)
(require 2htdp/universe)
#|
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Constant data

-- sound

;;; Images:
-- player's car
  -crash image
-- helper truck
  - mini oil slick
  - mini smoke screen
-- small enemy
  -crash image
-- bullet-proof enemy
  -crash image
-- gun enemy
  -crash image

-- Background
-- splashscreen
-- gameover screen

-- Bullet
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
-- time of run

-- time left on oil slick (when oil slick activated, countdown starts. and it
        stops when oil slick deactivated)
-- difficulty

;;; Velocities
-- bullet velocity
-- enemy velocity
-- velocity of the background (because of the player's car)
-- velocity of helper truck

|#

;; how to make background collisions?

;;; Constant data defined

(define W 600)
(define H 800)

(define straight-road (beside (rectangle (* 1/6 W) (* 3 800) 'solid 'green)
                              (rectangle (* 2/3 W) (* 3 800) 'solid 'black)
                              (rectangle (* 1/6 W) (* 3 800) 'solid 'green)))
;; BG for now. need to make curvy road images and place them above straight-road
(define BG straight-road)

;; spy car -- BASE POS. OF STRIPES + ROOF OFF W AND H
(define spy-body (rectangle (* 1/20 W) (* 1/15 H) 'solid 'burlywood))
(define spy-roof (rectangle (* 1/30 W) (* 1/60 H) 'solid 'moccasin))
(define spy-stripes (beside(rectangle (* 1/80 W) (* 1/45 H) 'solid 'blue)
                           (empty-scene (* 1/80 W) 0)
                           (rectangle (* 1/80 W) (* 1/45 H) 'solid 'blue)))
(define spy (place-image spy-stripes 15 15
                         (place-image spy-roof 15 35 spy-body)))

;; friendly car
; uses the same code as spy, but with different colors.
(define frnd (place-image (beside(rectangle (* 1/80 W) (* 1/45 H)
                                            'solid 'black)
                                 (empty-scene (* 1/80 W) 0)
                                 (rectangle (* 1/80 W) (* 1/45 H)
                                            'solid 'black))
                          15 15
                          (place-image
                           (rectangle (* 1/30 W) (* 1/60 H) 'solid 'firebrick)
                           15 35
                           (rectangle (* 1/20 W) (* 1/15 H) 'solid 'darkred))
                          ))
;; helper truck
(define trailer (rectangle (* 1/20 W) (* 1/12 H) 'solid 'darkred))
(define connector (rectangle (* 1/100 W) (* 1/180 H) 'solid 'firebrick))
(define nose (above (rectangle (* 1/25 W) (* 1/130 H) 'solid 'red)
                    (rectangle (* 1/20 W) (* 1/25 H) 'solid 'darkred)))
(define truck (above nose connector trailer))

































