#!/bin/bash -e
# vim: set ts=4 sw=4 sts=4 et :

if [ "$VERBOSE" -ge 2 -o "$DEBUG" == "1" ]; then
    set -x
fi

source "${SCRIPTSDIR}/vars.sh"
source "${SCRIPTSDIR}/distribution.sh"

##### '=========================================================================
debug ' Cleaning up...'
##### '=========================================================================

# ==============================================================================
# Execute any template flavor or sub flavor 'pre' scripts
# ==============================================================================
buildStep "${0}" "pre"

#### '-------------------------------------------------------------------------
info ' Cleaning up  any left over files from installation'
#### '-------------------------------------------------------------------------
chroot_cmd apt-get remove -y 'cryptsetup-initramfs' 'linux-image-*' 'linux-headers-*' 'linux-kbuild-*'
chroot_cmd apt-get autoremove -y
rm -rf "${INSTALLDIR}/var/cache/apt/archives"
rm -rf "${INSTALLDIR}/var/cache/apt/pkgcache.bin"
rm -rf "${INSTALLDIR}/var/cache/apt/srcpkgcache.bin"
rm -f "${INSTALLDIR}/etc/apt/sources.list.d/qubes-builder.list"
rm -rf "${INSTALLDIR}/${TMPDIR}"
rm -f "${INSTALLDIR}/var/lib/systemd/random-seed"
if [ "$DIST" == "jessie" ]; then
    rm -f "${INSTALLDIR}/var/lib/exim4/config.autogenerated"
    rm -f "${INSTALLDIR}/etc/mailname"
    sed -i /dc_other_hostnames=.*/d  "${INSTALLDIR}/etc/exim4/update-exim4.conf.conf" || true
    # The target files here contain paragraphs of varying length delimited by blank lines
    # These sed oneliners edit inplace to delete the whole paragraph containing the search term
    sed -i '/./{H;$!d};x;/dc_other_hostnames/d'  "${INSTALLDIR}/var/cache/debconf/config.dat" || true
    sed -i '/./{H;$!d};x;/exim4\/mailname/d'  "${INSTALLDIR}/var/cache/debconf/config.dat" || true
    sed -i '/./{H;$!d};x;/dc_other_hostnames/d'  "${INSTALLDIR}/var/cache/debconf/config.dat-old" || true
    sed -i '/./{H;$!d};x;/exim4\/mailname/d'  "${INSTALLDIR}/var/cache/debconf/config.dat-old" || true
fi
sed -i "s/`hostname`/$DIST/"  "${INSTALLDIR}/etc/hosts" || true

# ==============================================================================
# Execute any template flavor or sub flavor 'post' scripts
# ==============================================================================
buildStep "${0}" "post"
