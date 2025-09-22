# ------------------------------------------------------------
# Builder stage – compile Perl with clang on Alpine (musl)
# ------------------------------------------------------------
# Use MIT licensed Alpine as the base image for the build environment
# shellcheck disable=SC2154
FROM --platform="linux/${TARGETARCH}" alpine:latest AS builder

# ---- build‑time arguments -------------------------------------------------
ARG PERL_VERSION=5.43.2
ARG PERL_SHA256=202dc989a29e461bef175dc23ac0ba0d7eef49ea10e1fefe696f19ede210dc29

# ---- install only clang/llvm toolchain and required libs -----------------
RUN apk add --no-cache \
        clang \
        clang-dev \
        llvm-dev \
        make \
        perl-dev \
        musl-dev \
        libintl \
        zlib \
        zlib-dev \
        bzip2 \
        bzip2-dev \
        xz \
        xz-dev \
        openssl \
        openssl-dev \
        curl \
        tar \
        patch \
        git

# ---- force clang as the compiler -----------------------------------------
ENV CC=clang CXX=clang++

# ---- download, verify and extract Perl source -----------------------------
WORKDIR /usr/src
RUN curl -fL "https://cpan.metacpan.org/authors/id/E/ET/ETHER/perl-${PERL_VERSION}.tar.gz" \
        -o "perl-${PERL_VERSION}.tar.gz" \
    && echo "${PERL_SHA256}  perl-${PERL_VERSION}.tar.gz" | sha256sum -c - \
    && tar --strip-components=1 -xzf "perl-${PERL_VERSION}.tar.gz" \
    && rm "perl-${PERL_VERSION}.tar.gz"

# ---- compute architecture values (musl) -----------------------------------
#   alpineArch = "<machine>-linux-musl"   (e.g., x86_64-linux-musl)
#   archBits   = 64 or 32
#   archFlag   = -Duse64bitall (64‑bit) or -Duse64bitint (32‑bit)
RUN alpineArch="$(uname -m)-linux-musl" \
    && archBits="$(getconf LONG_BIT)" \
    && archFlag="$([ "$archBits" = '64' ] && echo '-Duse64bitall' || echo '-Duse64bitint')" \
    && ./Configure -Darchname="${alpineArch}" "${archFlag}" \
        -Dusethreads -Duseshrplib -Dvendorprefix=/usr/local \
        -Dusedevel -Dversiononly=undef -des \
    && make -j$(nproc) \
    && TEST_JOBS=$(nproc) make test_harness \
    && make install \
    # ---- create a stable `perl` symlink ----
    && ln -s "$(which perl5.${PERL_VERSION%.*})" /usr/local/bin/perl

# ------------------------------------------------------------
# Runtime stage – minimal Alpine with the compiled Perl
# ------------------------------------------------------------
# Use MIT licensed Alpine as the base image for the final environment
# shellcheck disable=SC2154
FROM --platform="linux/${TARGETARCH}" alpine:latest AS perl-alpine-llvm

COPY --from=builder /usr/local /usr/local

ENV PATH="/usr/local/bin:/usr/local/sbin:${PATH}"

# Minimal runtime libraries (no compilers, no dpkg)
RUN apk add --no-cache \
        libintl \
        zlib \
        bzip2 \
        xz \
        openssl

WORKDIR /usr/src/app

# Default entrypoint – generic `perl` now points to the versioned binary
CMD ["perl", "-de0"]
