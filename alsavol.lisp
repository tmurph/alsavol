;;; alsavol.lisp --- simple StumpWM module to interact with ALSA

;;; Copyright (C) 2014 Trevor Murphy

;;; This program is free software: you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by the Free
;;; Software Foundation, either version 3 of the License, or (at your option)
;;; any later version.

;;; This program is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.

;;; You should have received a copy of the GNU General Public License along
;;; with this program.  If not, see <http://www.gnu.org/licenses/>.

;;;; Commentary:

;;; Usage
;;; -----

;;; The following commands are defined:

;;; + alsavol-vol+
;;; + alsavol-vol-
;;; + alsavol-toggle-mute

;;; For this to work you probably want to assign appropriate keys in your
;;; `.stumpwmrc'. For example:

;;;   (define-key *top-map*
;;;               (kbd "XF86AudioRaiseVolume")
;;;               "alsavol-vol+")

;;;; Code:

(defpackage #:alsavol
  (:use #:cl))

(in-package #:alsavol)

(defvar *alsavol-control* "Master"
  "The control used when changing the volume or muting a sink")

(defun volume (&optional (control *alsavol-control*))
  (ppcre:register-groups-bind (volume)
      ("\\[(.*?)%\\]"
       (stumpwm:run-shell-command
        (format nil "amixer get ~a" control) t))
    (when volume
      (parse-integer volume))))

(defun mutep (&optional (control *alsavol-control*))
  (ppcre:register-groups-bind (mutep)
      ("\\[(on|off)\\]"
       (stumpwm:run-shell-command
        (format nil "amixer get ~a" control) t))
    (when mutep
      (string= "off" mutep))))

(defun set-volume (percentage &optional (change 0))
  (let ((sign (cond
                ((> change 0) "+")
                ((< change 0) "-")
                (t ""))))
    (stumpwm:run-shell-command
     (format nil "amixer set ~a ~a%~a"
             *alsavol-control* percentage sign))))

(defun toggle-mute-1 (&optional (control *alsavol-control*))
  (stumpwm:run-shell-command
   (format nil "amixer set ~a toggle" control)))

(defun make-volume-bar (percent)
  (format nil "^B~3d%^b [^[^7*~a^]]"
          percent (stumpwm::bar percent 50 #\# #\:)))

(defun show-volume-bar (&optional (control *alsavol-control*))
  (funcall (if (interactivep)
               #'stumpwm::message-no-timeout
               #'stumpwm:message)
           (format nil "~a ~:[OPEN~;MUTED~]~%~a"
                   control (mutep control)
                   (make-volume-bar (volume control)))))

(defun volume-up (percentage)
  (set-volume percentage +1)
  (show-volume-bar))

(defun volume-down (percentage)
  (set-volume percentage -1)
  (show-volume-bar))

(defun toggle-mute ()
  (toggle-mute-1)
  (show-volume-bar))

;;;; Commands

(stumpwm:defcommand alsavol-vol+ () ()
  "Increase the volume by ~5%."
  (volume-up 5))

(stumpwm:defcommand alsavol-vol- () ()
  "Decrease the volume by ~5%."
  (volume-down 5))

(stumpwm:defcommand alsavol-toggle-mute () ()
  "Toggle mute."
  (toggle-mute))
