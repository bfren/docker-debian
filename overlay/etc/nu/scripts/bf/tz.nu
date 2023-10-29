use fs.nu
use write.nu

# Set the container's timezone
export def main [
    tz: string  # The name of the timezone to use
] {
    # get path to timezone definiton
    let zone = $"/usr/share/zoneinfo/($tz)"
    let localtime = "/etc/localtime"

    # check the specified timezone exists
    if ($zone | fs is_not_file) { write error $"($tz) is not a recognise timezone." tz }

    # copy timezone info
    write $"Setting timezone to ($tz)." tz
    rm --force $localtime
    ^ln $zone $localtime

    # return nothing
    return
}
