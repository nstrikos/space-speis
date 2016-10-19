import QtQuick 2.5
import QtCanvas3D 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import "content"

ApplicationWindow {
    id: mainview
    visible: true
    visibility: Window.Maximized
    FontLoader { id: myCustomFont; source: "qrc:/fonts/LiberationSans-Regular.ttf" }


    title: qsTr("Space - Speis")
    color: "#000000"
    opacity: 1

/* This section is not needed */
    property bool dragging
    property int userInfoWidth
    userInfoWidth: 250

    function setDragging(value) {
        mainview.dragging = value;
    }

/* Up till here   */

    Rectangle {
        color: "#212126"
        anchors.fill: parent
    }

    toolBar: BorderImage {
        border.bottom: 8
        source: "images/toolbar.png"
        width: parent.width
        height: 50

        Rectangle {
            id: backButton
            width: opacity ? 60 : 0
            anchors.left: parent.left
            anchors.leftMargin: 20
            opacity: stackView.depth > 1 ? 1 : 0
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
            height: 60
            radius: 4
            color: backmouse.pressed ? "#222" : "transparent"
            Behavior on opacity { NumberAnimation{} }
            Image {
                anchors.verticalCenter: parent.verticalCenter
                source: "images/navigation_previous_item.png"
            }
            MouseArea {
                id: backmouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: stackView.pop()
            }
        }

        Text {
            font.pixelSize: 36
            Behavior on x { NumberAnimation{ easing.type: Easing.OutCubic} }
            x: backButton.x + backButton.width + 20
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            text: "Space - Speis"
        }
    }

    ListModel {
        id: pageModel
        ListElement {
            title: "Δες το ζώδιο της Σελήνης"
            page: "content/lunar.qml"
        }
        ListElement {
            title: "Conic sections in 3D"
            page: "content/lunar.qml"
        }        
        ListElement {
            title: "Two body problem"
            page: "content/lunar.qml"
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        // Implements back key navigation
        focus: true
        Keys.onReleased: if (event.key === Qt.Key_Back && stackView.depth > 1) {
                             stackView.pop();
                             event.accepted = true;
                         }

        initialItem: Item {
            width: parent.width
            height: parent.height
            ListView {
                model: pageModel
                anchors.fill: parent
                delegate: AndroidDelegate {
                    text: title
                    onClicked: stackView.push(Qt.resolvedUrl(page))
                }
            }
        }
    }
}

