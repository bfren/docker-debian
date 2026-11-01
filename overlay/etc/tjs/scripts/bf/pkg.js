import { handle } from "./handle.js";
import * as write from "./write.js";
/** Globs of the package manager's caches, deleted by clean(). */
export const CACHES = ["/var/lib/apt/lists/*", "/usr/share/man"];
/**
 * Perform a package action, outputting any errors - apt-get update runs first so the package lists are current.
 *
 * @param name Name of the action.
 * @param description Description of the action for logs.
 * @param cmd The apt-get command to run.
 * @param args Command arguments.
 */
async function action(name, description, cmd, args) {
    const $script = `pkg/${name}`;
    const $joined = args.join(" ");
    write.debug($script, "%s: %s.", description, $joined);
    for (const $args of [["update"], [cmd, "-y", ...args]]) {
        await handle(["env", "DEBIAN_FRONTEND=noninteractive", "apt-get", ...$args], {
            script: $script,
            dumpResult: `${description} packages`,
            ignoreSuccess: true,
            onFailure: ($code, $err) => write.error($script, "Error %d %s packages: %s.\n%s", $code, description.toLowerCase(), $joined, $err)
        });
    }
}
/**
 * Use apt-get to install a list of packages.
 *
 * @param args List of packages to add / arguments.
 */
export function install(args) {
    return action("install", "Installing", "install", args);
}
/**
 * Use apt-get to remove a list of packages.
 *
 * @param args List of packages to delete / arguments.
 */
export function remove(args) {
    return action("remove", "Removing", "remove", args);
}
/**
 * Use apt-get to upgrade a list of packages.
 *
 * @param args List of packages to upgrade / arguments.
 */
export function upgrade(args = []) {
    return action("upgrade", "Upgrading", "upgrade", args);
}
