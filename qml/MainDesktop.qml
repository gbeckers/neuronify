import QtQuick 2.5
import QtQuick.Controls 2.1 as QQC1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.3
import QtQuick.Particles 2.0
import QtQuick.Window 2.1

import QtCharts 2.1
import QtMultimedia 5.5
import Qt.labs.settings 1.0
import Qt.labs.folderlistmodel 2.1
import Qt.labs.platform 1.0

import Neuronify 1.0
import CuteVersioning 1.0
import QtGraphicalEffects 1.0

import "qrc:/qml/backend"
import "qrc:/qml/controls"
import "qrc:/qml/hud"
import "qrc:/qml/io"
import "qrc:/qml/hud"
import "qrc:/qml/menus"
import "qrc:/qml/menus/filemenu"
import "qrc:/qml/menus/mainmenu"
import "qrc:/qml/tools"
import "qrc:/qml/store"
import "qrc:/qml/style"
import "qrc:/qml/ui"

Item {
    id: root

    property bool dragging: false
    property url currentSimulationFile

    state: "view"

    DownloadManager {
        id: _downloadManager
    }

    Neuronify {
        id: neuronify
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        clip: true
        autoPause: root.state != "view" && root.state != "creation"
        onBackgroundClicked: {
            itemModelLoader.source = ""
            propertiesPanel.revealed = false
        }
    }

    LeftMenu { // TODO rename to topmenu
        id: topMenu

        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        height: 72

        onNewClicked: {
            fileView.open("new")
        }

        onSaveRequested: {
            console.log("Considering", currentSimulationFile)
            if(Qt.resolvedUrl(currentSimulationFile) !== Qt.resolvedUrl("")) {
                neuronify.save(currentSimulationFile) // TODO hold name and description
                return
            }
            fileView.open("save")
        }

        onSaveAsRequested: {
            fileView.open("save")
        }

        onOpenRequested: {
            fileView.open("open")
        }

        onCommunityClicked: {
            fileView.open("community")
        }

        onAccountClicked: {
            fileView.open("account")
        }

        onSettingsClicked: {
            fileView.open("settings")
        }
    }

    FileView {
        id: fileView
        anchors.fill: parent
        revealed: false
        z: 99

        onSaveRequested: {
            currentSimulationFile = file
            neuronify.save(file, name, description)
        }

        onOpenRequested: {
            currentSimulationFile = file
            neuronify.open(file)
        }
    }

    HudShadow {
        id: leftMenuShadow
        anchors.fill: topMenu
        source: topMenu
        z: 38
    }

    Rectangle {
        id: itemMenu
        anchors {
            top: topMenu.bottom
            left: parent.left
            bottom: parent.bottom
        }
        color: "#e3eef9"
        width: 96
        z: 38

        Column {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 16
                leftMargin: 8
                rightMargin: 8
            }

            Repeater {
                id: itemListRepeater
                model: ListModel {
                    ListElement {
                        name: "Excitatory"
                        source: "qrc:/qml/neurons/LeakyNeuron.qml"
                        imageSource: "qrc:/images/neurons/leaky.png"
                        listSource: "qrc:/qml/hud/NeuronList.qml"
                    }
                    ListElement {
                        name: "Inhibitory"
                        listSource: "qrc:/qml/hud/InhibitoryNeuronList.qml"
                        source: "qrc:/qml/neurons/LeakyInhibitoryNeuron.qml"
                        imageSource: "qrc:/images/neurons/leaky_inhibitory.png"
                    }
                    ListElement  {
                        name: "Measurement"
                        listSource: "qrc:/qml/hud/MetersList.qml"
                        source: "qrc:/qml/meters/Voltmeter.qml"
                        imageSource: "qrc:/images/meters/voltmeter.png"
                    }
                    ListElement  {
                        name: "Generators"
                        source: "qrc:/qml/generators/CurrentClamp.qml"
                        imageSource: "qrc:/images/generators/current_clamp.png"
                        listSource: "qrc:/qml/hud/GeneratorsList.qml"
                    }
                    ListElement  {
                        name: "Annotation"
                        source: "qrc:/qml/annotations/Note.qml"
                        listSource: "qrc:/qml/hud/AnnotationsList.qml"
                        imageSource: "qrc:/images/categories/annotation.png"
                    }
                }

                TopCreationItem {
                    id: creationItem

                    parentWhenDragging: root
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    name: model.name
                    source: model.source
                    imageSource: model.imageSource
                    selected: Qt.resolvedUrl(itemModelLoader.source) === Qt.resolvedUrl(model.listSource)
                    onClicked: {
                        if(Qt.resolvedUrl(itemModelLoader.source) === Qt.resolvedUrl(model.listSource)) {
                            itemModelLoader.source = ""
                            return
                        }
                        itemModelLoader.source = model.listSource
                    }
                }
            }
        }

        Column {
            anchors {
                left: parent.left
                bottom: parent.bottom
                right: parent.right
                leftMargin: 8
                rightMargin: 8
                bottomMargin: 16
            }

            spacing: 8

            Label {
                id: selectedLabel
                anchors {
                    left: parent.left
                    right: parent.right
                }

                wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                text: ""
                font.pixelSize: 12
                horizontalAlignment: Qt.AlignHCenter
                color: Style.mainDesktop.text.color
                states: State {
                    when: neuronify.activeObject ? true : false
                    PropertyChanges {
                        target: selectedLabel
                        text: neuronify.activeObject.name
                    }
                }
            }

            MaterialButton {
                id: propertiesButton
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: width

                icon.name: "settings_input_component"
                icon.category: "action"
                color: Material.primary
                text: "Properties"

                onClicked: {
                    propertiesPanel.revealed = !propertiesPanel.revealed
                }

                states: State {
                    when: neuronify.activeObject ? false : true
                    PropertyChanges {
                        target: propertiesButton
                        opacity: 0.0
                        enabled: false
                    }
                }
            }
        }
    }

    HudShadow {
        anchors.fill: itemMenu
        source: itemMenu
        z: 29
    }

    Rectangle {
        id: itemSubMenu
        anchors {
            top: topMenu.bottom
            left: itemMenu.right
        }
        width: 240
        height: itemListView.height + 36
        visible: Qt.resolvedUrl(itemModelLoader.source) !== Qt.resolvedUrl("") ? true : false
        color: Material.background

        Flow {
            id: itemListView
            property int currentIndex: 0
            property alias listSource: itemModelLoader.source
            property int rows: Math.floor(parent.height / 96)
            property int columns: 2
            property real itemHeight: (height - spacing * (rows - 1)) / rows - 1
            property real itemWidth: (width - spacing * (columns - 1)) / columns - 1

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: 18
                rightMargin: 18
                topMargin: 18
            }

            spacing: 8

            Loader {
                id: itemModelLoader
                //                source: model.listSource
            }

            Repeater {
                model: itemModelLoader.item

                CreationItem {
                    id: creationItem2

                    //                                    width: itemListView.itemWidth
                    width: itemListView.itemWidth

                    parentWhenDragging: root

                    name: model.name
                    description: model.description
                    source: model.source
                    imageSource: model.imageSource

                    onDragActiveChanged: {
                        if(dragActive) {
                            root.dragging = true
                        } else {
                            root.dragging = false
                        }
                        showInfoPanelTimer.stop()
                    }
                }
            }
        }
    }

    HudShadow {
        anchors.fill: itemSubMenu
        source: itemSubMenu
        visible: itemSubMenu.visible
        z: 20
    }

    PropertiesPanel {
        id: propertiesPanel

        property bool revealed: false

        anchors {
            left: itemMenu.right
            bottom: parent.bottom
        }
        activeObject: neuronify.activeObject

        states: [
            State {
                when: !propertiesPanel.revealed
                AnchorChanges {
                    target: propertiesPanel
                    anchors {
                        left: undefined
                        right: itemMenu.left
                    }
                }
            }
        ]

        transitions: [
            Transition {
                AnchorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        ]
    }

    HudShadow {
        anchors.fill: propertiesPanel
        source: propertiesPanel
        verticalOffset: -1
    }

    states: [
        State {
            name: "view"
            PropertyChanges { target: fileView; state: "hidden" }
            //            PropertyChanges { target: infoPanel; state: "hidden" }
        },
        State {
            name: "creation"
            extend: "view"
            PropertyChanges { target: topMenu; state: "small" }
            PropertyChanges { target: itemMenu; state: "" }
        },
        State {
            name: "welcome"
            extend: "view"
            PropertyChanges { target: fileView; state: "" }
            PropertyChanges { target: leftMenuShadow; opacity: 0.0 }
            PropertyChanges { target: topMenu; state: "small" }
        },
        State {
            name: "projects"
            extend: "view"
        },
        State {
            name: "help"
            extend: "view"
        }

    ]

    transitions: [
        Transition {
            animations: [
                animateCreation,
            ]
        },
        Transition {
            to: "community"
            animations: [
                animateCreation,
                animateCommunityTextIn
            ]
        },
        Transition {
            from: "community"
            animations: [
                animateCreation,
                animateCommunityTextOut
            ]
        }
    ]

    ParallelAnimation {
        id: animateCreation
        NumberAnimation {
            properties: "anchors.leftMargin"
            duration: 400
            easing.type: Easing.InOutQuad
        }
        ColorAnimation {
            properties: "color"
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: animateCommunityTextIn
        PauseAnimation {
            duration: 400
        }
    }
    SequentialAnimation {
        id: animateCommunityTextOut
        PauseAnimation {
            duration: 200
        }
    }
}
