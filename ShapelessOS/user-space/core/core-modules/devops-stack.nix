{ config, pkgs, ... }:
{
  # Full DevOps development stack
  
  # PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
    '';
    initialScript = pkgs.writeText "init.sql" ''
      CREATE ROLE aoeu WITH LOGIN SUPERUSER;
    '';
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
 

#  services.hydra = {
#    enable = true;
#    hydraURL = "http://localhost:3000"; # externally visible URL
#    notificationSender = "hydra@localhost"; # e-mail of Hydra service
#    # a standalone Hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/machines
#    buildMachinesFiles = [];
#    # you will probably also want this, otherwise *everything* will be built from scratch
#    useSubstitutes = true;
#  };

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
        admin_password = "admin";
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
    postgresql
    redis
    prometheus
    grafana
    kubectl
    helm
    terraform
    ansible
    dive
    ctop
    httpie
    curl
    jupyter
    python3Packages.pandas
    python3Packages.numpy
    python3Packages.matplotlib
  ];
}
