use del.nu
use dump.nu
use fs.nu
use write.nu

# path to current timezone info
const localtime = "/etc/localtime"

# path to file containing name of current timezone
const timezone = "/etc/timezone"

# path to installed timezone definition files
const zoneinfo = "/usr/share/zoneinfo"

# Set the container's timezone
export def main [
    tz: string  # The name of the timezone to use
]: nothing -> nothing {
    # if current timezone is already $tz, do nothing
    let current = fs read --quiet $timezone
    if $current == $tz {
        write $"Timezone is already ($tz)." tz
        return
    }

    # get path to timezone definiton
    let zone = $"/($zoneinfo)/($tz)"

    # check the specified timezone exists
    if ($zone | fs is_not_file) { write error $"($tz) is not a recognise timezone." tz }

    # copy timezone info
    write $"Setting timezone to ($tz)." tz
    rm --force $localtime
    ^ln $zone $localtime
    $tz | save --force $timezone

    # return nothing
    return
}

# Return the name of the current timezone
export def current []: nothing -> string { fs read $timezone }
