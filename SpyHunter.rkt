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






























