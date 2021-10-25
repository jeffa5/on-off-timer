{
  description = "A very basic flake";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; android_sdk.accept_license = true; };
      };
    in
    {
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [
          flutter
          dart
          android-studio
          android-tools
          androidenv.androidPkgs_9_0.androidsdk

          clang
          libclang
          cmake
          ninja
          pkg-config
          gtk3
          glibc
          glib
          epoxy
          pcre
          mount
          mesa
          # gobject
          cairo
          pango
          # gdk
          atk

          rnix-lsp
          nixpkgs-fmt
        ];

        CHROME_EXECUTABLE = "chromium";
      };
    };
}
