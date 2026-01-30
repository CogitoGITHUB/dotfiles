{ config, pkgs, ... }:
{
  # System packages for version control
  environment.systemPackages = with pkgs; [
    git
    gh       # GitHub CLI
    lazygit
    ghq      # optional, Git repository manager
    tig      # optional, ncurses Git viewer
    hub      # optional, classic GitHub CLI wrapper
  ];
  
  # Git global configuration
  programs.git = {
    enable = true;
    config = {
      user.name = "CogitoGITHUB";
      user.email = "vlasceanupaulinoionut@gmail.com";
      core.editor = "nvim";
      
      # Remove or comment out these lines:
      # commit.gpgsign = true;
      # gpg.format = "ssh";
      # user.signingkey = "~/.ssh/id_ed25519.pub";
      
      # Aliases
      alias = {
        st = "status";
        co = "checkout";
        ci = "commit";
        br = "branch";
        lg = "log --graph --all --decorate --oneline";
      };
    };
  };
}
