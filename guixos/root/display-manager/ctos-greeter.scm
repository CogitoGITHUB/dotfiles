;; ctOS Greeter Service for Guix System
;; Uses the built-in greetd-service-type and configures it for ctOS

(use-modules (guix gexp)
             (gnu services)
             (gnu services desktop)
             (gnu services base))

(define %ctos-greeter-files-directory "/opt/ctos")

(define (ctos-greeter-etc-service config)
  (let ((user (or (assoc-ref config 'user) "aoeu"))
        (monitor (or (assoc-ref config 'monitor) "DP-1")))
    `(("greetd/config.toml"
       ,(plain-file "greetd-config.toml"
         (string-append "\
[terminal]
vt = 1

[default_session]
command = \"env CTOS_MODE=greetd CTOS_USER=" user " CTOS_MONITOR=" monitor " cage -ds -- quickshell --path " %ctos-greeter-files-directory "/greeter.qml\"
user = \"greeter\"
")))
     ("ctos/greeter.config.json"
      ,(plain-file "greeter.config.json"
        (string-append "{
  \"$schema\": \"https://raw.githubusercontent.com/TSM-061/ctOS/main/schema/greeter.schema.json\",
  \"user\": \"" user "\",
  \"monitor\": \"" monitor "\",
  \"fontFamily\": \"JetBrains Mono\",
  \"fakeIdentity\": {
    \"id\": \"XYZ-843\",
    \"class\": \"L5_PROV\",
    \"fullName\": \"User\"
  },
  \"fakeStatus\": {
    \"env\": \"Workstation\",
    \"node\": \"0.0.0.0\"
  },
  \"modes\": {
    \"greetd\": {
      \"animations\": \"all\",
      \"exit\": [\"killall\", \"cage\"],
      \"launch\": [\"Hyprland\"]
    },
    \"lockd\": {
      \"animations\": \"reduced\"
    },
    \"test\": {
      \"animations\": \"all\"
    }
  }
}
"))))))

(define (ctos-greeter-greetd-configuration config)
  (greetd-configuration))

(define ctos-greeter-service-type
  (service-type (name 'ctos-greeter)
                (extensions
                 (list (service-extension etc-service-type
                                          ctos-greeter-etc-service)
                       (service-extension greetd-service-type
                                          ctos-greeter-greetd-configuration)))
                (default-value '(("user" . "aoeu") ("monitor" . "DP-1")))
                (description "ctOS login manager using greetd and quickshell")))
