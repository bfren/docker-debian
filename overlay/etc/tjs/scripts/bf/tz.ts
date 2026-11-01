import * as fs from "./fs.ts";
import { handle } from "./handle.ts";
import * as sys from "./sys.ts";
import * as write from "./write.ts";

/** Path to current timezone info. */
const LOCALTIME = "/etc/localtime";

/** Path to file containing name of current timezone. */
const TIMEZONE = "/etc/timezone";

/** Path to installed timezone definition files - Debian keeps tzdata installed, so there is nothing to clean. */
const ZONEINFO = "/usr/share/zoneinfo";

/**
 * Set the container's timezone.
 *
 * @param name The name of the timezone to use.
 */
export async function set(name: string): Promise<void> {
    // if current timezone is already name, do nothing
    if ((await fs.read(TIMEZONE, { quiet: true })) == name) {
        write.info("tz", "Timezone is already %s.", name);
        return;
    }

    // check the specified timezone exists
    const $zone = `${ZONEINFO}/${name}`;
    if (await fs.isNotFile($zone)) write.error("tz", "%s is not a recognised timezone.", name);

    // link timezone info and write to file
    write.info("tz", "Setting timezone to %s.", name);
    await sys.remove(LOCALTIME).catch(() => { });
    await handle(["ln", $zone, LOCALTIME], { script: "tz", ignoreSuccess: true });
    await sys.writeTextFile(TIMEZONE, name);
}

/**
 * Return the name of the current timezone.
 */
export function current(): Promise<string> {
    return fs.read(TIMEZONE);
}
