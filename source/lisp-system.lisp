;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

(in-package :nyxt)

(define-command list-systems ()
  "List systems available via Quicklisp."
  (let ((buffer (make-internal-buffer :title "*Systems*")))
    (let* ((content
             (markup:markup
              (:style (style buffer))
              (:h1 "Systems")
              (:p "Listing of all available Quicklisp systems.")
              (:body
               (loop for system in (ql:system-list)
                     collect
                        (let ((name (ql-dist:short-description system))
                              (size (format nil "~a" (ql-dist:archive-size (ql-dist:preference-parent system))))
                              (dependencies (format nil "~a" (ql-dist:required-systems system))))
                          (markup:markup (:div
                                          (:h2 name)
                                          (:p "Size: " size)
                                          (:p "Requires: " dependencies)
                                          (:p (:a :class "button"
                                                  :href (lisp-url `(ql:quickload ,name)) "Load"))
                                          (:hr))))))))
           (insert-content (ps:ps (setf (ps:@ document body |innerHTML|)
                                        (ps:lisp content)))))
      (ffi-buffer-evaluate-javascript buffer insert-content))
    (set-current-buffer buffer)
    buffer))

(define-command load-system ()
  "Load a system from Quicklisp."
  (let ((system (prompt-minibuffer
                 :input-prompt "Load system"
                 :suggestion-function (lambda (minibuffer)
                                        (fuzzy-match
                                         (input-buffer minibuffer)
                                         (mapcar #'ql-dist:short-description (ql:system-list))))
                 :must-match-p t)))
    (ql:quickload system)))

(define-command add-distribution ()
  "Add a new Quicklisp distribution."
  (let ((url (prompt-minibuffer
              :input-prompt "New distribution URL"
              :must-match-p nil)))
    (ql-dist:install-dist url :prompt nil)))
