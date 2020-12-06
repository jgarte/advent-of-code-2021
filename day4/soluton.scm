(define input-data "
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
")

; Utility functions
(define (split-list-by l el)
  (define (split l el splitted-part already-splitted)
    (cond ((null? l)
            (cons (reverse splitted-part) already-splitted))
          ((eq? (car l) el)
            (split (cdr l) el '() (cons (reverse splitted-part) already-splitted)))
          (else
            (split (cdr l) el (cons (car l) splitted-part) already-splitted))))
  (reverse (split l el '() '())))

(define (some? predicate l)
  (not
    (every?
      (lambda (x)
        (not
          (predicate x)))
      l)))

(define (every? predicate l)
  (cond ((null? l) #t)
        ((not (predicate (car l))) #f)
        (else (every? predicate (cdr l)))))

; Parser
(define (parse-passports input)
  (let ((passport-inputs (split-list-by (split-list-by input '#\newline) '())))
    (map
      parse-passport
      (filter
        (lambda (p) (> (length p) 0))
        passport-inputs))))

(define (parse-passport passport-input)
  (let ((passport-field-inputs
          (map
            (lambda (l) (split-list-by l '#\space))
            passport-input)))
    (let ((passport-fields (map parse-passport-field (apply append passport-field-inputs))))
      (make-passport passport-fields))))

(define (parse-passport-field passport-field-input)
  (let ((parts (split-list-by passport-field-input '#\:)))
    (make-passport-field
      (list->string (car parts))
      (list->string (cadr parts)))))

; Passport definition
(define (make-passport-field name value)
  (define (dispatch op)
    (cond ((eq? op 'name) name)
          ((eq? op 'value) value)
          ((eq? op 'as-list) (list name value))
          (else (error "Unsupported password-field op:" op))))
  dispatch
)

(define (make-passport passport-fields)
  (define required-field-names (list 'byr 'iyr 'eyr 'hgt 'hcl 'ecl 'pid))
  (define (has-field field-name)
    (some?
      (lambda (field)
        (equal? (field 'name) (symbol->string field-name)))
      passport-fields))
  (define (is-valid)
    (every?
      has-field
      required-field-names))
  (define as-list
    (map
      (lambda (f) (f 'as-list))
      passport-fields))
  (define (dispatch op)
    (cond ((eq? op 'is-valid) is-valid)
          ((eq? op 'has-field) has-field)
          ((eq? op 'as-list) as-list)
          (else (error "Unsupported password-field op:" op))))
  dispatch
)

(define passports
  (parse-passports
    (string->list input-data)))

(define passport-validity
  (map
    (lambda (p) ((p 'is-valid)))
    passports))

(define valid-passports-number
  (length
    (filter
      (lambda (x) x)
      passport-validity)))

(newline)
(display "Part 1:")
(newline)
(display valid-passports-number)
(newline)

; car - valid (all fields)
; cadr - invalid (missing hgt)
; caddr - valid (missing cid)
; cadddr - invalid (missing cid, byr)