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
  outputs = inputs @ {
    lix-module,
    nix-darwin,
    home-manager,
    ...
  }: {
    darwinConfigurations.daniel-macbook-pro-2018 = nix-darwin.lib.darwinSystem {
      system = "x86_64-darwin";

      modules = [
        # see: https://lix.systems/add-to-config/
        lix-module.nixosModules.default

        ({pkgs, ...}: {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            # List of system wide packages to install

            # putting these shells here so that they show up in
            # /run/current-system/sw/bin
            # and therefore can easily be used by my terminals
            pkgs.nushell
            pkgs.fish
          ];

          fonts.packages = [
            pkgs.meslo-lgs-nf
            pkgs.commit-mono
          ];

          homebrew = {
            enable = true;
            onActivation.cleanup = "uninstall";
            onActivation.upgrade = true;
            global.autoUpdate = false;
            global.brewfile = true;
            taps = ["homebrew/cask"];
            caskArgs.no_quarantine = true;
            casks = [
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
            masApps = {
              "Accelerate" = 1459809092;
              "AdGuard for Safari" = 1440147259;
              "Hidden Bar" = 1452453066;
              Amphetamine = 937984704;
              Bitwarden = 1352778147;
              Numbers = 409203825;
              OneTab = 1540160809;
              Pages = 409201541;
              WireGuard = 1451685025;
            };
          };

          # environment.shells = [ pkgs.fish pkgs.nushell ];
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

          # You can read these values with:
          # > defaults read <domain> [<key>]
          # like this:
          # > defaults read com.apple.desktopservices
          # > defaults read com.apple.desktopservices DontWriteUSBStores
          system.defaults.CustomUserPreferences = {
            "com.apple.desktopservices" = {
              # Avoid creating .DS_Store files on network or USB volumes
              DSDontWriteNetworkStores = true;
              DSDontWriteUSBStores = true;
            };
            "com.apple.AdLib" = {
              allowApplePersonalizedAdvertising = false;
            };
          };

          system.keyboard.enableKeyMapping = true;
          system.keyboard.remapCapsLockToControl = true;

          nix.useDaemon = true;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 4;
        })

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users.dansan.imports = [
              ({
                pkgs,
                config,
                ...
              }: {
                # Don't change this when you change package inputs. Leave it alone.
                home.stateVersion = "23.05";

                # specify my home-manager configs
                home.packages = [
                  # List of user-only packages to install
                  # here are the ones that I don't care to tweak
                  # otherwise they'd go under programs.<module>...
                  (pkgs.ripgrep.override {withPCRE2 = true;})
                  pkgs.alejandra
                  pkgs.binutils
                  pkgs.clac
                  pkgs.coreutils-prefixed
                  pkgs.difftastic
                  pkgs.editorconfig-core-c
                  pkgs.fd
                  pkgs.findutils
                  pkgs.fishPlugins.tide
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
                  pkgs.pandoc
                  pkgs.riff
                  pkgs.shellcheck
                  pkgs.sqlite
                  pkgs.tree-sitter
                  pkgs.zstd
                ];

                home.sessionVariables = {
                  CLICOLOR = 1;
                  EDITOR = "nvim";
                };

                programs.atuin = {
                  enable = true;
                  enableFishIntegration = true;
                  enableZshIntegration = true;
                  enableNushellIntegration = true;
                };

                programs.carapace = {
                  enable = true;
                  enableNushellIntegration = true;
                };

                programs.eza = {
                  enable = true;
                  enableFishIntegration = true;
                  #enableNushellIntegration = true;
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

                programs.nushell = {
                  enable = true;
                  shellAliases = {
                    nu-open = "open";
                    open = "^open";
                  };
                  envFile.text = ''
                    $env.PROMPT_COMMAND = {|| 
                      if (is-admin) {
                        $"(ansi red_bold)($env.PWD)"
                      } else {
                        $"(ansi green_bold)($env.PWD)"
                      }
                    }

                    $env.PROMPT_COMMAND_RIGHT = "" 

                    $env.PROMPT_INDICATOR = "〉"
                    $env.PROMPT_INDICATOR_VI_INSERT = ": "
                    $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
                    $env.PROMPT_MULTILINE_INDICATOR = "::: "
                  '';
                };

                programs.fish = {
                  enable = true;

                  functions = {
                    # $1 length is 2 -> `cd ../`, 3 -> `cd ../../`, etc
                    __multicd = "echo cd (string repeat --count (math (string length -- $argv[1]) - 1) ../)";
                    forward-single-char-or-forward-word = ''
                      set -l line (commandline -L)
                      set -l cmd (commandline)
                      set -l cursor (commandline -C)
                      if test (string length -- $cmd[$line]) = $cursor
                        commandline -f forward-word
                      else
                        commandline -f forward-single-char
                      end
                    '';
                  };

                  plugins = [
                    {
                      name = "fishPlugins.tide";
                      src = pkgs.fishPlugins.tide.src;
                    }
                  ];

                  shellAbbrs = let
                    global = {
                      position = "anywhere";
                    };
                    cursor = {
                      setCursor = true;
                    };
                    regex = pat: {regex = pat;};
                    function = name: {function = name;};
                    text = str: {expansion = str;};
                  in {
                    _dotdot =
                      regex "^\\.\\.+$" // function "__multicd";
                    calc = "clac";
                  };

                  interactiveShellInit = ''
                    # disable greeting
                    set -U fish_greeting

                    # my bindings
                    bind \cf forward-single-char-or-forward-word
                  '';
                };

                programs.direnv = {
                  enable = true;
                  enableNushellIntegration = true;
                  nix-direnv.enable = true;
                };

                programs.fzf.enable = true;

                programs.yazi = {
                  enable = true;
                  enableFishIntegration = true;
                  enableNushellIntegration = true;
                };

                programs.zoxide = {
                  enable = true;
                  enableFishIntegration = true;
                  enableNushellIntegration = true;
                };

                # ~/.config symlinks
                xdg.configFile = {};

                # ~ symlinks
                home.file = {};
              })
            ];
          };
        }
      ];
    };
  };
}
