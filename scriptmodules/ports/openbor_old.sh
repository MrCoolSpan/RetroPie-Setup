#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openbor_old"
rp_module_desc="OpenBOR - Beat 'em Up Game Engine"
rp_module_help="OpenBOR games need to be extracted to function properly. Place your pak files in $romdir/ports/openbor and then run $rootdir/ports/openbor/extract.sh. When the script is done, your original pak files will be found in $romdir/ports/openbor/originals and can be deleted."
rp_module_licence="BSD https://raw.githubusercontent.com/rofl0r/openbor/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!mali !kms"

function depends_openbor() {
    getDepends libsdl1.2-dev libsdl-gfx1.2-dev libogg-dev libvorbisidec-dev libvorbis-dev libpng-dev zlib1g-dev yasm
}

function sources_openbor() {
    if uname -m |grep "x86_64"; then
    gitPullOrClone "$md_build" https://github.com/MrCoolSpan/openbor.git
    else
    gitPullOrClone "$md_build" https://github.com/rofl0r/openbor.git
    fi
}

function build_openbor() {
    if uname -m |grep "x86_64"; then
    cd "$md_build/engine"
    sed -i 's/-Werror//g' Makefile 
    ./build.sh 4 amd64
    cd "$md_build/tools/borpak/source/"
    chmod 755 build.sh
    ./build.sh lin
    else
    local params=()
    ! isPlatform "x11" && params+=(NO_GL=1)
    make clean
    make "${params[@]}"
    cd "$md_build/tools/borpak/"
    ./build-linux.sh
    md_ret_require="$md_build/OpenBOR"
    fi
}

function install_openbor() {
    if uname -m |grep "x86_64"; then
      md_ret_files=(
       'engine/releases/LINUX_AMD64/OpenBOR/OpenBOR'
       'tools/borpak/source/borpak'
       'tools/unpack.sh'
    )
       else
       md_ret_files=(
       'OpenBOR'
       'tools/borpak/borpak'
       'tools/unpack.sh'
    )
    fi
}

function configure_openbor() {
    addPort "$md_id" "openbor" "OpenBOR - Beats of Rage Engine" "pushd $md_inst; $md_inst/OpenBOR; popd"

    mkRomDir "ports/$md_id"

cat >"$md_inst/extract.sh" <<_EOF_
#!/bin/bash
PORTDIR="$md_inst"
BORROMDIR="$romdir/ports/$md_id"
mkdir \$BORROMDIR/original/
mkdir \$BORROMDIR/original/borpak/
mv \$BORROMDIR/*.pak \$BORROMDIR/original/
cp \$PORTDIR/unpack.sh \$BORROMDIR/original/
cp \$PORTDIR/borpak \$BORROMDIR/original/borpak/
cd \$BORROMDIR/original/
for i in *.pak
do
  CURRENTFILE=\`basename "\$i" .pak\`
  ./unpack.sh "\$i"
  mkdir "\$CURRENTFILE"
  mv data/ "\$CURRENTFILE"/
  mv "\$CURRENTFILE"/ ../
done
echo "Your games are extracted and ready to be played. Your originals are stored safely in $BORROMDIR/original/ but they won't be needed anymore. Everything within it can be deleted."
_EOF_

    chmod +x "$md_inst/extract.sh"
    chmod +x "$md_inst/unpack.sh"
    chown -R "$user":"$user" "$md_inst/extract.sh"
    chown -R "$user":"$user" "$md_inst/unpack.sh"
    chown -R "$user":"$user" "$md_inst"

    local dir
    for dir in ScreenShots Logs Saves; do
        mkUserDir "$md_conf_root/$md_id/$dir"
        ln -snf "$md_conf_root/$md_id/$dir" "$md_inst/$dir"
    done

    ln -snf "$romdir/ports/$md_id" "$md_inst/Paks"
}
