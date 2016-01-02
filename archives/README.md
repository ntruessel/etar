# Example Archives
## ustar Format
* devnode.tar: single device node (-> header only)
* link.tar: single symlink (-> header only)
* ustar.tar: complete archive of the doc folder
* error.tar: link.tar with header that has wrong checksum

## pax Format
* pax.tar: complete archive of the doc folder
* pax-error.tar: pax.tar with wrong mtime format
