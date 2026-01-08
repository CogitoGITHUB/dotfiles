#!/usr/bin/env bash

# Scientific Mapping NixOS Installation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔬 Scientific Mapping NixOS Installation${NC}"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}❌ This script should not be run as root${NC}"
    echo -e "${YELLOW}⚠️ Please run as a regular user and add to your configuration${NC}"
    exit 1
fi

# Installation directory
INSTALL_DIR="$HOME/.config/nixos"
SCIENTIFIC_MAPPING_CONFIG_DIR="$HOME/.config/nixos/scientific-mapping"

echo -e "${BLUE}📦 Creating NixOS configuration...${NC}"

# Create directory structure
mkdir -p "$INSTALL_DIR"
mkdir -p "$SCIENTIFIC_MAPPING_CONFIG_DIR"

# Copy configuration files
echo -e "${GREEN}✓ Creating configuration files...${NC}"

# Copy NixOS configuration
cat > "$SCIENTIFIC_MAPPING_CONFIG_DIR/default.nix" << 'EOF'
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core Scientific Mapping Dependencies
    emacs
    sqlite
    git
    
    # AI Runtime Dependencies
    nodejs_22
    docker
    curl
    wget
    ripgrep
    
    # System Utilities
    coreutils
    findutils
    gnutar
    gnugrep
    gnumake
    
    # Development Tools
    python311
    python311Packages.pip
    gcc
    gnumake
    
    # Network Tools
    netcat-openbsd
    nmap
    
    # Archive Tools
    unzip
    zip
  ];

  # Home Manager Configuration
  home-manager.users.asdf = {
    homeDirectory = "/home/asdf";
    packages = with pkgs; [
      # Scientific Mapping Development Environment
      emacs
      git
      sqlite
      
      # AI/LLM Tools
      nodejs_22
      python311
      python311Packages.pip
      
      # Command Line Tools
      ripgrep
      fd
      bat
      exa
      
      # Build Tools
      gnumake
      gcc
      cmake
      
      # Network Tools
      curl
      wget
      
      # Archive Tools
      unzip
      zip
      p7zip
    ];
    
    # Emacs Configuration
    programs.emacs = {
      enable = true;
      defaultEditor = true;
    };
    
    # Environment Variables for Scientific Mapping
    home.sessionVariables = {
      # Scientific Mapping Configuration
      SCIENTIFIC_MAPPING_CONFIG = "$SCIENTIFIC_MAPPING_CONFIG_DIR";
      SCIENTIFIC_MAPPING_DOCUMENTS_DIR = "/home/asdf/scientific-documents";
      SCIENTIFIC_MAPPING_NOTES_DIR = "/home/asdf/scientific-notes";
      SCIENTIFIC_MAPPING_REFERENCES_DIR = "/home/asdf/scientific-references";
      
      # AI Runtime Configuration
      OLLAMA_HOST = "127.0.0.1";
      OLLAMA_PORT = "11434";
      OPENAI_API_KEY_ENV = "";
      ANTHROPIC_API_KEY_ENV = "";
      
      # Development Environment
      EMACS_DEV_MODE = "false";
      DEBUG_SCIENTIFIC_MAPPING = "false";
      
      # PATH Additions
      PATH = [
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
        "$HOME/.npm-global/bin"
        "/run/current-user/sw/bin"
      ];
    };
  };

  # Optional: Scientific Mapping Service (uncomment if needed)
  # services.scientific-mapping = {
  #   description = "Scientific Mapping MCP Server";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network-online.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.emacs}/bin/emacs --fg-daemon";
  #     ExecStop = "${pkgs.procps}/bin/killall emacs";
  #     Restart = "on-failure";
  #     RestartSec = 10;
  #   };
  # };
}
EOF

# Copy specialized configurations
cat > "$SCIENTIFIC_MAPPING_CONFIG_DIR/scientific-mapping.nix" << 'EOF'
{ config, pkgs, ... }@inputs: {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  }:

{
  # Scientific Mapping Package Definition
  scientific-mapping = pkgs.buildPythonPackage {
    name = "scientific-mapping";
    version = "1.0.0";
    
    src = pkgs.fetchFromGitHub {
      owner = "your-username";
      repo = "scientific-mapping";
      rev = "main";
      hash = "";
    };
    
    propagatedBuildInputs = with pkgs.python311Packages; [
      # Core dependencies
      emacsql
      org-mode
      org-roam
      
      # Web dependencies
      requests
      beautifulsoup4
      flask
      
      # AI/ML dependencies
      transformers
      torch
      numpy
      scipy
      pandas
      
      # Scientific dependencies
      matplotlib
      plotly
      seaborn
      
      # Database dependencies
      psycopg2-binary
    ];
    
    buildInputs = with pkgs; [
      python311
      make
      gcc
    ];
    
    propagatedUserEnvPkgs = with pkgs.python311Packages; [
      scientific-mapping
    ];
    
    # Shell scripts and executables
    passthru.bin = {
      # Scientific Mapping Commands
      scientific-mapping-server = pkgs.writeShellScriptBin "scientific-mapping-server" ''
        #!/usr/bin/env python3
        import sys
        import argparse
        from scientific_mapping.server import main
        
        if __name__ == "__main__":
            parser = argparse.ArgumentParser(description="Scientific Mapping Server")
            args = parser.parse_args()
            sys.exit(main(args.args))
        '';
      
      # Database utilities
      scientific-mapping-db = pkgs.writeShellScriptBin "scientific-mapping-db" ''
        #!/usr/bin/env python3
        import sys
        import argparse
        from scientific_mapping.database import main
        
        if __name__ == "__main__":
            parser = argparse.ArgumentParser(description="Scientific Mapping Database")
            args = parser.parse_args()
            sys.exit(main(args.args))
        '';
      
      # Citation management
      scientific-mapping-cite = pkgs.writeShellScriptBin "scientific-mapping-cite" ''
        #!/usr/bin/env python3
        import sys
        import argparse
        from scientific_mapping.citation import main
        
        if __name__ == "__main__":
            parser = argparse.ArgumentParser(description="Scientific Mapping Citation Manager")
            args = parser.parse_args()
            sys.exit(main(args.args))
        '';
      
      # Visualization tools
      scientific-mapping-viz = pkgs.writeShellScriptBin "scientific-mapping-viz" ''
        #!/usr/bin/env node
        const path = require('path');
        const { main } = require('./dist/main.js');
        
        main(process.argv.slice(2));
        '';
    };
    
    meta = with pkgs.lib; {
      description = "Scientific Knowledge Mapping System with Deep MCP Integration";
      longDescription = ''
        A comprehensive Emacs-based platform for scientific research,
        literature management, and knowledge mapping with advanced AI integration.
        
        Features:
        • Deep Model Context Protocol (MCP) integration
        • AI-powered document analysis and suggestions
        • Real-time cross-document intelligence
        • Intelligent research workflow orchestration
        • Live 3D visualization with AI enhancement
        • Org-based configuration management
        • Profile-based research environments
        • Multi-provider AI support (Ollama, OpenAI, Anthropic)
      '';
      homepage = "https://github.com/your-repo/scientific-mapping";
      license = lib.licenses.gpl3;
      platforms = lib.platforms.linux;
    };
  };
}
EOF

