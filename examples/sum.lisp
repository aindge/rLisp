(define sum (lambda (x)
            (cond ((number? x) x)
                  ((or (null? x) (not (list? x))) 0)
                  (else (+ (sum (car x)) (sum(cdr x)))))))