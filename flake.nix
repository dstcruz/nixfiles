{
  description = "dansan's nix-darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Build using: 
  # > darwin-rebuild switch --flake .#daniel-macbook-pro-2018
  # Alternatively, since this system _is_ daniel-macbook-pro-2018, then we can build with:
  # > darwin-rebuild switch --flake .
  outputs = inputs: {
    darwinConfigurations.daniel-macbook-pro-2018 =
      inputs.nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        pkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };

        modules = [
          # see: https://lix.systems/add-to-config/
          inputs.lix-module.nixosModules.default

          ({ pkgs, ... }: {
            # List packages installed in system profile. To search by name, run:
            # $ nix-env -qaP | grep wget
            environment.systemPackages = [
              # List of system wide packages to install
            ];

            fonts.packages = [
              pkgs.meslo-lgs-nf
              pkgs.commit-mono
            ];

            homebrew.enable = true;
            homebrew.onActivation.cleanup = "uninstall";
            homebrew.onActivation.upgrade = true;
            homebrew.global.autoUpdate = false;
            homebrew.global.brewfile = true;
            homebrew.taps = [ "homebrew/cask" ];
            homebrew.caskArgs.no_quarantine = true;
            homebrew.casks = [
              "arc"
              "firefox"
              "microsoft-edge"
              "obsidian"
              "raycast"
              "telegram"
              "visual-studio-code"
              "wezterm"
            ];

            # See https://github.com/mas-cli/mas
            # > mas list  # for installed apps
            # > mas search --price # to search the app store
            homebrew.masApps = {
              "Microsoft Remote Desktop" = 1295203466;
              Amphetamine = 937984704;
              Bitwarden = 1352778147;
              WhatsApp = 1147396723;
              WireGuard = 1451685025;
              Pages = 409201541;
              Numbers = 409203825;
              "AdGuard for Safari" = 1440147259;
            };

            environment.shells = [ pkgs.fish ];
            programs.fish.enable = true;

            users.users.dansan = {
              name = "dansan";
              home = "/Users/dansan";
            };

            networking.hostName = "daniel-macbook-pro-2018";

            system.defaults.dock = {
              autohide = true;
              autohide-delay = 0.0;
              autohide-time-modifier = 0.0;
              mineffect = "scale";
              mru-spaces = false;
              orientation = "left";
              show-recents = false;
              showhidden = true;
              tilesize = 40;

              wvous-tl-corner = 1; # disabled
              wvous-tr-corner = 1; # disabled
              wvous-bl-corner = 1; # disabled
              wvous-br-corner = 1; # disabled
            };

            system.defaults.screencapture.type = "jpg";

            system.defaults.trackpad = {
              Clicking = true;
              TrackpadRightClick = true;
              TrackpadThreeFingerDrag = true;
            };

            system.defaults.finder = {
              AppleShowAllExtensions = true;
              _FXShowPosixPathInTitle = true;
              AppleShowAllFiles = true;
              ShowPathbar = true;
              ShowStatusBar = true;
            };

            system.defaults.NSGlobalDomain = {
              NSAutomaticSpellingCorrectionEnabled = false;
              NSAutomaticQuoteSubstitutionEnabled = false;
              NSAutomaticPeriodSubstitutionEnabled = false;
              NSAutomaticDashSubstitutionEnabled = false;
              NSAutomaticCapitalizationEnabled = false;
            };

            system.keyboard.enableKeyMapping = true;
            system.keyboard.remapCapsLockToControl = true;

            nix.useDaemon = true;
            nix.package = pkgs.nix;
            nix.extraOptions = ''
              experimental-features = nix-command flakes
            '';

            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            system.stateVersion = 4;
          })

          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              users.dansan.imports = [
                ({ pkgs, config, ... }: {
                  # Don't change this when you change package inputs. Leave it alone.
                  home.stateVersion = "23.05";

                  # specify my home-manager configs
                  home.packages = [
                    # List of user-only packages to install
                    # here are the ones that I don't care to tweak
                    # otherwise they'd go under programs.<module>...
                    (pkgs.ripgrep.override { withPCRE2 = true; })
                    pkgs.atuin
                    pkgs.binutils
                    pkgs.clac
                    pkgs.coreutils-prefixed
                    pkgs.difftastic
                    pkgs.editorconfig-core-c
                    pkgs.emacs
                    pkgs.fd
                    pkgs.findutils
                    pkgs.fishPlugins.tide
                    pkgs.fontconfig
                    pkgs.gawk
                    pkgs.git
                    pkgs.gnugrep
                    pkgs.gnutls
                    pkgs.home-manager
                    pkgs.imagemagick
                    pkgs.iosevka
                    pkgs.ispell
                    pkgs.moar
                    pkgs.neofetch
                    pkgs.neovim
                    pkgs.nixfmt-classic
                    pkgs.nushell
                    pkgs.pandoc
                    pkgs.riff
                    pkgs.ripgrep
                    pkgs.shellcheck
                    pkgs.sqlite
                    pkgs.tree-sitter
                    pkgs.yazi
                    pkgs.zstd
                    pkgs.zoxide
                  ];

                  home.sessionVariables = {
                    CLICOLOR = 1;
                    EDITOR = "nvim";
                    TERMINAL = "alacritty";
                    TERM = "xterm-256color";
                  };

                  programs.alacritty = {
                    enable = true;
                    settings.font.normal.family = "MesloLGS Nerd Font Mono";
                    settings.font.size = 14;
                    settings.shell.program = "${pkgs.fish}/bin/fish";
                    settings.window.blur = true;
                    settings.window.decorations = "Buttonless";
                    settings.window.opacity = 0.75;
                    settings.window.padding.x = 10;
                    settings.window.padding.y = 10;
                  };

                  programs.atuin = {
                    enable = true;
                    enableFishIntegration = true;
                    enableZshIntegration = true;
                  };
                  
                  programs.bat = {
                    enable = true;
                    config = {
                      pager = "less -FR";
                      theme = "Nord";
                    };
                  };

                  programs.eza = {
                    enable = true;
                    enableFishIntegration = true;
                  };

                  programs.git = {
                    enable = true;
                    package = pkgs.git;
                    #package = pkgs.gitAndTools.gitFull;
                    userEmail = "dstcruz@gmail.com";
                    userName = "Daniel Santa Cruz";
                    difftastic.enable = true;
                    aliases = {
                      dtl = "difftool";
                      dlog = "-c diff.external=difft log -p --ext-diff";
                    };
                  };

                  programs.fish = {
                    enable = true;

                    functions = {
                      # $1 length is 2 -> `cd ../`, 3 -> `cd ../../`, etc
                      __multicd = "echo cd (string repeat --count (math (string length -- $argv[1]) - 1) ../)";
                    };

                    plugins = [
                      { name = "fishPlugins.tide"; src = pkgs.fishPlugins.tide.src; }
                    ];

                    shellAbbrs = 
                      let
                        global = {
                          position = "anywhere";
                        };
                        cursor = {
                          setCursor = true;
                        };
                        regex = pat: { regex = pat; };
                        function = name: { function = name; };
                        text = str: { expansion = str; };
                      in {
                        _dotdot =
                          regex "^\\.\\.+$" // function "__multicd";
                        calc = "clac";
                      };

                    interactiveShellInit = ''
                      # disable greeting
                      set -U fish_greeting
                    '';
                  };

                  programs.direnv = {
                    enable = true;
                    nix-direnv.enable = true;
                  };

                  programs.fzf.enable = true;

                  programs.yazi = {
                    enable = true;
                  };

                  programs.zoxide = {
                    enable = true;
                  };

                  # ~/.config symlinks
                  xdg.configFile = { };

                  # ~ symlinks
                  home.file = { };
                })
              ];
            };
          }
        ];
      };
  };
}
