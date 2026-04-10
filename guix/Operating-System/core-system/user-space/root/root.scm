(define-module (core-system user-space root root)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services guix)
  #:use-module (gnu services ssh)
  #:use-module (gnu services networking)
  #:use-module (gnu services docker)
  #:use-module (gnu services audio)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services mcron)
  #:use-module (gnu services databases)
  #:use-module (gnu packages databases)
  #:use-module (core-system user-space root services greetd)
  #:use-module (core-system user-space root users users)
  #:use-module (core-system user-space root loaders core)
  #:use-module (core-system user-space root loaders networking)
  #:use-module (core-system user-space root loaders programming-languages)
  #:use-module (core-system user-space root loaders editors)
  #:use-module (core-system user-space root loaders shell)
  #:use-module (core-system user-space root loaders containers)
  #:use-module (core-system user-space root loaders keyboard)
  #:use-module (core-system user-space root loaders terminal)
  #:use-module (core-system user-space root loaders desktop)
  #:use-module (core-system user-space root loaders ai)
  #:use-module (core-system user-space root loaders formatters)
  #:use-module (core-system user-space root loaders lsp)
  #:use-module (core-system user-space root loaders audio)
  #:use-module (core-system user-space root loaders video)
  #:use-module (core-system user-space root loaders image)
  #:use-module (core-system user-space root loaders 3d)
  #:use-module (core-system user-space root loaders security)
  #:use-module (core-system user-space root loaders scheduling)
  #:use-module (core-system user-space root loaders compute)
  #:use-module (core-system user-space root loaders ci)
  #:use-module (core-system user-space root loaders data)
  #:use-module (core-system user-space root loaders guix)
  #:use-module (core-system user-space root loaders monitoring)
  #:use-module (core-system user-space root loaders sandbox)
  #:use-module (core-system user-space root loaders fonts)
  #:use-module (core-system user-space root loaders wayland)
  #:use-module (core-system user-space root loaders password-manager)
  #:use-module (core-system user-space root loaders games)
  #:re-export (users groups sudoers-file setuid-programs)
  #:export (root-system-packages root-system-services))

(define-public root-system-packages
  (append root-core-packages
          root-networking-packages
          root-programming-languages-packages
          root-editors-packages
          root-shell-packages
          root-shell-system-monitor-packages
          root-shell-power-packages
          root-shell-archive-packages
          root-shell-fetch-packages
          root-containers-packages
          root-keyboard-packages
          root-terminal-packages
          root-desktop-packages
          root-ai-packages
          root-formatters-packages
          root-lsp-packages
          root-audio-packages
          root-compute-packages
          root-desktop-video-packages
          root-desktop-image-packages
          root-desktop-3d-packages
          root-desktop-wayland-packages
          root-security-packages
          root-password-manager-packages
          root-games-packages
          root-scheduling-packages
          root-ci-packages
          root-data-packages
          root-guix-packages
          root-monitoring-packages
          sandbox-packages
          font-packages))

(define-public root-system-services
  (append
    (list
     (service openssh-service-type)
     ;; (service sops-secrets-service-type (sops-service-configuration))
     (service greetd-service-type
              (greetd-configuration
               (command "Hyprland --config /home/aoeu/.config/lock-screen/config/greeter.hyprland.conf")
               (user "greeter"))))
    root-networking-services
    root-containers-services
    root-audio-services
    (list (service libvirt-service-type)
          (service virtlog-service-type)
          (service mcron-service-type))
    ;; root-ai-services
    (list (service postgresql-service-type
                   (postgresql-configuration
                    (postgresql postgresql))))
    root-ci-services
    root-monitoring-services
    root-keyboard-services
    root-guix-services
    %base-services))
