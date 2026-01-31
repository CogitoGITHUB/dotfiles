{ config, pkgs, ... }:
{
  # Full DevOps development stack
  
  # PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    ;
    initialScript = pkgs.writeText "init.sql" 
      CREATE ROLE aoeu WITH LOGIN SUPERUSER;
    ;
  };
  
  # Redis
  services.redis.servers."" = {
    enable = true;
    port = 6379;
  };
  
  # Prometheus monitoring
  services.prometheus = {
    enable = true;
    port = 9090;
    
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
      };
    };
    
    scrapeConfigs = [
      {
        job_name = "shapeless";
        static_configs = [{
          targets = [ "localhost:9100" ];
        }];
      }
    ];
  };
  
  # Grafana dashboards
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
      };
      
      security = {
        admin_user = "admin";
        admin_password = "admin";  # Change this in secrets!
      };
    };
    
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:9090";
        }
      ];
    };
  };
  
  # Development packages
  environment.systemPackages = with pkgs; [
    # Database tools
    postgresql
    redis
    
    # Monitoring
    prometheus
    grafana
    
    # DevOps tools
    kubectl
    helm
    terraform
    ansible
    
    # Container tools (already have docker)
    dive  # Docker image explorer
    ctop  # Container monitoring
    
    # API testing
    httpie
    curl
    
    # Jupyter for data science
    jupyter
    python3Packages.pandas
    python3Packages.numpy
    python3Packages.matplotlib
  ];
  
  # Open firewall for services (localhost only by default)
  networking.firewall.allowedTCPPorts = [ 
    # 3000  # Grafana (uncomment for network access)
    # 9090  # Prometheus
  ];
}
