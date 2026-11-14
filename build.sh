#!/usr/bin/env bash
# Reproducible build with the TeX Live closest to the original toolchain (MiKTeX 2.9, pdfTeX 1.40.13); TeX Live 2013 (pdfTeX 1.40.14) is the oldest available image and reproduces it pixel-identically.
# Requires podman (or docker: export ENGINE=docker).
#   ./build.sh          → build/web3d-webbased-treemaps.pdf          (as submitted, v1.0)
#   ./build.sh author   → build/web3d-webbased-treemaps-author.pdf   (ACM author's version notice and DOI on every page, for Zenodo)
# The ACM SIGGRAPH template of 2013 (acmsiggraph.cls/.bst, bundled in src/) has no authorversion option;
# the author target adds the notice in the bottom margin (atbegshi) without changing the layout.
set -euo pipefail
cd "$(dirname "$0")"
ENGINE=${ENGINE:-podman}
IMAGE=docker.io/texlive/texlive:TL2013-historic
MAIN=web3d-webbased-treemaps
DOI=10.1145/2466533.2466550
args=(-pdf -interaction=nonstopmode -outdir=/out)
dir=src out=build
if [[ ${1:-} == author ]]; then
  # atbegshi (not eso-pic) because it can be loaded before \documentclass; US letter = 215.9 x 279.4 mm
  notice="\\AtBeginShipout{\\AtBeginShipoutUpperLeft{\\setlength{\\unitlength}{1mm}\\put(107.95,-270.2){\\makebox[0pt][c]{\\fontsize{6.5}{8}\\selectfont\\color[gray]{0.4}\\copyright{} ACM 2013. This is the author\\rq{}s version of the work. It is posted here for your personal use. Not for redistribution. The definitive Version of Record is available at https://doi.org/$DOI.}}}}"
  pre="\\RequirePackage{atbegshi}$notice"
  args+=(-jobname="$MAIN-author" -pdflatex="pdflatex %O '$pre\\input{%S}'")
fi
mkdir -p "$out"
"$ENGINE" run --rm -e openout_any=a -v "$PWD/$dir:/src:ro,Z" -v "$PWD/$out:/out:Z" -w /src "$IMAGE" \
  latexmk "${args[@]}" "$MAIN.tex"
