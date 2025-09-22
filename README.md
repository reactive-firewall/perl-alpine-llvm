# About *Perl‑Alpine‑LLVM*

`Perl‑Alpine‑LLVM` builds **Perl 5.** *X.Y* (default 5.43.2) from source on **Alpine Linux** using the **LLVM/Clang** toolchain **exclusively** (no GCC).  

## Key features
- **Thread‑enabled** (`-Dusethreads`) and linked with shared libraries (`-Duseshrplib`) for high‑performance workloads.  
- **Minimal runtime** – only the compiled interpreter and required musl libraries are kept; final image < 80 MB.  
- **Version‑transparent** – installs `perl5.<major>.<minor>` and creates a stable `perl` symlink, matching Docker’s official Perl naming scheme.  
- **Reproducible builds** – source tarballs are SHA‑256 verified; clang’s deterministic output ensures consistent images.  
- **Extensible** – CI pipelines and documentation for adding extra CPAN modules while preserving the lean footprint.

## Why use this image?
- Need a **lightweight** container for micro‑services or CI jobs.  
- Prefer the **musl** C library and **clang** compiler for security or licensing reasons.  
- Want a **drop‑in replacement** for the official Debian‑based Perl images with the same entrypoint, but on Alpine.

The repository contains the Dockerfile, GitHub Actions workflows for automated builds, and usage examples.
