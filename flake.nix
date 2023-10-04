{
  description = "dansan's darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Build using: darwin-rebuild switch --flake .#Daniels-MacbookPro
  outputs = inputs: {
    formatter."x86_64-darwin" = inputs.nixpkgs.legacyPackages."x86_64-darwin".nixpkgs-fmt;

    darwinConfigurations.daniel-macbook-pro-2018 = inputs.darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      pkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };

      modules = [
        ({ pkgs, ... }: {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            # List of system wide packages to install
          ];

          fonts.fontDir.enable = true;
          fonts.fonts = [
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
            "firefox"
            "google-chrome"
            "raycast"
            "visual-studio-code"
            "telegram"
          ];

          # See https://github.com/mas-cli/mas
          # > mas list  # for installed apps
          # > mas search --price # to search the app store
          homebrew.masApps = {
            "Microsoft Remote Desktop" = 1295203466;
            Amphetamine = 937984704;
            Bitwarden = 1352778147;
            #Telegram = 747648890;
            WhatsApp = 1147396723;
            WireGuard = 1451685025;
            Pages = 409201541;
            Numbers = 409203825;
            "AdGuard for Safari" = 1440147259;
          };

          environment.shells = [ pkgs.bash pkgs.zsh pkgs.fish ];
          environment.loginShell = "${pkgs.fish}/bin/fish -l";

          programs.fish.enable = true;
          #programs.zsh.enable = true;

          #services.emacs.enable = true;
          services.nix-daemon.enable = true;

          users.users.dansan = {
            name = "dansan";
            home = "/Users/dansan";
            shell = pkgs.fish;
          };

          networking.hostName = "daniel-macbook-pro-2018";

          system.defaults.dock.autohide = true;
          system.defaults.dock.autohide-delay = 0.0;
          system.defaults.dock.autohide-time-modifier = 0.0;
          system.defaults.dock.mineffect = "scale";
          system.defaults.dock.mru-spaces = false;
          system.defaults.dock.orientation = "left";
          system.defaults.dock.show-recents = false;
          system.defaults.dock.showhidden = true;
          system.defaults.dock.tilesize = 40;

          system.defaults.dock.wvous-tl-corner = 1; #disabled
          system.defaults.dock.wvous-tr-corner = 1; #disabled
          system.defaults.dock.wvous-bl-corner = 1; #disabled
          system.defaults.dock.wvous-br-corner = 1; #disabled

          system.defaults.screencapture.type = "jpg";

          system.defaults.trackpad.Clicking = true;
          system.defaults.trackpad.TrackpadRightClick = true;
          system.defaults.trackpad.TrackpadThreeFingerDrag = true;

          system.defaults.finder.AppleShowAllExtensions = true;
          system.defaults.finder._FXShowPosixPathInTitle = true;
          system.defaults.finder.AppleShowAllFiles = true;
          system.defaults.finder.ShowPathbar = true;
          system.defaults.finder.ShowStatusBar = true;

          system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
          system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
          system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
          system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
          system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;

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
                  pkgs.ispell
                  pkgs.bat
                  pkgs.binutils
                  pkgs.clac
                  pkgs.coreutils
                  pkgs.coreutils-prefixed
                  pkgs.editorconfig-core-c
                  pkgs.emacs29
                  pkgs.emacs-all-the-icons-fonts
                  pkgs.eza
                  pkgs.fish
                  pkgs.fd
                  pkgs.git
                  pkgs.gnugrep
                  pkgs.gnutls
                  pkgs.imagemagick
                  pkgs.neofetch
                  pkgs.neovim
                  pkgs.nixfmt
                  pkgs.nodePackages.svelte-language-server
                  pkgs.nodePackages.typescript-language-server
                  pkgs.pandoc
                  pkgs.ripgrep
                  pkgs.shellcheck
                  pkgs.sqlite
                  pkgs.zsh-powerlevel10k
                  pkgs.zstd
                ];

                home.sessionPath = [
                  "$HOME/.config/emacs/bin"
                ];

                home.sessionVariables = {
                  PAGER = "bat";
                  CLICOLOR = 1;
                  EDITOR = "nvim";
                  TERMINAL = "alacritty";
                };

                programs.alacritty = {
                  enable = true;
                  settings.font.normal.family = "CommitMono";
                  settings.font.size = 14;
                  settings.dynamic_title = true;
                  settings.window.padding.x = 10;
                  settings.window.padding.y = 10;
                  settings.shell.program = "${pkgs.fish}/bin/fish";
                };

                programs.atuin = {
                  enable = true;
                  enableFishIntegration = true;
                  enableZshIntegration = true;
                };

                programs.git = {
                  enable = true;
                  package = pkgs.git;
                  #package = pkgs.gitAndTools.gitFull;
                  userEmail = "dstcruz@gmail.com";
                  userName = "Daniel Santa Cruz";
                };

                programs.fish.enable = true;


                programs.fzf.enable = true;
                #programs.fzf.enableZshIntegration = true;

                programs.zsh = {
                  enable = true;
                  enableCompletion = true;
                  enableAutosuggestions = true;
                  syntaxHighlighting.enable = true;
                  shellAliases = {
                    ls = "eza";
                  };
                  history = {
                    expireDuplicatesFirst = true;
                    ignoreSpace = true;
                    save = 10000;
                    share = true;
                  };
                  plugins = [
                    {
                      name = "powerlevel10k";
                      src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
                      file = "powerlevel10k.zsh-theme";
                    }
                    {
                      name = "powerlevel10k-config";
                      src = ./dotfiles;
                      file = "p10k.zsh";
                    }
                  ];
                  initExtraFirst = ''
                    # powerlevel10k instant prompt stuff
                    if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
                      source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
                    fi
                  '';
                };

                # ~/.config symlinks
                xdg.configFile = {
                  "doom" = {
                    source = ./doom;
                    recursive = true;
                    # This is now working
                    # onChange = "$HOME/.config/emacs/bin/doom sync";
                  };
                };

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
