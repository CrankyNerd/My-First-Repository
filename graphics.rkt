#lang racket

#|
Graphical constants — images of cars and such — used in the game.
|#

(require "constants.rkt"
         2htdp/image)

(provide BG
         plain-bg
         splash-image
         gameover-image
         os-image
         ss-image
         mini-ss-image
         spy-car
         frnd
         mini-car
         truck
         sml-enemy
         lrg-enemy
         bullet
         player-shot)
;; TODO check that the above list includes all the graphics you need
;; in the main file and none that you don't

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
