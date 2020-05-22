{ stdenv
, autoPatchelfHook
, fetchurl
, glibc
, gcc-unwrapped
, gtk3
, jre
, libsecret
, makeDesktopItem
, webkitgtk
, wrapGAppsHook
}:
let
  desktopItem = makeDesktopItem {
    name = "Portfolio";
    exec = "portfolio";
    icon = "portfolio";
    comment = "Calculate Investment Portfolio Performance";
    desktopName = "Portfolio Performance";
    categories = "Office;";
  };

  runtimeLibs = stdenv.lib.makeLibraryPath [ gtk3 webkitgtk ];
in
stdenv.mkDerivation rec {
  pname = "PortfolioPerformance";
  version = "0.46.3";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/${version}/PortfolioPerformance-${version}-linux.gtk.x86_64.tar.gz";
    sha256 = "0263v0ymqmf7kcwys4smwx1p1gh8d20dh10canjfqgl4c5lfx966";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook
  ];

  buildInputs = [
    glibc
    gcc-unwrapped
    libsecret
  ];

  installPhase = ''
    mkdir -p $out/portfolio
    cp -av ./* $out/portfolio

    makeWrapper $out/portfolio/PortfolioPerformance $out/bin/portfolio \
      --prefix LD_LIBRARY_PATH : "${runtimeLibs}" \
      --prefix PATH : ${jre}/bin

    # Create desktop item
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
    mkdir -p $out/share/pixmaps
    ln -s $out/portfolio/icon.xpm $out/share/pixmaps/portfolio.xpm
  '';

  meta = with stdenv.lib; {
    description = "A simple tool to calculate the overall performance of an investment portfolio.";
    homepage = "https://www.portfolio-performance.info/";
    license = licenses.epl10;
    maintainers = with maintainers; [ elohmeier ];
    platforms = [ "x86_64-linux" ];
  };
}