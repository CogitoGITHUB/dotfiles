;;;; Keyd - keyboard remapping daemon
(define-public keyd (module-ref (resolve-interface '(gnu packages linux)) 'keyd))

(define keyd-defaults.conf
  (plain-file "defaults.conf"
   "[main]
# Dvorak layout mappings
# Left hand
a = b
b = x
c = j
d = e
e = .
f = i
g = ,
h = n
i = u
j = m
k = y
l = ;

# Right hand
n = k
o = i
p = o
q = '
r = p
s = o
t = r
u = y
v = g
w = ,
x = q
y = f
z = ;

# Special keys
' = [

backspace = backspace
space = space
enter = enter
tab = tab
escape = escape

# Modifiers
left_shift = left_shift
right_shift = right_shift
left_ctrl = left_ctrl
right_ctrl = right_ctrl
left_alt = left_alt
right_alt = right_alt
left_meta = left_meta
right_meta = right_meta

# Navigation
up = up
down = down
left = left
right = right

# Punctuation that changed in Dvorak
; = [
. = e
, = w
/ = z
- = [
= = =
[ = p
] = x

# Caps lock -> backspace
capslock = backspace
"))

(define (keyd-shepherd-service config)
  (list (shepherd-service
         (documentation "literativeos-keyd - keyboard remapping daemon")
         (provision '(literativeos-keyd))
         (respawn? #t)
         (start #~(make-forkexec-constructor
                   (list (string-append #$keyd "/bin/keyd"))))
         (stop #~(make-kill-destructor)))))

(define-public literativeos-keyd-service-type
  (service-type
   (name 'literativeos-keyd)
   (extensions
    (list (service-extension shepherd-root-service-type keyd-shepherd-service)
          (service-extension etc-service-type
                            (lambda (config)
                              `(("keyd/defaults.conf"
                                 ,keyd-defaults.conf))))))
   (default-value '())
   (description "literativeos-keyd keyboard remapping daemon")))