echo -e "${GREEN}✓ Configuration files created${NC}"

# Create startup script
cat > "$HOME/.config/scientific-mapping/start.sh" << 'EOF'
#!/usr/bin/env bash

# Scientific Mapping NixOS Startup Script
# This script initializes the Scientific Mapping environment

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Scientific Mapping NixOS Environment${NC}"
echo -e "${YELLOW}Loading environment...${NC}"

# Source NixOS profile if exists
if [[ -f "/nix/var/nix-profile/profile" ]]; then
    source /nix/var/nix-profile/profile
fi

# Set environment variables
export SCIENTIFIC_MAPPING_CONFIG="/home/asdf/.config/nixos/scientific-mapping"
export SCIENTIFIC_MAPPING_DOCUMENTS_DIR="/home/asdf/scientific-documents"
export SCIENTIFIC_MAPPING_NOTES_DIR="/home/asdf/scientific-notes" 
export SCIENTIFIC_MAPPING_REFERENCES_DIR="/home/asdf/scientific-references"

# AI Runtime Environment
export OLLAMA_HOST="127.0.0.1"
export OLLAMA_PORT="11434"
export PATH="$HOME/.nix-profile/bin:$PATH"

# Start services if needed
if command -v systemctl >/dev/null 2>&1; then
    if systemctl --user is-active ollama 2>/dev/null; then
        echo -e "${GREEN}✓ Ollama service running${NC}"
    else
        echo -e "${YELLOW}⚠️ Starting Ollama service...${NC}"
        systemctl --user start ollama
    fi
else
    echo -e "${YELLOW}⚠️ Systemd not available, please start Ollama manually${NC}"
fi

echo -e "${GREEN}✓ Environment initialized${NC}"
echo -e "${BLUE}📊 Scientific Mapping is ready!${NC}"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo -e "  scientific-mapping-start    - Start the application"
echo -e "  scientific-mapping-server    - Start the web server"
echo -e "  scientific-mapping-db      - Database management"
echo -e "  scientific-mapping-cite       - Citation management"
echo -e "  scientific-mapping-viz       - 3D visualization"
echo ""
echo -e "${GREEN}🎯 NixOS Scientific Mapping Environment Active${NC}"
EOF

chmod +x "$HOME/.config/scientific-mapping/start.sh"

echo -e "${GREEN}✓ Startup script created${NC}"

# Create home-manager configuration
if command -v home-manager >/dev/null 2>&1; then
    echo -e "${BLUE}🏠 Configuring Home Manager...${NC}"
    
    # Backup current configuration
    home-manager backup
    echo -e "${YELLOW}⚠️ If asked to replace configuration, answer 'y'${NC}"
    
    # Apply new configuration
    home-manager switch --flake "$SCIENTIFIC_MAPPING_CONFIG_DIR/flake.nix"
    echo -e "${GREEN}✓ Home Manager configured${NC}"
else
    echo -e "${YELLOW}⚠️ Home Manager not available${NC}"
    echo -e "${YELLOW}📦 Please install Home Manager first:"
    echo -e "${NC}    curl -L https://nixos.org/nix/install | sh -s -- -"
    echo -e "${NC}    OR use your distribution's package manager"
fi

echo -e "${BLUE}🔬 Installation Complete!${NC}"
echo ""
echo -e "${GREEN}📚 Next Steps:${NC}"
echo -e "${NC}1. Reboot or run:  source ~/.nix-profile/profile"
echo -e "${NC}2. Run:    ~/Scientific-Mapping/start.sh"
echo -e "${NC}3. Configure your AI providers (Ollama, OpenAI, etc.)"
echo ""
echo -e "${YELLOW}📖 Configuration files created in: $SCIENTIFIC_MAPPING_CONFIG_DIR${NC}"
echo -e "${YELLOW}🎯 Scientific Mapping NixOS environment ready!${NC}"
EOF

chmod +x "$HOME/.config/scientific-mapping/install.sh"

# Run the installation
exec "$HOME/.config/scientific-mapping/install.sh"