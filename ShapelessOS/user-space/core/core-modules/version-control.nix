{ config, pkgs, ... }:

{
  # System packages for version control
  environment.systemPackages = with pkgs; [
    git
    gh       # GitHub CLI
    lazygit
    ghq      # optional, Git repository manager
    tig      # optional, ncurses Git viewer
    gh-pr    # optional, GitHub pull request CLI if installed separately
    hub      # optional, classic GitHub CLI wrapper
  ];

  # Git global configuration
  programs.git = {
    enable = true;
    userName = "CogitoGITHUB";
    userEmail = "vlasceanupaulinoionut@gmail.com";
    editor = pkgs.neovim;  # or pkgs.vim or pkgs.emacs
    signing.key = "auto";  # enable automatic commit signing if GPG key available
  };

  # Optional: setup global Git aliases
  environment.etc."gitconfig".text = ''
    [alias]
      st = status
      co = checkout
      ci = commit
      br = branch
      lg = log --graph --all --decorate --oneline
  '';
}
