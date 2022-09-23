{
  description = "dansan's darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Build using: darwin-rebuild switch --flake .#Daniels-MacbookPro
  # Add --recreate-lock-file option to update all flake dependencies
  outputs = { self, nixpkgs, darwin }: {
    # Not sure what this does ATM
    darwinPackages = self.darwinConfigurations."Daniel-MackbookPro".pkgs;

    darwinConfigurations."Daniels-MacbookPro" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";

      modules = [
        ({ config, lib, pkgs, ... }: {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.bat
            pkgs.clac
            pkgs.coreutils
            pkgs.emacs
            pkgs.fd
            pkgs.fzf
            pkgs.git
            pkgs.gnugrep
            pkgs.kitty
            pkgs.neovim
            pkgs.pandoc
            pkgs.ripgrep
            pkgs.zsh
          ];

          fonts.fontDir.enable = true;
          fonts.fonts = [
            pkgs.emacs-all-the-icons-fonts
            pkgs.meslo-lgs-nf
          ];

          homebrew.enable = true;
          homebrew.onActivation.cleanup = "uninstall";
          homebrew.onActivation.upgrade = true;
          homebrew.global.autoUpdate = false;
          homebrew.global.brewfile = true;
          homebrew.taps = [ "homebrew/cask" ];
          homebrew.casks = [
            "firefox"
            "google-chrome"
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

          programs.zsh = {
            enable = true;
            promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            enableFzfHistory = true;
            enableSyntaxHighlighting = true;
          };

          environment.shells = [ pkgs.zsh ];

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
          nix.package = pkgs.nixFlakes;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 4;
        })
      ];
    };
  };
}
