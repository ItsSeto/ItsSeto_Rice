import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root

    property bool menuVisible: false
    property bool powerMenuVisible: false
    property bool wallpaperMenuVisible: false
    property string selectedWallpaper: ""

    function run(command) {
        Quickshell.execDetached({
            command: ["sh", "-c", command]
        })

        root.menuVisible = false
        root.powerMenuVisible = false
        root.wallpaperMenuVisible = false
    }

    function openPowerMenu() {
        root.powerMenuVisible = true
        root.wallpaperMenuVisible = false
    }

    function openWallpaperMenu() {
        root.wallpaperMenuVisible = true
        root.powerMenuVisible = false
    }

    function backToMain() {
        root.powerMenuVisible = false
        root.wallpaperMenuVisible = false
    }

    function setWallpaper(path) {
    console.log("Setting wallpaper:", path)

    root.selectedWallpaper = path

    Quickshell.execDetached([
        "awww",
        "img",
        path,
        "--transition-type",
        "any",
        "--transition-duration",
        "1"
    ])

    root.menuVisible = false
    root.wallpaperMenuVisible = false
    root.powerMenuVisible = false
}

    IpcHandler {
        target: "profileMenu"

        function toggle(): void {
            root.menuVisible = !root.menuVisible
            root.powerMenuVisible = false
            root.wallpaperMenuVisible = false
        }

        function show(): void {
            root.menuVisible = true
            root.powerMenuVisible = false
            root.wallpaperMenuVisible = false
        }

        function hide(): void {
            root.menuVisible = false
            root.powerMenuVisible = false
            root.wallpaperMenuVisible = false
        }
    }

    FolderListModel {
        id: wallpaperModel

        folder: "file:///home/setojp/Pictures/Wallpapers"

        nameFilters: [
            "*.png",
            "*.jpg",
            "*.jpeg",
            "*.webp"
        ]

        showDirs: false
    }

    PanelWindow {
        id: panel

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        color: "transparent"

        focusable: root.menuVisible
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        visible: root.menuVisible

        WlrLayershell.keyboardFocus: root.menuVisible
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.menuVisible = false
                root.powerMenuVisible = false
                root.wallpaperMenuVisible = false
            }

            // ═════════════════════════════════════
            // MAIN MENU
            // ═════════════════════════════════════

            Rectangle {
                id: mainMenu

                visible: !root.powerMenuVisible && !root.wallpaperMenuVisible

                width: 460
                height: 610

                anchors.centerIn: parent

                radius: 24
                color: "#282c34"

                border.width: 1
                border.color: "#3a3f4b"

                MouseArea {
                    anchors.fill: parent

                    onClicked: mouse.accepted = true
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 30
                    }

                    spacing: 0

                    // ───────────── Avatar ─────────────

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter

                        width: 92
                        height: 92

                        radius: 46

                        color: "#3a3f4b"

                        Image {
                            anchors.fill: parent

                            source: "file:///home/setojp/.config/waybar/profile.png"

                            fillMode: Image.PreserveAspectCrop
                            smooth: true

                            layer.enabled: true

                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: 92
                                    height: 92
                                    radius: 46
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: 14
                    }

                    // ───────────── Name ─────────────

                    Text {
                        Layout.fillWidth: true

                        text: "Seto"

                        color: "#f5f0f5"

                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        font.pixelSize: 20

                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        Layout.preferredHeight: 4
                    }

                    Text {
                        Layout.fillWidth: true

                        text: "CachyOS • Hyprland"

                        color: "#9aa0aa"

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12

                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        Layout.preferredHeight: 25
                    }

                    // ───────────── Apps / Settings ─────────────

                    RowLayout {
                        Layout.fillWidth: true

                        spacing: 10

                        MenuButton {
                            Layout.fillWidth: true

                            icon: "󰍉"
                            label: "Apps"

                            onClicked: root.run("~/.config/rofi/launchers/type-2/launcher.sh")
                        }

                        MenuButton {
                            Layout.fillWidth: true

                            icon: "󰒓"
                            label: "Settings"

                            onClicked: root.run(
                                "nwg-look 2>/dev/null || kitty -e sh -c 'echo Install nwg-look first; read'"
                            )
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    // ───────────── Files / Terminal ─────────────

                    RowLayout {
                        Layout.fillWidth: true

                        spacing: 10

                        MenuButton {
                            Layout.fillWidth: true

                            icon: "󰉋"
                            label: "Files"

                            onClicked: root.run("dolphin")
                        }

                        MenuButton {
                            Layout.fillWidth: true

                            icon: ""
                            label: "Terminal"

                            onClicked: root.run("kitty")
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    // ───────────── Wallpapers ─────────────

                    MenuButton {
                        Layout.fillWidth: true

                        icon: "󰸉"
                        label: "Wallpapers"

                        onClicked: root.openWallpaperMenu()
                    }

                    Item {
                        Layout.preferredHeight: 25
                    }

                    // ───────────── Divider ─────────────

                    Rectangle {
                        Layout.fillWidth: true

                        height: 1

                        color: "#3a3f4b"
                    }

                    Item {
                        Layout.preferredHeight: 14
                    }

                    // ───────────── Power ─────────────

                    Rectangle {
                        Layout.fillWidth: true

                        height: 52

                        radius: 14

                        color: powerMouse.containsMouse
                            ? "#3a3f4b"
                            : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        Row {
                            anchors.centerIn: parent

                            spacing: 10

                            Text {
                                text: "󰐥"

                                color: "#f38ba8"

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 18
                            }

                            Text {
                                text: "Power"

                                color: "#f38ba8"

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                            }
                        }

                        MouseArea {
                            id: powerMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: {
                                root.openPowerMenu()
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }


            // ═════════════════════════════════════
            // WALLPAPER MENU
            // ═════════════════════════════════════

            Rectangle {
                id: wallpaperMenu

                visible: root.wallpaperMenuVisible

                width: 760
                height: 680

                anchors.centerIn: parent

                radius: 24
                color: "#282c34"

                border.width: 1
                border.color: "#3a3f4b"

                MouseArea {
                    anchors.fill: parent

                    onClicked: mouse.accepted = true
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 28
                    }

                    spacing: 0

                    // ───────────── Header ─────────────

                    Text {
                        Layout.fillWidth: true

                        text: "󰸉  Wallpapers"

                        color: "#f5f0f5"

                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        font.pixelSize: 22

                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        Layout.preferredHeight: 5
                    }

                    Text {
                        Layout.fillWidth: true

                        text: wallpaperModel.count === 0
                            ? "No wallpapers found"
                            : wallpaperModel.count + " wallpapers"

                        color: "#9aa0aa"

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12

                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        Layout.preferredHeight: 20
                    }

                    // ───────────── Thumbnail Grid ─────────────

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        radius: 16

                        color: "#232731"

                        clip: true

                        GridView {
                            id: wallpaperGrid

                            anchors {
                                fill: parent
                                margins: 14
                            }

                            cellWidth: 170
                            cellHeight: 135

                            model: wallpaperModel

                            clip: true

                            delegate: Rectangle {
                                width: 158
                                height: 120

                                radius: 12

                                color: root.selectedWallpaper === model.filePath
                                    ? "#f4a6c1"
                                    : "#323640"

                                border.width: root.selectedWallpaper === model.filePath
                                    ? 2
                                    : 1

                                border.color: root.selectedWallpaper === model.filePath
                                    ? "#f4a6c1"
                                    : "#3a3f4b"

                                Image {
                                    id: thumbnail

                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                        topMargin: 5
                                        leftMargin: 5
                                        rightMargin: 5
                                    }

                                    height: 82

                                    source: model.fileUrl

                                    fillMode: Image.PreserveAspectCrop

                                    asynchronous: true
                                    cache: true
                                    smooth: true

                                    Rectangle {
                                        anchors.fill: parent

                                        radius: 8

                                        color: "transparent"

                                        border.width: 1
                                        border.color: "#3a3f4b"
                                    }
                                }

                                Text {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        bottom: parent.bottom
                                        leftMargin: 8
                                        rightMargin: 8
                                        bottomMargin: 7
                                    }

                                    text: model.fileBaseName

                                    color: root.selectedWallpaper === model.filePath
                                        ? "#282c34"
                                        : "#f5f0f5"

                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10

                                    elide: Text.ElideRight

                                    horizontalAlignment: Text.AlignHCenter
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    hoverEnabled: true

                                    onClicked: {
                                        root.setWallpaper(model.filePath)
                                    }

                                    onEntered: {
                                        parent.scale = 1.03
                                    }

                                    onExited: {
                                        parent.scale = 1.0
                                    }
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            visible: wallpaperModel.count === 0

                            text: "󰸉\n\nPut wallpapers in:\n~/Pictures/Wallpapers"

                            color: "#9aa0aa"

                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13

                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Item {
                        Layout.preferredHeight: 16
                    }

                    // ───────────── Back ─────────────

                    Rectangle {
                        Layout.fillWidth: true

                        height: 48

                        radius: 14

                        color: wallpaperBackMouse.containsMouse
                            ? "#3a3f4b"
                            : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        Row {
                            anchors.centerIn: parent

                            spacing: 9

                            Text {
                                text: "󰁍"

                                color: "#9aa0aa"

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                            }

                            Text {
                                text: "Back"

                                color: "#9aa0aa"

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }
                        }

                        MouseArea {
                            id: wallpaperBackMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: {
                                root.backToMain()
                            }
                        }
                    }
                }
            }


            // ═════════════════════════════════════
            // POWER MENU
            // ═════════════════════════════════════

            Rectangle {
                id: powerMenu

                visible: root.powerMenuVisible

                width: 460
                height: 610

                anchors.centerIn: parent

                radius: 24
                color: "#282c34"

                border.width: 1
                border.color: "#3a3f4b"

                MouseArea {
                    anchors.fill: parent

                    onClicked: mouse.accepted = true
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 30
                    }

                    spacing: 0

                    Text {
                        Layout.fillWidth: true

                        text: "Power"

                        color: "#f5f0f5"

                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        font.pixelSize: 22

                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        Layout.preferredHeight: 6
                    }

                    Text {
                        Layout.fillWidth: true

                        text: "What would you like to do?"

                        color: "#9aa0aa"

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12

                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        Layout.preferredHeight: 28
                    }

                    PowerButton {
                        Layout.fillWidth: true

                        icon: "󰐥"
                        label: "Shutdown"
                        description: "Turn off the computer"

                        iconColor: "#f38ba8"

                        onClicked: {
                            root.run("systemctl poweroff")
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    PowerButton {
                        Layout.fillWidth: true

                        icon: "󰜉"
                        label: "Reboot"
                        description: "Restart the computer"

                        iconColor: "#f9e2af"

                        onClicked: {
                            root.run("systemctl reboot")
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    PowerButton {
                        Layout.fillWidth: true

                        icon: "󰒲"
                        label: "Sleep"
                        description: "Suspend the computer"

                        iconColor: "#89b4fa"

                        onClicked: {
                            root.run("systemctl suspend")
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    PowerButton {
                        Layout.fillWidth: true

                        icon: "󰤄"
                        label: "Hibernate"
                        description: "Hibernate the computer"

                        iconColor: "#cba6f7"

                        onClicked: {
                            root.run("systemctl hibernate")
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    PowerButton {
                        Layout.fillWidth: true

                        icon: "󰌾"
                        label: "Lock"
                        description: "Lock your session"

                        iconColor: "#a6e3a1"

                        onClicked: {
                            root.run(
                                "command -v hyprlock >/dev/null && hyprlock || loginctl lock-session"
                            )
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    PowerButton {
                        Layout.fillWidth: true

                        icon: "󰗽"
                        label: "Logout"
                        description: "Exit Hyprland"

                        iconColor: "#fab387"

                        onClicked: {
                            root.run("hyprctl dispatch exit")
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        height: 48

                        radius: 14

                        color: backMouse.containsMouse
                            ? "#3a3f4b"
                            : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        Row {
                            anchors.centerIn: parent

                            spacing: 9

                            Text {
                                text: "󰁍"

                                color: "#9aa0aa"

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                            }

                            Text {
                                text: "Back"

                                color: "#9aa0aa"

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }
                        }

                        MouseArea {
                            id: backMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: {
                                root.backToMain()
                            }
                        }
                    }
                }
            }
        }
    }


    // ═══════════════════════════════════════════
    // MAIN MENU BUTTON
    // ═══════════════════════════════════════════

    component MenuButton: Rectangle {
        property string icon
        property string label

        signal clicked()

        height: 58

        radius: 14

        color: mouse.containsMouse
            ? "#f4a6c1"
            : "#3a3f4b"

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Row {
            anchors.centerIn: parent

            spacing: 9

            Text {
                text: icon

                color: mouse.containsMouse
                    ? "#282c34"
                    : "#f5f0f5"

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
            }

            Text {
                text: label

                color: mouse.containsMouse
                    ? "#282c34"
                    : "#f5f0f5"

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
            }
        }

        MouseArea {
            id: mouse

            anchors.fill: parent

            hoverEnabled: true

            onClicked: parent.clicked()
        }
    }


    // ═══════════════════════════════════════════
    // POWER BUTTON
    // ═══════════════════════════════════════════

    component PowerButton: Rectangle {
        property string icon
        property string label
        property string description
        property color iconColor: "#f5f0f5"

        signal clicked()

        height: 64

        radius: 14

        color: powerMouse.containsMouse
            ? "#3a3f4b"
            : "#323640"

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 18
                rightMargin: 18
            }

            spacing: 16

            Text {
                text: icon

                color: iconColor

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 22

                Layout.preferredWidth: 30

                horizontalAlignment: Text.AlignHCenter
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 2

                Text {
                    text: label

                    color: "#f5f0f5"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    text: description

                    color: "#9aa0aa"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }
            }
        }

        MouseArea {
            id: powerMouse

            anchors.fill: parent

            hoverEnabled: true

            onClicked: parent.clicked()
        }
    }
}
