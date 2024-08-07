use del.nu
use dump.nu
use env.nu
use write.nu

# clean temporary directories, caches and installation files
export def main []: nothing -> nothing {
    write debug "Deleting preinstallation script." clean
    del force /preinstall

    write debug "Deleting .empty files." clean
    del force **/.empty

    write debug "Deleting caches." clean
    del force /tmp/* /var/lib/apt/lists/* /usr/share/man

    if (env check PUBLISHING) {
        write debug "Deleting test files." clean
        del force /etc/nu/scripts/tests
    }
}
