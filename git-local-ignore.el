;;; elisp-local-ignore.el --- add 'local ignore' options to git package

;; Copyright (C) 2016  Sam Preston

;; Author: Sam Preston <jsam@sci.utah.edu>
;; Keywords: vc

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(require 'git)
(require 'f)

(defun git-local-ignore-add ()
  "Add marked file(s) to the local ignore list."
  (interactive)
  (let ((files (git-get-filenames (git-marked-files-state 'unknown))))
    (unless files
      (push (file-relative-name (read-file-name "File to ignore: " nil nil t)) files))
    (dolist (f files) (git-local-ignore-add-file f))
    (git-update-status-files files)
    (git-success-message "Local Ignored" files)
  ))

(defun git-local-ignore-remove ()
  "Remove marked file(s) from the local ignore list."
  (interactive)
  (let ((files (git-get-filenames (git-marked-files-state 'ignored))))
    (unless files
      (push (file-relative-name (read-file-name "File to ignore: " nil nil t)) files))
    (dolist (f files) (git-local-ignore-remove-file f))
    (git-update-status-files files)
    (git-success-message "Local Unignored" files)
  ))

(defun git-local-ignore-add-file (file)
  "Add a file name to the local ignore file for repo."
  (let* ((fullname (expand-file-name file))
         (dir (file-name-directory fullname))
         (repo-dir (git-get-top-dir dir))
         (relname (file-relative-name fullname repo-dir))
         (local-ignore-name (f-join repo-dir ".git" "info" "exclude"))
	 )
    (save-window-excursion
      (set-buffer (find-file-noselect local-ignore-name))
      (goto-char (point-max))
      (unless (zerop (current-column)) (insert "\n"))
      (insert "/" relname "\n")
      (sort-lines nil (point-min) (point-max))
      (save-buffer))
    ))

(defun git-local-ignore-remove-file (file)
  "remove a file name from the local ignore file for repo."
  (let* ((fullname (expand-file-name file))
         (dir (file-name-directory fullname))
         (repo-dir (git-get-top-dir dir))
         (relname (file-relative-name fullname repo-dir))
         (local-ignore-name (f-join repo-dir ".git" "info" "exclude"))
	 )
    (save-window-excursion
      (set-buffer (find-file-noselect local-ignore-name))
      (goto-char (point-min))
      (when
	  (if (re-search-forward (concat "^[/]" relname "[/]?[ ]*$"))
	      ;; delete the line
	      (let ((beg (progn (forward-line 0) (point))))
		(forward-line 1)
		(delete-region beg (point))
		t)
	    ;; error, file not found
	    (message "file not in local ignore: %s" relname)
	    nil
	    )
	(save-buffer)))
    ))

(provide 'git-local-ignore)
;;; elisp-local-ignore.el ends here

