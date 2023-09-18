/* _____   ________________
   ___  | / /_  __ \_  ___/
   __   |/ /_  / / /____ \
   _  /|  / / /_/ /____/ /
   /_/ |_/  \____/ /____/

   01001010 01001100
   Igne natura renovatur integra.
*/

{ config, pkgs, ... }:

{
  imports = [ # Include hardware scan product.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "NOS-Mach-0"; # Hostname.

  # Network proxy config.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Networking on/off.
  networking.networkmanager.enable = true;

  # Time zone.
  time.timeZone = "";

  # Internationalization properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Explicit tty1 activation.
  systemd.services."autovt@tty1".wantedBy = [ "multi-user.target" ];

  # Sound.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User account. Password set with ‘passwd’.
  users.users.name = {
    isNormalUser = true;
    description = "name";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ firefox ];
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    # Nix packages.
    nil # Language server protocol.
    nixfmt # Nix formatter.

    # Text editor.
    helix # hx.

    # Notification daemon.
    mako # makoctl, mako.

    # Notif dep.
    libnotify # notify-send.

    # Terminal emulator.
    foot # footclient, foot.
  ];

  networking.firewall.enable = true;

  # Review relevant documentation before changing.
  system.stateVersion = "23.05";

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Nvidia driver for Xorg and Wayland.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    modesetting.enable = true;

    # Enable power management.
    # Likely to cause problems on laptops and with screen tearing if disabled.
    powerManagement.enable = true;

    # Use the Nvidia open source kernel module.
    # supported GPUs: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+.
    open = false;

    # Enable Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Select GPU driver version.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable Hyprland.
  programs.hyprland = {
    enable = true;
    nvidiaPatches = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    # Hint electron apps to use wayland.
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Desktop portal.
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  # Bash config.
  programs.bash.interactiveShellInit = ''
    bind '"\e\C-h": "\e[D"' # Move left // Ctrl+Alt+h.
    bind '"\e\C-l": "\e[C"' # Move right // Ctrl+Alt+l.

    bind '"\e\C-j": "\e[B"' # Search down // Ctrl+Alt+j.
    bind '"\e\C-k": "\e[A"' # Search up // Ctrl+Alt+k.
  '';

  # Hyprland config.
  environment.etc."hypr/hyprland.conf".text = ''
    ########################################################################################
    #                                  HYPRLAND CONFIG                                     #
    ########################################################################################

    # Monitor config.
    monitor = DP-1,1920x1080@60,0x0,1

    # Run notification daemon.
    exec-once = mako

    # Cursor size. 
    env = XCURSOR_SIZE,24

    # Input var config.
    input {
        kb_layout = us
        kb_variant =
        kb_model =
        kb_options =
        kb_rules =

        follow_mouse = 1

        sensitivity = 0 
        accel_profile = flat
    }

    # General var config.
    general {
        gaps_in = 5
        gaps_out = 20
        border_size = 2
        col.active_border = rgba(a4a0e8ee) rgba(3b224cee) 45deg
        col.inactive_border = rgba(3b224caa)

        layout = master
    }

    # Decoration var config.
    decoration {
        rounding = 10

        blur = true
        blur_size = 3
        blur_passes = 1
        blur_new_optimizations = true
        blur_xray = true 
        
        drop_shadow = true
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)

        active_opacity = 0.9
        inactive_opacity = 0.8
        fullscreen_opacity = 0.9
    }

    # Animations config.
    animations {
        enabled = true

        bezier = myBezier, 0.05, 0.9, 0.1, 1.05

        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
    }

    # Master layout config.
    master {
        new_is_master = false
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
    }

    # Bind mainMod.
    $mainMod = SUPER

    # Bindings.
    bind = $mainMod, T, exec, foot # Launch foot.
    bind = $mainMod, X, killactive # Terminate current focus.
    bind = $mainMod, M, fullscreen, 1 # Maximize current focus.

    # Move focus with mainMod. 
    bind = $mainMod, H, movefocus, l
    bind = $mainMod, L, movefocus, r
    bind = $mainMod, K, movefocus, u
    bind = $mainMod, J, movefocus, d

    # Switch workspaces with mainMod.
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
  '';

  # Helix config.
  environment.etc."helix/config.toml".text = ''
    ########################################################################################
    #                                  HELIX CONFIG                                        #
    ########################################################################################

    theme = "nos"
  '';

  # Helix theme config.
  environment.etc."helix/themes/nos.toml".text = ''
    ########################################################################################
    #                            NOS // HELIX THEME CONFIG                                 #
    ########################################################################################
           
    attribute = "comet"
    keyword = "timber"
    "keyword.directive" = "lilac" 
    namespace = "comet"
    punctuation = "lavender"
    "punctuation.delimiter" = "lavender"
    operator = "lavender"
    special = "atomic"
    "variable.other.member" = "atomic"
    variable = "blueg"
    "variable.parameter" = { fg = "fgrey" }
    "variable.builtin" = "vista"
    type = "lilac"
    "type.builtin" = "ice"
    constructor = "fgrey"
    function = "white"
    "function.macro" = "vista"
    "function.builtin" = "nyan"
    tag = "rose"
    comment = "sirocco"
    constant = "rose"
    "constant.builtin" = "ice"
    string = "timber"
    "constant.numeric" = "rose"
    "constant.character.escape" = "nyan"
    label = "fgrey"

    "markup.heading" = "lilac"
    "markup.bold" = { modifiers = ["bold"] }
    "markup.italic" = { modifiers = ["italic"] }
    "markup.strikethrough" = { modifiers = ["crossed_out"] }
    "markup.link.url" = { fg = "silver", modifiers = ["underlined"] }
    "markup.link.text" = "rquartz"
    "markup.raw" = "rquartz"

    "diff.plus" = "#35bf86"
    "diff.minus" = "#f22c86"
    "diff.delta" = "#6f44f0"

    "ui.background" = { bg = "onyx" }
    "ui.background.separator" = { fg = "comet" }
    "ui.linenr" = { fg = "comet" }
    "ui.linenr.selected" = { fg = "lilac" }
    "ui.statusline" = { fg = "lilac", bg = "revolver" }
    "ui.statusline.inactive" = { fg = "lavender", bg = "revolver" }
    "ui.popup" = { bg = "revolver" }
    "ui.window" = { fg = "bossanova" }
    "ui.help" = { bg = "#7958DC", fg = "#171452" }

    "ui.text" = { fg = "lavender" }
    "ui.text.focus" = { fg = "white" }
    "ui.text.inactive" = "sirocco"
    "ui.virtual" = { fg = "comet" }

    "ui.virtual.indent-guide" = { fg = "comet" }

    "ui.selection" = { bg = "#540099" }
    "ui.selection.primary" = { bg = "#540099" }
    "ui.cursor.select" = { bg = "delta" }
    "ui.cursor.insert" = { bg = "white" }
    "ui.cursor.match" = { fg = "#212121", bg = "#6C6999" }
    "ui.cursor" = { modifiers = ["reversed"] }
    "ui.cursorline.primary" = { bg = "bossanova" }
    "ui.highlight" = { bg = "bossanova" }
    "ui.highlight.frameline" = { bg = "#634450" }
    "ui.debug" = { fg = "#634450" }
    "ui.debug.breakpoint" = { fg = "nyan" }
    "ui.menu" = { fg = "lavender", bg = "revolver" }
    "ui.menu.selected" = { fg = "revolver", bg = "white" }
    "ui.menu.scroll" = { fg = "lavender", bg = "comet" }

    "diagnostic.hint" = { underline = { color = "silver", style = "curl" } }
    "diagnostic.info" = { underline = { color = "delta", style = "curl" } }
    "diagnostic.warning" = { underline = { color = "lightning", style = "curl" } }
    "diagnostic.error" = { underline = { color = "nyan", style = "curl" } }

    warning = "lightning"
    error = "nyan"
    info = "delta"
    hint = "silver"

    [palette]
    silver = "#cccccc"
    lightning = "#ffcd1c"   
    white = "#f5f5f5"
    lilac = "#dbbfef"
    lavender = "#a4a0e8"
    comet = "#5a5977"
    bossanova = "#452859"
    onyx = "#37393a"
    revolver = "#281733"
    sirocco = "#697C81"
    nyan = "#eafae0"
    rquartz = "#aa98a9"
    midnight = "#3b224c"
    delta = "#6F44F0"
    timber = "#dddad5"
    blueg = "#7487a5"
    ice = "#afe9e9"
    fgrey = "#7f7f7f"
    atomic = "#fddfb5"
    rose = "#d95c9a"
    vista = "#809fd6"
  '';

  # Foot config.
  environment.etc."foot/foot.ini".text = ''
    ########################################################################################
    #                                  FOOT CONFIG                                         #
    ########################################################################################

    term=foot
    login-shell=no
    app-id=foot
    title=NOS
    locked-title=yes

    font=monospace:size=12
    font-bold=monospace Bold:size=12
    font-italic=monospace Italic:size=12
    font-bold-italic=monospace Bold Italic:size=12
    pad=1x1 center
    letter-spacing=3px

    notify=notify-send -a $''${app-id} -i $''${app-id} $''${title} $''${body}
    bold-text-in-bright=no
    #workers=<num logical cpu>
    	   	
    [colors]
    background=37393a # Onyx.
    foreground=a4a0e8 # Lav.
    	
    # Normal/regular colors (color palette 0-7).
    regular0=dbbfef # Llc.
    regular1=7f7f7f # Fgr. 
    regular2=dddad5 # Timb. 
    regular3=f5f5f5 # Ws.
    regular4=afe9e9 # Ic. 
    regular5=7487a5 # Bgr. 
    regular6=dbbfef # Llc.
    regular7=697c81 # Sir. 
    		
    # Misc colors.
    selection-foreground=5a5977
    selection-background=6f44f0
    scrollback-indicator=d95c9a eafae0 
  '';

  # Mako config.
  environment.etc."mako/config".text = ''
    ########################################################################################
    #                                   MAKO CONFIG                                        #
    ########################################################################################

    background-color=#37393aee
    text-color=#f5f5f5ff
    border-color=#3b224cee
  '';

  # Symlink system-wide Hyprland config to user's local config directory.
  system.activationScripts.hyprConfig = {
    text = ''
      ln -sf /etc/hypr/hyprland.conf /home/jl/.config/hypr/hyprland.conf
    '';
  };

  # x2.
  system.activationScripts.helixThemeConfig = {
    text = ''
      mkdir -p /home/jl/.config/helix/themes
      ln -sf /etc/helix/themes/nos.toml /home/jl/.config/helix/themes/nos.toml
    '';
  };

  # x3.
  system.activationScripts.helixConfig = {
    text = ''
      ln -sf /etc/helix/config.toml /home/jl/.config/helix/config.toml
    '';
  };

  # x4.
  system.activationScripts.footConfig = {
    text = ''
      mkdir -p /home/jl/.config/foot
      ln -sf /etc/foot/foot.ini /home/jl/.config/foot/foot.ini
    '';
  };

  # x5.
  system.activationScripts.makoConfig = {
    text = ''
      mkdir -p /home/jl/.config/mako
      ln -sf /etc/mako/config /home/jl/.config/mako/config
    '';
  };
}