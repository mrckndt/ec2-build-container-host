{ config, lib, modulesPath, pkgs, ... }:

with lib;

let
  allowedTCPPorts = [ 80 443 8065 ];
  allowedUDPPorts = [ ];
  autoUpdateDockerContainers = true;
  defaultContainerBackend = "docker";
  hostName = "nixos-container-host";
  # system-wide available packages - https://search.nixos.org/packages
  systemPackages = with pkgs; [
    atool
    bind
    bmon
    docker-compose
    file
    git
    htop
    iotop
    ncdu
    netcat-gnu
    nettools
    nmap
    nmon
    psmisc
    ranger
    rsync
    unzip
  ];
  stateVersion = "23.05";
  timeZone = "Europe/Berlin";
in
{
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];

  boot.tmp = {
    cleanOnBoot = true;
    useTmpfs = true;
  };

  documentation = {
    info.enable = false;
    man.generateCaches = true;
  };

  environment = {
    systemPackages = systemPackages;
    variables = {
      LESS = mkDefault "-FRSMKI";
      SYSTEMD_LESS = mkDefault "FRSMKI";
    };
  };

  fonts.fontconfig.enable = false;

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
  ];

  networking = {
    hostName = hostName;
    firewall = {
      allowedTCPPorts = allowedTCPPorts;
      allowedUDPPorts = allowedUDPPorts;
    };
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    settings.auto-optimise-store = true;
  };

  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
      configure = {
        customRC = ''
          filetype plugin indent on

          set autowrite
          set expandtab
          set ignorecase
          set laststatus=2
          set linebreak
          set list listchars=tab:▸\ ,trail:·
          set mouse=a
          set nofoldenable
          set nojoinspaces
          set nowrap
          set number
          set shiftwidth=2
          set showbreak=↪\
          set splitbelow
          set splitright
          set statusline=\(%n\)\ %<%.99f\ %y\ %w%m%r%=%-14.(%l,%c%V%)\ %P
          set textwidth=120
          set wrapscan

          nnoremap <silent> <C-b> :buffers<CR>:buffer<Space>

          unmap Y
        '';
      };
    };
    tmux = {
      enable = true;
      aggressiveResize = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 0;
      extraConfig = ''
        set -g mouse on
        set -g renumber-windows on
        set -g set-titles on
        set -g status-interval 10
        set -g status-right "#(whoami)@#(hostname) | #(cut -f1 -d \" \" < /proc/loadavg) | %H:%M "
        set -ga terminal-overrides ",xterm-256color:Tc"

        unbind C-b
        set -g prefix C-x
        bind C-x send-prefix
      '';
      historyLimit = 10000;
      terminal = "xterm-256color";
    };
    zsh = {
      enable = true;
      enableBashCompletion = true;
      ohMyZsh = {
        enable = true;
        theme = "gentoo";
      };
      shellAliases = {
        ":q" = "exit";
        ".." = "cd ..";
        "grep" = "grep --color=auto";
      };
    };
  };

  # needed for rootless containers (e.g. with podman)
  security.unprivilegedUsernsClone = config.virtualisation.containers.enable;

  system = {
    autoUpgrade.enable = true;
    stateVersion = stateVersion;
  };

  time.timeZone = timeZone;

  users.defaultUserShell = mkIf config.programs.zsh.enable pkgs.zsh;

  virtualisation = {
    docker.enable = true;
    podman.enable = true;

    oci-containers.backend = defaultContainerBackend;
    oci-containers.containers.watchtower = mkIf autoUpdateDockerContainers {
      image = "containrrr/watchtower:latest";
      volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
      extraOptions = [
        "--security-opt=no-new-privileges:true"
        "--pids-limit=100"
        "--read-only"
        "--tmpfs=/tmp"
      ];
    };
  };
}
