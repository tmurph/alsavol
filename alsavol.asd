;;;; alsavol.asd

(asdf:defsystem #:alsavol
  :description "A simple volume control for StumpWM and ALSA."
  :version "0.1"
  :author "Trevor Murphy <trevor.m.murphy@gmail.com>"
  :license "GPL3"
  :serial t
  :depends-on (#:stumpwm
               #:cl-ppcre)
  :components ((:file "alsavol")))
