{ config, lib, ... }:
let

  cfg = config.programs.librewolf;

  mkOverridesFile = prefs: ''
    // Generated by Home Manager.

    ${lib.concatStrings (lib.mapAttrsToList (name: value: ''
      defaultPref("${name}", ${builtins.toJSON value});
    '') prefs)}
  '';

  modulePath = [ "programs" "librewolf" ];

  mkFirefoxModule = import ./firefox/mkFirefoxModule.nix;

in {
  meta.maintainers = with lib.maintainers; [ chayleaf onny ];

  imports = [
    (mkFirefoxModule {
      inherit modulePath;
      name = "LibreWolf";
      description = "LibreWolf is a privacy enhanced Firefox fork.";
      wrappedPackageName = "librewolf";
      unwrappedPackageName = "librewolf-unwrapped";

      platforms.linux = { configPath = ".librewolf"; };
      platforms.darwin = {
        configPath = "Library/Application Support/LibreWolf";
      };

      enableBookmarks = false;
    })
  ];

  options.programs.librewolf = {
    settings = lib.mkOption {
      type = with lib.types; attrsOf (either bool (either int str));
      default = { };
      example = lib.literalExpression ''
        {
          "webgl.disabled" = false;
          "privacy.resistFingerprinting" = false;
        }
      '';
      description = ''
        Attribute set of global LibreWolf settings and overrides. Refer to
        <https://librewolf.net/docs/settings/>
        for details on supported values.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".librewolf/librewolf.overrides.cfg" =
      lib.mkIf (cfg.settings != { }) { text = mkOverridesFile cfg.settings; };
  };
}
