{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, makeWrapper
, dbus
, libpulseaudio
, notmuch
, openssl
, ethtool
, lm_sensors
, iw
, iproute2
}:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "0.31.7";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-LcaKBl2PAEbXYFMJUth8vgx557YTiiuZd3EHBGrsO0M=";
  };

  cargoHash = "sha256-b3YkmyWgnhWyQ/ZhU6TyOZMFwk7jY80FHEd/MUqEQzw=";

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = [ dbus libpulseaudio notmuch openssl lm_sensors ];

  buildFeatures = [
    "notmuch"
    "maildir"
    "pulseaudio"
  ];

  prePatch = ''
    substituteInPlace src/util.rs \
      --replace "/usr/share/i3status-rust" "$out/share"
  '';

  postInstall = ''
    mkdir -p $out/share
    cp -R examples files/* $out/share
  '';

  postFixup = ''
    wrapProgram $out/bin/i3status-rs --prefix PATH : ${lib.makeBinPath [ iproute2 ethtool iw ]}
  '';

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  meta = with lib; {
    description = "Very resource-friendly and feature-rich replacement for i3status";
    homepage = "https://github.com/greshake/i3status-rust";
    license = licenses.gpl3Only;
    mainProgram = "i3status-rs";
    maintainers = with maintainers; [ backuitist globin ];
    platforms = platforms.linux;
  };
}
