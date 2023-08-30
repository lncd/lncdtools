(define-module (gnu packages lncdtools)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download)
  ;#:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages bash))


(define-public lncdtools
   (package
     (name "lncdtools")
     (version "0.0.202307242")
     (source (origin
               (method url-fetch)
               (uri (string-append "https://github.com/lncd/lncdtools/archive/refs/tags/v" version 
                                   ".tar.gz"))
               (sha256
                (base32
                 "0whdz2vqkz4djmk21l79m10w7zln13kqkf3isgbccryl6i00ar4d"))))
     (inputs (list perl bash))
     (build-system copy-build-system)
     (arguments
     '(#:install-plan
       '(("./" "bin/" #:exclude ("dist" "docs" "src" "t" "Makefile" "Dockerfile" "mkdocs.yaml" "README.md")))))
     (synopsis "Suit of neuroimaging companion tools for shell and make")
     (description "A suit of shell scripting, GNU Make, and general neuroimaging companion tools developed in the Laboratory of NeuroCognitive Development.")
     (home-page "https://github.com/lncd/lncdtools")
     (license gpl3+)))

lncdtools
