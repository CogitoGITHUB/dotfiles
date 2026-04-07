pragma Singleton

import QtQuick
import Quickshell

Singleton {
    Logger {
        id: logger
        name: "Env"
    }

    function get(name: string): var {
        return Quickshell.env(`LOCK-SCREEN_${name}`);
    }

    function log(name: string, value: var, isDefault = false): void {
        logger.debug(`Env.LOCK-SCREEN_${name} = ${Utils.toStringTyped(value)}${isDefault ? " (Default)" : ""}`);
    }

    function processArray(raw: string): var {
        try {
            const components = raw.split(",").map(s => s.trim()).filter(s => s.length > 0);
            return {
                isSuccess: true,
                array: components
            };
        } catch (error) {
            logger.error(error);
            return {
                isSuccess: false,
                array: []
            };
        }
    }

    function getArray(name: string, fallback = []): var {
        const value = get(name);

        if (!value) {
            log(name, fallback, true);
            return fallback;
        }

        const result = processArray(value);

        if (!result.isSuccess) {
            logger.error(`Env.LOCK-SCREEN_${name} is invalid. Form must be LOCK-SCREEN_${name}=arg1,arg2,...`);
            return fallback;
        }

        log(name, result.array);
        return result.array;
    }
}
