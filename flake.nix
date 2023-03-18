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
  # Add --recreate-lock-file option to update all flake dependencies
  outputs = inputs: {
    formatter."x86_64-darwin" = inputs.nixpkgs.legacyPackages."x86_64-darwin".nixpkgs-fmt;

    darwinConfigurations.Daniels-MacBook-Pro = inputs.darwin.lib.darwinSystem {
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
            pkgs.nerdfonts
          ];

          homebrew.enable = true;
          homebrew.onActivation.cleanup = "uninstall";
          homebrew.onActivation.upgrade = true;
          homebrew.global.autoUpdate = false;
          homebrew.global.brewfile = true;
          homebrew.taps = [ "homebrew/cask" ];
          homebrew.caskArgs.no_quarantine = true;
          homebrew.casks = [
            "amethyst"
            "brave-browser"
            "firefox"
            "google-chrome"
            "raycast"
            "visual-studio-code"
          ];
          # See https://github.com/mas-cli/mas
          # > mas list  # for installed apps
          # > mas search --price # to search the app store
          homebrew.masApps = {
            "Microsoft Remote Desktop" = 1295203466;
            Amphetamine = 937984704;
            Bitwarden = 1352778147;
            Telegram = 747648890;
            WhatsApp = 1147396723;
          };

          environment.shells = [ pkgs.bash pkgs.zsh ];
          environment.loginShell = pkgs.zsh;

          programs.zsh.enable = true;

          services.emacs.enable = true;

          # Use TouchID for sudo auth
          security.pam.enableSudoTouchIdAuth = true;

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
              ({ pkgs, ... }: {
                # Don't change this when you change package inputs. Leave it alone.
                home.stateVersion = "23.05";

                # specify my home-manager configs
                home.packages = [
                  # List of user-only packages to install
                  # here are the ones that I don't care to tweak
                  # otherwise they'd go under programs.<module>...
                  pkgs.bat
                  pkgs.clac
                  pkgs.coreutils
                  pkgs.emacs
                  pkgs.fd
                  pkgs.gnugrep
                  pkgs.neovim
                  pkgs.pandoc
                  pkgs.ripgrep
                ];

                home.sessionVariables = {
                  PAGER = "less";
                  CLICOLOR = 1;
                  EDITOR = "nvim";
                };

                programs.git.enable = true;
                programs.git.package = pkgs.gitAndTools.gitFull;
                programs.git.userEmail = "dstcruz@gmail.com";
                programs.git.userName = "Daniel Santa Cruz";

                programs.fzf.enable = true;
                programs.fzf.enableZshIntegration = true;

                programs.zsh.enable = true;
                programs.zsh.enableCompletion = true;
                programs.zsh.enableAutosuggestions = true;
                programs.zsh.enableSyntaxHighlighting = true;
                programs.zsh.shellAliases = { ls = "ls --color=auto -F"; };
              })
            ];
          };
        }
      ];
    };
  };
}
