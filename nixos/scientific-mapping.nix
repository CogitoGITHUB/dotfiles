{ pkgs, lib, ... }@inputs: nixpkgs 
let
  system = "x86_64-linux";
  
in
{
  environment.systemPackages = with pkgs; [
    # Core Scientific Mapping
    emacs
    git
    sqlite
    nodejs_22
    
    # Required for deep MCP integration
    curl
    wget
    ripgrep
    
    # AI Runtime Dependencies  
    docker
    podman
    
    # System Utilities
    coreutils
    findutils
    gnugrep
    gnutar
    
    # Development Tools
    python311
    python311Packages.pip
    gcc
    gnumake
    
    # Terminal and Shell
    nushell
    fish
    
    # Text Processing
    ripgrep
    jq
    
    # Network Tools
    netcat-openbsd
    nmap
    
    # Archive Tools
    unzip
    zip
    
    # Optional GUI Components
    gnome.gtk
    gsettings-desktop-schemas
  ];
  
  # Scientific Mapping Emacs Configuration
  environment.sessionVariables = {
    # Emacs Configuration Directory
    "SCIENTIFIC_MAPPING_CONFIG" = "/home/asdf/.config/emacs/scientific-mapping";
    
    # Configuration Files
    "SCIENTIFIC_CONFIG_ORG" = "/home/asdf/.config/nixos/scientific-mapping-config.org";
    "MCP_CONFIG_ORG" = "/home/asdf/.config/nixos/scientific-mapping-mcp-config.org";
    "WORKFLOW_CONFIG_ORG" = "/home/asdf/.config/nixos/scientific-mapping-workflow-config.org";
    
    # Research Directories
    "SCIENTIFIC_DOCUMENTS_DIR" = "/home/asdf/scientific-documents";
    "SCIENTIFIC_NOTES_DIR" = "/home/asdf/scientific-notes";
    "SCIENTIFIC_REFERENCES_DIR" = "/home/asdf/scientific-references";
    
    # AI Runtime Configuration
    "OLLAMA_HOST" = "127.0.0.1";
    "OLLAMA_PORT" = "11434";
    "OPENAI_API_KEY_ENV" = "";
    "ANTHROPIC_API_KEY_ENV" = "";
    
    # MCP Configuration
    "MCP_ENABLED" = "true";
    "MCP_AUTO_SYNC" = "true"; 
    "MCP_AI_ANALYSIS" = "true";
    "MCP_REALTIME_SYNC" = "true";
    "MCP_ALLOWED_DIRS" = "/home/asdf/scientific-documents/,/home/asdf/.config/emacs/scientific-mapping/";
    
    # Development Environment
    "EMACS_DEV_MODE" = "false";
    "DEBUG_SCIENTIFIC_MAPPING" = "false";
  };
  
  # Home Manager Configuration
  home-manager.users.asdf = {
    homeDirectory = "/home/asdf";
    stateVersion = "24.05";
    
    packages = with pkgs; [
      # Scientific Mapping Core
      (pkgs.writeTextBin {
        name = "scientific-mapping-launcher";
        text = ''
          #!/usr/bin/env nix-shell
          
          # Scientific Mapping Environment Variables
          export SCIENTIFIC_MAPPING_CONFIG="/home/asdf/.config/emacs/scientific-mapping"
          export SCIENTIFIC_DOCUMENTS_DIR="/home/asdf/scientific-documents"
          export SCIENTIFIC_NOTES_DIR="/home/asdf/scientific-notes"
          export SCIENTIFIC_REFERENCES_DIR="/home/asdf/scientific-references"
          
          # AI Runtime Configuration
          export OLLAMA_HOST="127.0.0.1"
          export OLLAMA_PORT="11434"
          
          # MCP Configuration
          export MCP_ENABLED="true"
          export MCP_AUTO_SYNC="true"
          export MCP_AI_ANALYSIS="true"
          export MCP_REALTIME_SYNC="true"
          
          # Development
          export EMACS_DEV_MODE="false"
          export DEBUG_SCIENTIFIC_MAPPING="false"
          
          # Initialize Emacs with Scientific Mapping
          exec ${pkgs.emacs}/bin/emacs --eval "
          ;; Load Scientific Mapping
          (load-file \"$SCIENTIFIC_MAPPING_CONFIG/scientific-mapping.el\")
          
          ;; Initialize Enhanced Configuration System
          (when (require 'scientific-mapping-config nil t)
            (scientific-mapping-config-install))
          
          ;; Start Scientific Mapping with Deep MCP Integration
          (when (require 'scientific-mapping nil t)
            (scientific-mapping-start))
            
          ;; Initialize Real-time Features
          (when (require 'mcp-realtime nil t)
            (mcp-realtime-enable))
            
          ;; Enable Smart Suggestions  
          (when (require 'mcp-smart-suggestions nil t)
            (mcp-smart-suggestions-enable))
            
          ;; Enable Live Visualization
          (when (require 'viz-mcp-enhanced nil t)
            (viz-mcp-enable-live-enhancements))
            
          ;; Initialize MCP System
          (when (require 'scientific-mapping-mcp-initialize nil t)
            (scientific-mapping-mcp-initialize))
            
          ;; Enable Configuration Menu
          (when (require 'scientific-mapping-config nil t)
            (message \"🎉 Scientific Mapping with Deep MCP Integration Started!\")
            (message \"📋 Configuration: C-c s C C - Open Config Menu\")
            (message \"🔍 Research: C-c s C s - Semantic Search\")
            (message \"📚 Writing: C-c s C w - Start Writing Session\")
            (message \"📊 Visualize: C-c s C v - Open Visualization\")
            (message \"🚀 Workflow: C-c s C r - Research Session\")
            (message \"🎛️ Dashboard: C-c s C d - Open Dashboard\")
            (message \"🔄 Real-time: C-c s C t - Toggle Real-time Features\")
            (message \"💡 Smart Suggest: C-c s C i - Toggle Smart Suggestions\")
          )
        '';
      })
      
      # Configuration Scripts
      (pkgs.writeTextBin {
        name = "scientific-mapping-config";
        text = ''
          #!/usr/bin/env nix-shell
          export SCIENTIFIC_MAPPING_CONFIG="/home/asdf/.config/emacs/scientific-mapping"
          
          # Create Org-based configuration files
          # Main configuration
          cat > "$SCIENTIFIC_CONFIG_ORG" << 'EOF'
          #+TITLE: Scientific Mapping Configuration
          #+AUTHOR: Scientific Tools Development Team
          #+STARTUP: content
          
          * System Environment
          
          ** Basic Settings
          
          #+begin_src emacs-lisp :tangle config.el
          ;; Core Scientific Mapping Configuration
          (setq scientific-mapping-document-directory "$SCIENTIFIC_DOCUMENTS_DIR")
          (setq scientific-mapping-auto-sync t)
          (setq scientific-mapping-auto-save t)
          
          ;; MCP Integration
          (setq scientific-mapping-mcp-enabled t)
          (setq scientific-mapping-mcp-auto-sync t)
          (setq scientific-mapping-mcp-ai-analysis t)
          (setq scientific-mapping-mcp-allowed-directories 
                '("$SCIENTIFIC_DOCUMENTS_DIR" "$SCIENTIFIC_MAPPING_CONFIG"))
          
          ;; Real-time Features
          (setq mcp-realtime-enabled t)
          (setq mcp-realtime-sync-interval 30)
          (setq mcp-smart-suggestions-enabled t)
          (setq viz-mcp-live-updates t)
          (setq workflow-mcp-auto-orchestrate t)
          (setq dashboard-mcp-widgets-enabled t)
          
          ;; AI Configuration
          (setq scientific-mapping-ai-provider 'ollama)
          (setq scientific-mapping-ai-model "llama3.1:8b")
          (setq scientific-mapping-ai-temperature 0.7)
          
          ;; Visualization Configuration
          (setq scientific-mapping-viz-port 8080)
          (setq scientific-mapping-viz-auto-start t)
          
          ;; Dashboard Configuration
          (setq scientific-mapping-dashboard-enable-mcp-widgets t)
          (setq scientific-mapping-dashboard-auto-refresh-interval 30)
          
          ;; Research Workflow Configuration
          (setq scientific-mapping-workflow-auto-orchestrate t)
          (setq scientific-mapping-workflow-intelligent-scheduling t)
          (setq scientific-mapping-workflow-context-aware-routing t)
          #+end_src
          
          ** Key Bindings for Enhanced Features
          
          #+begin_src emacs-lisp :tangle keybindings.el
          ;; Enhanced key bindings for Scientific Mapping
          
          ;; Configuration Management
          (define-key scientific-mapping-mode-map (kbd "C-c s C C") 'scientific-mapping-config-menu)
          (define-key scientific-mapping-mode-map (kbd "C-c s C r") 'scientific-mapping-config-reload)
          
          ;; Deep MCP Features
          (define-key scientific-mapping-mode-map (kbd "C-c s C m") 'scientific-mapping-mcp-initialize)
          (define-key scientific-mapping-mode-map (kbd "C-c s C s") 'scientific-mapping-mcp-sync-allowed-files)
          (define-key scientific-mapping-mode-map (kbd "C-c s C a") 'scientific-mapping-mcp-analyze-document)
          (define-key scientific-mapping-mode-map (kbd "C-c s C q") 'scientific-mapping-mcp-semantic-search)
          
          ;; Real-time Features
          (define-key scientific-mapping-mode-map (kbd "C-c s C t") 'mcp-realtime-enable)
          (define-key scientific-mapping-mode-map (kbd "C-c s C i") 'mcp-realtime-request-insights)
          (define-key scientific-mapping-mode-map (kbd "C-c s C u") 'mcp-smart-suggestions-enable)
          (define-key scientific-mapping-mode-map (kbd "C-c s C w") 'mcp-smart-suggestions-writing-improvements)
          
          ;; Visualization
          (define-key scientific-mapping-mode-map (kbd "C-c s C v") 'viz-mcp-enable-live-enhancements)
          
          ;; Workflows
          (define-key scientific-mapping-mode-map (kbd "C-c s C r") 'workflow-mcp-research-session)
          (define-key scientific-mapping-mode-map (kbd "C-c s C l") 'scientific-mapping-literature-review-session)
          (define-key scientific-mapping-mode-map (kbd "C-c s C w") 'workflow-mcp-writing-session)
          
          ;; Dashboard
          (define-key scientific-mapping-mode-map (kbd "C-c s C d") 'dashboard-mcp-enable-widgets)
          
          ;; Quick Access
          (define-key scientific-mapping-mode-map (kbd "C-c s S") 'scientific-mapping-start)
          (define-key scientific-mapping-mode-map (kbd "C-c s ?") 'scientific-mapping-help)
          #+end_src
          
          ** Research Workflows
          
          #+begin_src emacs-lisp :tangle workflows.el
          ;; Research workflow automation
          
          ;; Comprehensive Research Session
          (defun comprehensive-research-session (topic)
            "Start comprehensive AI-assisted research session."
            (interactive "sResearch topic: ")
            (workflow-mcp-research-session topic 'comprehensive))
          
          ;; Literature Review Automation
          (defun automated-literature-review (domain)
            "Automate literature review process."
            (interactive "sResearch domain: ")
            (workflow-mcp-literature-review-session domain))
          
          ;; Paper Writing Assistant
          (defun ai-writing-assistant ()
            "AI-powered writing assistant."
            (interactive)
            (mcp-smart-suggestions-enable)
            (mcp-realtime-enable)
            (message "💡 AI Writing Assistant Enabled"))
          #+end_src
          EOF
        '';
        
        # MCP-specific configuration
        cat > "$MCP_CONFIG_ORG" << 'EOF'
        #+TITLE: Scientific Mapping MCP Configuration
        #+AUTHOR: Scientific Tools Development Team
        #+STARTUP: content
          
        * MCP Server Configuration
          
        ** Server Settings
        - **Server**: org-mcp
        - **Host**: 127.0.0.1  
        - **Port**: 3000
        - **Transport**: stdio
        - **Timeout**: 30000ms
        - **Keep-Alive**: true
        
        ** Allowed Directories
        - Scientific Documents: $SCIENTIFIC_DOCUMENTS_DIR
        - Configuration: $SCIENTIFIC_MAPPING_CONFIG
        - Research Notes: $SCIENTIFIC_NOTES_DIR
        - References: $SCIENTIFIC_REFERENCES_DIR
        
        ** Real-time Configuration
        - **Auto-Sync Interval**: 30s
        - **Batch Size**: 100 documents
        - **Cache Size**: 1000 items
        - **Max File Size**: 10MB
        
        ** AI Integration Settings
        - **Provider**: Ollama (default: OpenAI)
        - **Models**: llama3.1:8b, gpt-4, claude-3-sonnet
        - **Max Tokens**: 4000 (context)
        - **Temperature**: 0.7 (creative)
        - **Streaming**: true
        
        ** Security Settings
        - **Write Access**: read-only (default: true)
        - **Require Explicit**: write-actions
        - **Audit Logging**: true
        - **Rate Limiting**: 100 requests/minute
        
        ** Performance Settings
        - **Parallel Processing**: 4 workers
        - **Cache TTL**: 1 hour
        - **Memory Limit**: 2GB
        EOF
        '';
        
        # Workflow configuration
        cat > "$WORKFLOW_CONFIG_ORG" << 'EOF'
        #+TITLE: Scientific Mapping Workflow Configuration
        #+AUTHOR: Scientific Tools Development Team
        #+STARTUP: content
          
        * Research Workflow Automation
        
        ** Phase-Based Workflows
        1. **Discovery Phase**: Document discovery and initial analysis
        2. **Analysis Phase**: Deep document analysis and concept extraction
        3. **Synthesis Phase**: Literature synthesis and gap identification
        4. **Writing Phase**: Structured document creation with AI assistance
        5. **Review Phase**: Document review and quality assurance
        
        ** Automation Rules
        - Auto-save on significant changes (interval: 2 minutes)
        - Auto-citation extraction on document save
        - Auto-concept relationship discovery every 30 minutes
        - Intelligent suggestions based on writing patterns
        - Research gap analysis across entire corpus weekly
        
        ** Integration Points
        - Citation database sync with every save
        - Visualization update every 60 seconds
        - Dashboard refresh every 30 seconds
        - AI analysis queue for batch processing
        
        ** Quality Metrics
        - Citation relevance scoring
        - Document completion tracking
        - Research velocity monitoring
        - AI suggestion effectiveness tracking
        EOF
        '';
        
        # Create launcher script
        chmod +x "$SCIENTIFIC_CONFIG_ORG"
        
        echo "✅ Scientific Mapping Configuration Created"
        echo "📋 Main Config: $SCIENTIFIC_CONFIG_ORG"
        echo "🔗 MCP Config: $MCP_CONFIG_ORG" 
        echo "🚀 Workflow Config: $WORKFLOW_CONFIG_ORG"
        echo ""
        echo "🎯 Quick Start Commands:"
        echo "  scientific-mapping-launcher                    # Launch Scientific Mapping"
        echo "  scientific-mapping-config                      # Open configuration"
        echo ""
        echo "🔍 Key Features:"
        echo "  • Deep MCP integration with real-time AI analysis"
        echo "  • Org-based literate configuration system"
        echo "  • Profile-based research environment management"
        echo "  • Automated workflow orchestration"
        echo "  • Context-aware smart suggestions"
        echo "  • Live 3D visualization with AI enhancement"
        EOF
        '';
      })
      
      # Development Tools
      (pkgs.writeTextBin {
        name = "scientific-mapping-dev";
        text = ''
          #!/usr/bin/env nix-shell
          
          # Development Environment Variables
          export SCIENTIFIC_MAPPING_CONFIG="/home/asdf/.config/emacs/scientific-mapping"
          export EMACS_DEV_MODE="true"
          export DEBUG_SCIENTIFIC_MAPPING="true"
          
          # Development Tools
          echo "🔧 Scientific Mapping Development Environment"
          echo "📁 Config: $SCIENTIFIC_CONFIG"
          echo "🐛 Debug Mode: $DEBUG_SCIENTIFIC_MAPPING"
          echo "📚 Emacs Config: ~/.config/emacs/init.el"
          echo ""
          
          # Development Commands
          echo "🧪 Unit Testing:"
          echo "  emacs --batch --eval '(progn (load-file \"$SCIENTIFIC_MAPPING_CONFIG/scientific-mapping.el\") (ert-run-tests-batch-and-exit))'"
          echo ""
          echo "🔧 Package Testing:"
          echo "  emacs --batch --eval '(progn (load-file \"$SCIENTIFIC_MAPPING_CONFIG/scientific-mapping.el\") (scientific-mapping-test-all-modules))'"
          echo ""
          echo "📊 Performance Testing:"
          echo "  emacs --batch --eval '(progn (load-file \"$SCIENTIFIC_MAPPING_CONFIG/scientific-mapping.el\") (scientific-mapping-benchmark-suite))'"
          echo ""
          echo "🚀 Development Mode Features:"
          echo "  • Hot-reloading on configuration changes"
          echo "  • Debug logging for MCP operations"
          echo "  • Extended AI model testing tools"
          echo "  • Performance profiling enabled"
          echo "  • Integration test suite coverage"
          echo ""
          echo "🎯 Start Development Emacs:"
          echo "  exec ${pkgs.emacs}/bin/emacs --eval '(progn (load-file \"$SCIENTIFIC_MAPPING_CONFIG/scientific-mapping.el\") (scientific-mapping-start) (dev-mode-init))'"
        '';
      })
    ];
    
    # Services for Scientific Mapping
    services = {
      # Ollama AI Service
      ollama = {
        enable = true;
        package = pkgs.ollama;
        
        serviceConfig.ExecStart = "${pkgs.systemd}/bin/systemd-analyze";
        serviceConfig.ExecStop = "${pkgs.systemd}/bin/systemd-analyze";
        
        # Set Ollama environment variables
        environment = {
          "OLLAMA_HOST" = "127.0.0.1";
          "OLLAMA_PORT" = "11434";
          "OLLAMA_MODELS" = "llama3.1:8b,llama3.1:70b,qwen2.5:14b";
          "OLLAMA_KEEP_ALIVE" = "30";
          "OLLAMA_NUM_PARALLEL" = "2";
          "OLLAMA_MAX_QUEUE" = "512";
        };
      };
      
      # Scientific Mapping MCP Server Service
      scientific-mapping-mcp = {
        enable = true;
        description = "Scientific Mapping MCP Server for AI Integration";
        
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.systemd}/bin/systemd-analyze";
          ExecStop = "${pkgs.systemd}/bin/systemd-analyze";
          Restart = "on-failure";
        };
        
        script = ''
          #!/usr/bin/env bash
          
          # Environment Setup
          export SCIENTIFIC_MAPPING_CONFIG="/home/asdf/.config/emacs/scientific-mapping"
          export MCP_CONFIG_PATH="/home/asdf/.config/nixos/scientific-mapping-mcp-config.org"
          export PYTHONPATH="${pkgs.python311}/bin:$PYTHONPATH"
          
          # Service Start
          echo "🚀 Starting Scientific Mapping MCP Server..."
          
          # Check if Ollama is available
          if ! command -v ollama >/dev/null 2>&1; then
            echo "⚠️ Warning: Ollama not found. Please ensure it's installed."
            exit 1
          fi
          
          # Start Ollama in background if not running
          if ! pgrep -x ollama >/dev/null; then
            echo "🤖 Starting Ollama service..."
            systemctl --user start ollama || ollama serve &
            sleep 3
          fi
          
          # Start Scientific Mapping with MCP
          echo "🔗 Initializing Scientific Mapping with MCP..."
          exec emacs --batch --eval "
            (load-file \"$SCIENTIFIC_MAPPING_CONFIG/scientific-mapping.el\")
            
            ;; Initialize MCP system
            (when (require 'scientific-mapping-mcp-initialize nil t)
              (scientific-mapping-mcp-initialize))
            
            ;; Wait for MCP server to be ready
            (run-with-timer 5 nil 
              (lambda ()
                (when (and (require 'mcp-realtime nil t)
                           (mcp-realtime-status))
                  (message \"🔄 MCP system ready for connections!\"))))
            
            ;; Keep Emacs alive as MCP server
            (while true; do
              (sleep 30)
              (when (fboundp 'mcp-realtime-status)
                (let ((status (mcp-realtime-status)))
                  (message \"🔗 MCP Server Status: %s\" 
                           (if (plist-get status :mcp-server) \"🟢 Running\" \"🔴 Error\"))))
              ;; Check if service should continue
              if [ -f /tmp/scientific-mapping-mcp-stop ]; then
                break
              fi
            done
          )
          
          EOF
        
        '';
        
        postStart = ''
          #!/usr/bin/env bash
          
          # Create stop flag file
          touch /tmp/scientific-mapping-mcp-stop
          
          # Stop Ollama if needed
          echo "🛑 Stopping Scientific Mapping MCP Server..."
          systemctl --user stop ollama 2>/dev/null || pkill -f ollama
          
          # Clean up
          rm -f /tmp/scientific-mcp-stop
          
          echo "✅ Scientific Mapping MCP Server stopped"
        '';
      };
    };
    
    # Additional configuration for advanced users
    environment.etc = {
      # Scientific Mapping system-wide configuration
      "scientific-mapping".text = ''
        # Scientific Mapping NixOS Configuration
        # This file configures the Scientific Mapping system for NixOS
        
        ## System Environment
        SCIENTIFIC_MAPPING_CONFIG="/home/asdf/.config/emacs/scientific-mapping"
        SCIENTIFIC_DOCUMENTS_DIR="/home/asdf/scientific-documents"
        
        ## AI Runtime Configuration
        OLLAMA_HOST="127.0.0.1"
        OLLAMA_PORT="11434"
        MCP_ENABLED="true"
        
        ## Profile Configuration
        DEFAULT_RESEARCH_PROFILE="comprehensive"
        DEFAULT_AI_PROVIDER="ollama"
        DEFAULT_MCP_SYNC="true"
      '';
      
      "scientific-mapping".source = pkgs.writeText "scientific-mapping-config" ''
        #!/usr/bin/env bash
        source /etc/static/scientific-mapping
      '';
    };
  }
}