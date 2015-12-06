(define find (lambda (x y)
                     (cond ((null? y) #f)
                           ((cons? y)
                                  (if (eq? (car y) x) #t (find x (cdr y)))))))
