#!/usr/bin/env bash
# Modified from Dockerfile from https://github.com/docker-library/gcc/blob/e17fd3097b743216f292e50ea8e84b3b3bcc4e53/8/Dockerfile

set -ex

GCC_VERSION=${1}

apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
		curl \
		dirmngr \
		dpkg-dev \
		flex \
		gnupg \
    wget \
;
rm -rf /var/lib/apt/lists/*


# 1024D/745C015A 1999-11-09 Gerald Pfeifer <gerald@pfeifer.com>
# 1024D/B75C61B8 2003-04-10 Mark Mitchell <mark@codesourcery.com>
# 1024D/902C9419 2004-12-06 Gabriel Dos Reis <gdr@acm.org>
# 1024D/F71EDF1C 2000-02-13 Joseph Samuel Myers <jsm@polyomino.org.uk>
# 2048R/FC26A641 2005-09-13 Richard Guenther <richard.guenther@gmail.com>
# 1024D/C3C45C06 2004-04-21 Jakub Jelinek <jakub@redhat.com>
GPG_KEYS="\
	B215C1633BCA0477615F1B35A5B3A004745C015A \
	B3C42148A44E6983B3E4CC0793FA9B1AB75C61B8 \
	90AA470469D3965A87A5DCB494D03953902C9419 \
	80F98B2E0DAB6C8281BDF541A7C8C3B2F71EDF1C \
	7F74F97C103468EE5D750B583AB00996FC26A641 \
	33C235A34C46AA3FFB293709A328C3A2C3C45C06 \
  "

for key in $GPG_KEYS; do
  gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$key" \
	|| gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" \
  || gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" \
  || gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key"
done

# https://gcc.gnu.org/mirrors.html
GCC_MIRRORS="\
		https://ftpmirror.gnu.org/gcc \
		https://bigsearcher.com/mirrors/gcc/releases \
		https://mirrors-usa.go-parts.com/gcc/releases \
		https://mirrors.concertpass.com/gcc/releases \
		http://www.netgull.com/gcc/releases \
    "

_fetch() {
	local fetch="$1"; shift;
	local file="$1"; shift;
	for mirror in $GCC_MIRRORS; do
		if curl -fL "$mirror/$fetch" -o "$file"; then
			return 0
		fi
	done
	echo >&2 "error: failed to download '$fetch' from several mirrors"
	return 1
}

_fetch "gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz.sig" 'gcc.tar.xz.sig' \
	|| _fetch "$GCC_VERSION/gcc-$GCC_VERSION.tar.xz.sig"
_fetch "gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz" 'gcc.tar.xz' \
	|| _fetch "$GCC_VERSION/gcc-$GCC_VERSION.tar.xz" 'gcc.tar.xz'
gpg --batch --verify gcc.tar.xz.sig gcc.tar.xz
mkdir -p /usr/src/gcc
tar -xf gcc.tar.xz -C /usr/src/gcc --strip-components=1
rm gcc.tar.xz*
cd /usr/src/gcc

# "download_prerequisites" pulls down a bunch of tarballs and extracts them,
# but then leaves the tarballs themselves lying around
./contrib/download_prerequisites
{ rm *.tar.* || true; }
# explicitly update autoconf config.guess and config.sub so they support more arches/libcs
for f in config.guess config.sub; do
	wget -O "$f" "https://git.savannah.gnu.org/cgit/config.git/plain/$f?id=7d3d27baf8107b630586c962c057e22149653deb"
# find any more (shallow) copies of the file we grabbed and update them too
	find -mindepth 2 -name "$f" -exec cp -v "$f" '{}' ';'
done

dir="$(mktemp -d)"
cd "$dir"

gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
/usr/src/gcc/configure --build="$gnuArch" --disable-multilib --enable-languages=c,c++,fortran,go
make -j "$(nproc)"
make install-strip
cd ..

rm -rf "$dir" /usr/src/gcc

# gcc installs .so files in /usr/local/lib64...
echo '/usr/local/lib64' > /etc/ld.so.conf.d/local-lib64.conf
ldconfig -v

# ensure that alternatives are pointing to the new compiler and that old one is no longer used
dpkg-divert --divert /usr/bin/gcc.orig --rename /usr/bin/gcc
dpkg-divert --divert /usr/bin/g++.orig --rename /usr/bin/g++
dpkg-divert --divert /usr/bin/gfortran.orig --rename /usr/bin/gfortran
update-alternatives --install /usr/bin/cc cc /usr/local/bin/gcc 999
