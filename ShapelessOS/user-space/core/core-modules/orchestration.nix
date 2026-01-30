# modules/orchestration.nix
{ config, pkgs, ... }:

{
  # Kubernetes / container orchestration
  services.k3s = {
    enable = false;        # set to true if this machine is a server
    role = "server";
    clusterInit = true;
    extraFlags = [ "--docker" ];
  };

  # Optional swarm / task runners
  virtualisation.dockerSwarm.enable = false;

  # Optional workflow automation
  services.nomad.enable = false;

  # System packages for orchestration tooling
  environment.systemPackages = with pkgs; [
    kubectl
    helm
    k9s
    docker-compose
  ];
}
