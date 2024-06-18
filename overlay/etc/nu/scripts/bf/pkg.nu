use dump.nu
use handle.nu
use write.nu

# Perform a package action, capturing result and outputting any errors
def action [
    name: string
    description: string
    cmd: string
    args: list<string>
]: nothing -> nothing {
    # add pkg to the script name
    let script = $"pkg/($name)"

    # run apt-get update first
    let joined = $args | str join " "
    write debug $"($description): ($joined)." $script
    try {
        with-env { DEBIAN_FRONTEND: "noninteractive" } {
            ^apt-get update
            ^apt-get $cmd -y ...$args
        }
    } catch {
        write error $"Error ($description | str downcase) packages: ($joined)." $script
    }
}

# Use apk to install a list of packages
export def install [
    args: list<string>  # List of packages to add / arguments
]: nothing -> nothing {
    action "install" "Installing" "install" $args
}

# Use apk to remove a list of packages
export def remove [
    args: list<string>  # List of packages to delete / arguments
]: nothing -> nothing {
    action "remove" "Removing" "remove" $args
}

# Use apk to upgrade a list of packages
export def upgrade [
    args: list<string> = []  # List of packages to upgrade / arguments
]: nothing -> nothing {
    action "upgrade" "Upgrading" "upgrade" $args
}
