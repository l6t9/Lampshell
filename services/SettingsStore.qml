pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string path: {
        const base = Quickshell.env("XDG_STATE_HOME")
            || (Quickshell.env("HOME") + "/.local/state");
        return base + "/lampshell/settings.json";
    }

    readonly property var defaults: ({
        dnd: false,
        defaultExpireTimeout: 5000,
        fullscreenExpireTimeout: 2000,
        musicPlayerWidgetEnabled: false,
        caffeine: false,
        nightLightEnabled: false,
        nightLightTemperature: 4500,
        nightLightBackend: "auto",
        lockAfterMin: 15,
        screenOffAfterMin: 10,
        suspendAfterMin: 0,
        dockPosition: "left",
        barPosition: "top",
        uiScale: 1.0,
        dashboardEnabled: true,
        weatherLocation: "",
        weatherUnits: "metric",
        locale: "",
        use24Hour: false,
        timeZone: "",
        overlayEffectsManaged: true,
        keybindsManaged: true,
        themeTargetgtk4: true,
        themeTargetgtk3: true,
        themeTargethypr: true,
        themeTargethyprScheme: true,
        favouriteApps: []
    })

    property var values: root.defaults
    property bool loaded: false
    readonly property string lastError: ""

    FileView {
        id: file
        path: root.path
        printErrors: false
        watchChanges: true

        onLoaded: {
            let merged = Object.assign({}, root.defaults);
            try {
                const parsed = JSON.parse(text());
                if (parsed && typeof parsed === "object")
                    merged = Object.assign(merged, parsed);
            } catch (e) {
                console.warn("lampshell: settings.json is not valid JSON, using defaults:", e);
            }
            root.values = merged;
            root.loaded = true;
        }

        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                debounce.restart();
            root.loaded = true;
        }

        onFileChanged: reload()
    }

    Timer {
        id: debounce
        interval: 400
        onTriggered: file.setText(JSON.stringify(root.values, null, 2) + "\n")
    }

    function get(key) {
        return root.values[key];
    }

    function set(key, value) {
        if (root.values[key] === value)
            return;
        const next = Object.assign({}, root.values);
        next[key] = value;
        root.values = next;
        debounce.restart();
    }

    function toggle(key) {
        root.set(key, !root.values[key]);
    }

    function reset() {
        root.values = root.defaults;
        debounce.restart();
    }

    IpcHandler {
        target: "settings"

        function get(key: string): string {
            const v = root.get(key);
            return v === undefined ? "" : String(v);
        }

        function set(key: string, value: string): void {
            const def = root.defaults[key];
            let parsed = value;
            if (typeof def === "boolean")
                parsed = value === "true" || value === "1";
            else if (typeof def === "number")
                parsed = Number(value);
            root.set(key, parsed);
        }

        function keys(): string {
            return Object.keys(root.values).join("\n");
        }

        function reset(): void {
            root.reset();
        }
    }
}
