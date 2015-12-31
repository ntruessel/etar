# ETAR
Eiffel compression library based on tar.

## Provided archives
The archive folder contains some archives:
* link.tar: single symlink (ustar format)
* devnode.tar: single blockdevice (ustar format)
* etar.tar: archive of the expamles directory of this repo (ustar format)
* pax.tar: archive of the doc directory of this repo (pax format)
* error.tar: same as etar.tar with corrupted checksum

Since some of these archives are rather large, they use git lfs
