import QtQuick 2.5
import QtCanvas3D 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

import "../javascript/lunar.js" as GLCode


Rectangle {
    id: mainview

    width: 1280
    height: 768
    color: "#000000"
    opacity: 1
    visible: true


    property bool dragging
    property bool autoRotate : false
    property bool relativeMotion : false
    property bool controlsVisible: true
    property int parametersItemWidth: 300
    property int analysisItemWidth: 300
    property double time: 0
    property double posX: 0
    property double posY: 0
    property double posZ: 0
    property double curr_time: 0
    property bool componentCompleted: false

    function setDragging(value) {
        mainview.dragging = value;
    }

    function mySlot(){
        var new_time = (new Date).getTime();
        var diff = (new_time - time);
        curr_time += 360000 * diff;
        time = new_time;
        var d = new Date(curr_time);
        console.log(d);
        _performCalculations.performCalculations(curr_time);
        posX = _getLunarX.getLunarX();
        posY = _getLunarY.getLunarY();
        posZ = _getLunarZ.getLunarZ();
        GLCode.setLunarPosition(posX, posY, posZ);
    }

    Timer {
        id: timer
        interval: 50
        running: true
        repeat: true
        onTriggered: mySlot()
    }

    SplitView {
        id: splitView
        anchors.fill: parent
        orientation: Qt.Horizontal

        Item {
            id: controlsItem
            width : mainview.width / 3
            Layout.maximumWidth: 200
            Layout.minimumWidth: 50

            NumberAnimation {
                id: controlsAnimation
                target: controlsItem
                properties: "width"
                to: mainview.width / 3
                duration: 500
            }

            NumberAnimation {
                id: controlsAnimation2
                target: controlsItem
                properties: "width"
                to: 50
                duration: 500
            }

            Flickable {
                id: flickable
                opacity: 1.0
                visible: true
                anchors.fill: parent
                flickableDirection: Flickable.VerticalFlick
                clip: true

                NumberAnimation {
                    id: showControlsAnimation
                    target: myItem
                    properties: "opacity"
                    to: 1.0
                    duration: 500
                }

                NumberAnimation {
                    id: hideControlsAnimation
                    target: myItem
                    properties: "opacity"
                    to: 0.0
                    duration: 500
                    onStopped: {
                        myItem.visible = false
                    }
                }

                Rectangle {
                    id: showControlsButton

                    NumberAnimation {
                        id: enlargeControlsButtonAnimation
                        target: showControlsButton
                        properties: "height"
                        to: 100
                        duration: 650
                    }

                    NumberAnimation {
                        id: shrinkControlsButtonAnimation
                        target: showControlsButton
                        properties: "height"
                        to: 50
                        duration: 650
                    }

                    color: "lightgrey"
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    radius: 10
                    width: parent.width
                    height: 50
                    Text {
                        id: showControlsButtonText
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "Hide controls"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (controlsVisible)
                            {
                                controlsVisible = false
                                hideControlsAnimation.start()
                                controlsAnimation2.start()
                                enlargeControlsButtonAnimation.start()
                                showControlsButtonText.text = "+"
                            }
                            else
                            {
                                controlsVisible = true
                                shrinkControlsButtonAnimation.start()
                                myItem.visible = true
                                showControlsAnimation.start()
                                controlsAnimation.start()
                                showControlsButtonText.text = "Hide controls"
                            }
                        }
                    }
                }

                Item {
                    id: myItem
                    anchors.top: showControlsButton.bottom
                    width: parent.width
                    anchors.bottom: parent.bottom
                    Rectangle {
                        id: restartButton
                        color: "lightgrey"
                        width: parent.width
                        radius: 10
                        height: 50
                        anchors.top: parent.top
                        anchors.topMargin: 20
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        Text {
                            id: restartButtonText
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Restart"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                GLCode.restart();
                            }
                        }
                    }
                    Rectangle {
                        id: relativeMotionButton
                        color: "lightgrey"
                        width: parent.width
                        radius: 10
                        height: 50
                        anchors.top: restartButton.bottom
                        anchors.topMargin: 20
                        Text {
                            id: relativeMotionButtonText
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Relative motion disabled"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (relativeMotion == true)
                                {
                                    relativeMotion = false;
                                    relativeMotionButtonText.text = "Relative motion disabled";
                                    relativeMotionButton.color = "lightgrey"
                                }
                                else
                                {
                                    relativeMotion = true;
                                    relativeMotionButtonText.text = "Relative motion enabled";
                                    relativeMotionButton.color = "lightblue"
                                }
                                GLCode.setRelativeMotion(relativeMotion);
                            }
                        }
                    }
                    Rectangle {
                        id: evaluateButton
                        color: "lightgrey"
                        width: parent.width
                        radius: 10
                        height: 50
                        anchors.top: relativeMotionButton.bottom
                        anchors.topMargin: 20
                        Text {
                            id: evaluateButtonText
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Evaluate"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var mass1 = m1Slider.value * 1e24;
                                var mass2 = m2Slider.value * 1e24;
                                var x1 = mass1XSlider.value;
                                var y1 = mass1YSlider.value;
                                var z1 = mass1ZSlider.value;
                                var x2 = mass2XSlider.value;
                                var y2 = mass2YSlider.value;
                                var z2 = mass2ZSlider.value;
                                var velx1 = m1VelXSlider.value;
                                var vely1 = m1VelYSlider.value;
                                var velz1 = m1VelZSlider.value;
                                var velx2 = m2VelXSlider.value;
                                var vely2 = m2VelYSlider.value;
                                var velz2 = m2VelZSlider.value;
                                GLCode.evaluate(mass1, mass2, x1, y1, z1, x2, y2, z2,
                                                velx1, vely1, velz1, velx2, vely2, velz2);
                            }
                        }
                    }
                    Rectangle {
                        id: parametersButton
                        color: "lightgrey"
                        radius: 10
                        width: parent.width
                        height: 50
                        anchors.top: evaluateButton.bottom
                        anchors.topMargin: 20
                        Text {
                            id: parametersButtonText
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Show parameters"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (parametersItem.width == 0)
                                {
                                    parametersShowAnimation.start()
                                    //parametersButton.color = "lightblue"
                                }
                                else
                                {
                                    parametersItemWidth = parametersItem.width
                                    parametersHideAnimation.start()
                                    //parametersButton.color = "lightgrey"
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: analysisButton
                        color: "lightgrey"
                        radius: 10
                        width: parent.width
                        height: 50
                        anchors.top: parametersButton.bottom
                        anchors.topMargin: 20
                        Text {
                            id: analysisButtonText
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Show analysis"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (analysisItem.width == 0)
                                {
                                    analysisShowAnimation.start()
                                    //parametersButton.color = "lightblue"
                                }
                                else
                                {
                                    analysisItemWidth = analysisItem.width
                                    analysisHideAnimation.start()
                                    //parametersButton.color = "lightgrey"
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: autoRotateButton
                        radius: 10
                        color: "lightgrey"
                        width: parent.width
                        height: 50
                        anchors.top: analysisButton.bottom
                        anchors.topMargin: 20
                        Text {
                            id: autoRotateButtonText
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Auto rotate disabled"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (autoRotate == true)
                                {
                                    autoRotate = false;
                                    autoRotateButtonText.text = "Auto rotate disabled";
                                    autoRotateButton.color = "lightgrey"
                                }
                                else
                                {
                                    autoRotate = true;
                                    autoRotateButtonText.text = "Auto rotate enabled";
                                    autoRotateButton.color = "lightblue"
                                }
                                GLCode.setRotate(autoRotate);
                                //console.log(_testC.testC(5));
                            }
                        }
                    }
                    Label {
                        id: distanceLabel
                        color: "#ffffff"
                        text: "Zoom"
                        anchors.top: autoRotateButton.bottom
                        anchors.topMargin: 20
                        height: 20
                    }
                    Slider {
                        id: distanceSlider
                        value: 8000
                        activeFocusOnPress: true
                        stepSize: 1
                        minimumValue: 0
                        maximumValue: 12000
                        height: 20
                        width: parent.width
                        anchors.top: distanceLabel.bottom
                        anchors.topMargin: 5
                        onValueChanged: GLCode.setDistance(distanceSlider.value)
                        function setDistance(value) {
                            distanceSlider.value = value
                        }
                    }
                    Label {
                        id: zLabel
                        color: "#ffffff"
                        text: "Rotate x axis"
                        anchors.top: distanceSlider.bottom
                        anchors.topMargin: 20
                        height: 20
                    }
                    Slider {
                        id: phiSlider
                        value: Math.PI / 4;
                        activeFocusOnPress: true
                        minimumValue: Math.PI / 45
                        maximumValue: Math.PI / 2
                        width: parent.width
                        height: 20
                        anchors.top: zLabel.bottom
                        anchors.topMargin: 5
                        onValueChanged: {
                            if (mainview.dragging == false)
                                GLCode.setPhi(phiSlider.value)
                        }

                        function setPhi(value)
                        {
                            phiSlider.value = value;
                        }
                    }
                    Label {
                        id: xLabel
                        color: "#ffffff"
                        text: "Rotate y axis"
                        anchors.top : phiSlider.bottom
                        anchors.topMargin: 20
                        height: 20
                    }
                    Slider {
                        id: thetaSlider
                        anchors.top: xLabel.bottom
                        anchors.topMargin: 5
                        value: Math.PI / 8;
                        activeFocusOnPress: true
                        maximumValue: Math.PI
                        minimumValue: -Math.PI
                        width: parent.width
                        height: 20
                        onValueChanged: {
                            if (mainview.dragging == false)
                                GLCode.setTheta(thetaSlider.value)
                        }
                        function setTheta(value)
                        {
                            thetaSlider.value = value;
                        }
                    }
                }
            }
        }
        Item {
            id: canvasItem
            Layout.minimumWidth: 50
            Layout.fillWidth: true

            Canvas3D {
                id: canvas3d
                width: parent.width
                height: parent.height
                onInitializeGL: {
                    GLCode.initializeGL(canvas3d, eventSource);
                }
                onPaintGL: {
                    GLCode.paintGL(canvas3d);
                }
                onResizeGL: {
                    GLCode.resizeGL(canvas3d);
                }
                ControlEventSource {
                    anchors.fill: parent
                    focus: true
                    id: eventSource
                }
            }
        }
        Item {
            id : parametersItem
            width: 0
            onWidthChanged: {
                if ( parametersItem.width > 0 )
                {
                    parametersButtonText.text = "Hide parameters"
                    parametersButton.color = "lightblue"
                }
                else
                {
                    parametersButtonText.text = "Show parameters"
                    parametersButton.color = "lightgrey"
                }

            }

            NumberAnimation {
                id: parametersShowAnimation
                target: parametersItem
                properties: "width"
                to: parametersItemWidth
                duration: 250
            }

            NumberAnimation {
                id: parametersHideAnimation
                target: parametersItem
                properties: "width"
                to: 0
                duration: 250
            }

            Flickable {
                id: parametersFlickable
                anchors.fill: parent
                flickableDirection: Flickable.VerticalFlick
                contentHeight: contentItem.childrenRect.height
                clip: true

                Label {
                    id: redSphereLabel
                    color: "#ffffff"
                    text: "Velocity"
                    font.bold: true
                    anchors.top: parent.top
                }

                Label {
                    id: m1Label
                    color: "#ffffff"
                    text: "Mass "
                    anchors.top: redSphereLabel.bottom
                    anchors.topMargin: 20
                }

                Slider {
                    id: m1Slider
                    value: 100
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: 1
                    maximumValue: 100
                    anchors.top: m1Label.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.right: parent.right
                    onValueChanged: {
                        var i = m1Slider.value * 1e24;
                        m1Label.text = "Mass : " + i.toExponential(0)
                    }
                }
                Label {
                    id: m1PositionsLabel
                    color: "#ffffff"
                    text: "Position "
                    anchors.top: m1Slider.bottom
                    anchors.topMargin: 10
                }
                Label {
                    id: m1PositionXLabel
                    color: "#ffffff"
                    text: "X:"
                    anchors.top: m1PositionsLabel.bottom
                    anchors.topMargin: 10
                }
                SpinBox {
                    id: mass1XSpinbox
                    value: 0
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: m1PositionsLabel.bottom
                    anchors.topMargin: 10
                    anchors.left: m1PositionXLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m1PositionXLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass1XSlider.value = mass1XSpinbox.value
                            GLCode.setSphere1X(mass1XSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: mass1XSlider
                    value: 0
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -3000
                    maximumValue: 3000
                    //height: 40
                    anchors.left: mass1XSpinbox.left
                    anchors.right: parent.right
                    anchors.top: mass1XSpinbox.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass1XSpinbox.value = mass1XSlider.value
                            GLCode.setSphere1X(mass1XSlider.value)
                        }
                    }
                }
                Label {
                    id: m1PositionYLabel
                    color: "#ffffff"
                    text: "Y:"
                    anchors.top: mass1XSlider.bottom
                    anchors.topMargin: 10
                }
                SpinBox {
                    id: mass1YSpinbox
                    value: 0
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: mass1XSlider.bottom
                    anchors.topMargin: 10
                    anchors.left: m1PositionYLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m1PositionYLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass1YSlider.value = mass1YSpinbox.value
                            GLCode.setSphere1Y(mass1YSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: mass1YSlider
                    value: 0
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -3000
                    maximumValue: 3000
                    //height: 40
                    anchors.left: mass1YSpinbox.left
                    anchors.right: parent.right
                    anchors.top: mass1YSpinbox.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass1YSpinbox.value = mass1YSlider.value
                            GLCode.setSphere1Y(mass1YSlider.value)
                        }
                    }
                }
                Label {
                    id: m1PositionZLabel
                    color: "#ffffff"
                    text: "Z:"
                    anchors.top: mass1YSlider.bottom
                    anchors.topMargin: 10
                }
                SpinBox {
                    id: mass1ZSpinbox
                    value: 0
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: mass1YSlider.bottom
                    anchors.topMargin: 10
                    anchors.left: m1PositionZLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m1PositionZLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass1ZSlider.value = mass1ZSpinbox.value
                            GLCode.setSphere1Z(mass1ZSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: mass1ZSlider
                    value: 0
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -3000
                    maximumValue: 3000
                    //height: 40
                    //width: parent.width
                    anchors.left: mass1ZSpinbox.left
                    anchors.right: parent.right
                    anchors.top: mass1ZSpinbox.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass1ZSpinbox.value = mass1ZSlider.value
                            GLCode.setSphere1Z(mass1ZSlider.value)
                        }
                    }
                }
                Label {
                    id: m1VelocityLabel
                    color: "#ffffff"
                    text: "Velocity"
                    anchors.top: mass1ZSlider.bottom
                    anchors.topMargin: 20
                }
                Label {
                    id: m1VelXLabel
                    color: "#ffffff"
                    text: "X:"
                    anchors.top: m1VelocityLabel.bottom
                    anchors.topMargin: 10
                }
                SpinBox {
                    id: m1VelXSpinbox
                    value: 0
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: m1VelocityLabel.bottom
                    anchors.topMargin: 10
                    anchors.left: m1VelXLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m1PositionZLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m1VelXSlider.value = m1VelXSpinbox.value
                            //GLCode.setSphere1(mass1ZSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: m1VelXSlider
                    value: 0
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -300
                    maximumValue: 300
                    anchors.left: m1VelXSpinbox.left
                    anchors.right: parent.right
                    //height: 20
                    anchors.top: m1VelXLabel.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m1VelXSpinbox.value = m1VelXSlider.value
                        }
                    }
                }
                Label {
                    id: m1VelYLabel
                    color: "#ffffff"
                    text: "Y:"
                    anchors.top: m1VelXSlider.bottom
                    anchors.topMargin: 5
                }
                SpinBox {
                    id: m1VelYSpinbox
                    value: 0
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: m1VelXSlider.bottom
                    anchors.topMargin: 10
                    anchors.left: m1VelYLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m1PositionZLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m1VelYSlider.value = m1VelYSpinbox.value
                            //GLCode.setSphere1(mass1ZSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: m1VelYSlider
                    value: 0
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -300
                    maximumValue: 300
                    anchors.left: m1VelYSpinbox.left
                    anchors.right: parent.right
                    //height: 20
                    anchors.top: m1VelYLabel.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m1VelYSpinbox.value = m1VelYSlider.value
                        }
                    }
                }
                Label {
                    id: m1VelZLabel
                    color: "#ffffff"
                    text: "Z:"
                    anchors.top: m1VelYSlider.bottom
                    anchors.topMargin: 5
                }
                SpinBox {
                    id: m1VelZSpinbox
                    value: 0
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: m1VelYSlider.bottom
                    anchors.topMargin: 10
                    anchors.left: m1VelZLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m1PositionZLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m1VelZSlider.value = m1VelZSpinbox.value
                            //GLCode.setSphere1(mass1ZSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: m1VelZSlider
                    value: 0
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -300
                    maximumValue: 300
                    anchors.left: m1VelZSpinbox.left
                    anchors.right: parent.right
                    //height: 20
                    anchors.top: m1VelZLabel.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m1VelZSpinbox.value = m1VelZSlider.value
                        }
                    }
                }
                Label {
                    id: blueSphereLabel
                    color: "#ffffff"
                    text: "Blue sphere parameters"
                    font.bold: true
                    anchors.top: m1VelZSlider.bottom
                    anchors.topMargin: 40
                }
                Label {
                    id: m2Label
                    color: "#ffffff"
                    text: "Mass2 "
                    anchors.top: blueSphereLabel.bottom
                    anchors.topMargin: 20
                }
                Slider {
                    id: m2Slider
                    value: 10
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: 1
                    maximumValue: 100
                    //height: 40
                    width: parent.width
                    anchors.top: m2Label.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        var i = m2Slider.value * 1e24;
                        m2Label.text = "Mass : " + i.toExponential(0)
                    }
                }
                Label {
                    id: m2PositionsLabel
                    color: "#ffffff"
                    text: "Position "
                    anchors.top: m2Slider.bottom
                    anchors.topMargin: 10
                }
                Label {
                    id: m2PositionXLabel
                    color: "#ffffff"
                    text: "X:"
                    anchors.top: m2PositionsLabel.bottom
                    anchors.topMargin: 10
                }
                SpinBox {
                    id: mass2XSpinbox
                    value: 0
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: m2PositionsLabel.bottom
                    anchors.topMargin: 10
                    anchors.left: m2PositionXLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m2PositionXLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass2XSlider.value = mass2XSpinbox.value
                            GLCode.setSphere2X(mass2XSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: mass2XSlider
                    value: 0
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -3000
                    maximumValue: 3000
                    //height: 40
                    anchors.left: mass2XSpinbox.left
                    anchors.right: parent.right
                    anchors.top: mass2XSpinbox.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass2XSpinbox.value = mass2XSlider.value
                            GLCode.setSphere2X(mass2XSlider.value)
                        }
                    }
                }
                Label {
                    id: m2PositionYLabel
                    color: "#ffffff"
                    text: "Y:"
                    anchors.top: mass2XSlider.bottom
                    anchors.topMargin: 10
                }
                SpinBox {
                    id: mass2YSpinbox
                    value: -3000
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: mass2XSlider.bottom
                    anchors.topMargin: 10
                    anchors.left: m2PositionYLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m2PositionYLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass2YSlider.value = mass2YSpinbox.value
                            GLCode.setSphere2Y(mass2YSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: mass2YSlider
                    value: -3000
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -3000
                    maximumValue: 3000
                    //height: 40
                    anchors.left: mass2YSpinbox.left
                    anchors.right: parent.right
                    anchors.top: mass2YSpinbox.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass2YSpinbox.value = mass2YSlider.value
                            GLCode.setSphere2Y(mass2YSlider.value)
                        }
                    }
                }
                Label {
                    id: m2PositionZLabel
                    color: "#ffffff"
                    text: "Z:"
                    anchors.top: mass2YSlider.bottom
                    anchors.topMargin: 10
                }
                SpinBox {
                    id: mass2ZSpinbox
                    value: -3000
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: mass2YSlider.bottom
                    anchors.topMargin: 10
                    anchors.left: m2PositionZLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m2PositionZLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass2ZSlider.value = mass2ZSpinbox.value
                            GLCode.setSphere2Z(mass2ZSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: mass2ZSlider
                    value: -3000
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -3000
                    maximumValue: 3000
                    //height: 40
                    //width: parent.width
                    anchors.left: mass2ZSpinbox.left
                    anchors.right: parent.right
                    anchors.top: mass2ZSpinbox.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            mass2ZSpinbox.value = mass2ZSlider.value
                            GLCode.setSphere2Z(mass2ZSlider.value)
                        }
                    }
                }
                Label {
                    id: m2VelocityLabel
                    color: "#ffffff"
                    text: "Velocity"
                    anchors.top: mass2ZSlider.bottom
                    anchors.topMargin: 20
                }
                Label {
                    id: m2VelXLabel
                    color: "#ffffff"
                    text: "X:"
                    anchors.top: m2VelocityLabel.bottom
                    anchors.topMargin: 10
                }
                SpinBox {
                    id: m2VelXSpinbox
                    value: 12
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: m2VelocityLabel.bottom
                    anchors.topMargin: 10
                    anchors.left: m2VelXLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m2PositionZLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m2VelXSlider.value = m2VelXSpinbox.value
                            //GLCode.setSphere1(mass1ZSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: m2VelXSlider
                    value: 12
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -300
                    maximumValue: 300
                    anchors.left: m2VelXSpinbox.left
                    anchors.right: parent.right
                    //height: 20
                    anchors.top: m2VelXLabel.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m2VelXSpinbox.value = m2VelXSlider.value
                        }
                    }
                }
                Label {
                    id: m2VelYLabel
                    color: "#ffffff"
                    text: "Y:"
                    anchors.top: m2VelXSlider.bottom
                    anchors.topMargin: 5
                }
                SpinBox {
                    id: m2VelYSpinbox
                    value: -3
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: m2VelXSlider.bottom
                    anchors.topMargin: 10
                    anchors.left: m2VelYLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m2PositionZLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m2VelYSlider.value = m2VelYSpinbox.value
                            //GLCode.setSphere1(mass1ZSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: m2VelYSlider
                    value: -3
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -300
                    maximumValue: 300
                    anchors.left: m2VelYSpinbox.left
                    anchors.right: parent.right
                    //height: 20
                    anchors.top: m2VelYLabel.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m2VelYSpinbox.value = m2VelYSlider.value
                        }
                    }
                }
                Label {
                    id: m2VelZLabel
                    color: "#ffffff"
                    text: "Z:"
                    anchors.top: m2VelYSlider.bottom
                    anchors.topMargin: 5
                }
                SpinBox {
                    id: m2VelZSpinbox
                    value: 12
                    minimumValue: -3000
                    maximumValue: 3000
                    z: 1
                    anchors.top: m2VelYSlider.bottom
                    anchors.topMargin: 10
                    anchors.left: m2VelZLabel.right
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    style: SpinBoxStyle{
                        background: Rectangle {
                            //implicitWidth: 100
                            implicitHeight: m2PositionZLabel.height
                            border.color: "white"
                            color: "black"
                            radius: 2
                        }
                        textColor: "white"
                    }
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m2VelZSlider.value = m2VelZSpinbox.value
                            //GLCode.setSphere1(mass1ZSpinbox.value)
                        }
                    }
                }
                Slider {
                    id: m2VelZSlider
                    value: 12
                    activeFocusOnPress: true
                    stepSize: 1
                    minimumValue: -300
                    maximumValue: 300
                    anchors.left: m2VelZSpinbox.left
                    anchors.right: parent.right
                    //height: 20
                    anchors.top: m2VelZLabel.bottom
                    anchors.topMargin: 5
                    onValueChanged: {
                        if (componentCompleted)
                        {
                            m2VelZSpinbox.value = m2VelZSlider.value
                        }
                    }
                }

            }
        }
        Item {
            id : analysisItem
            width: 0
            onWidthChanged: {
                if ( analysisItem.width > 0 )
                {
                    analysisButtonText.text = "Hide analysis"
                    analysisButton.color = "lightblue"
                }
                else
                {
                    analysisButtonText.text = "Show analysis"
                    analysisButton.color = "lightgrey"
                }
            }

            NumberAnimation {
                id: analysisShowAnimation
                target: analysisItem
                properties: "width"
                to: analysisItemWidth
                duration: 250
            }

            NumberAnimation {
                id: analysisHideAnimation
                target: analysisItem
                properties: "width"
                to: 0
                duration: 250
            }

            Flickable {
                id: analysisFlickable
                anchors.fill: parent
                contentHeight: contentItem.childrenRect.height
                flickableDirection: Flickable.VerticalFlick
                clip: true

                Text {
                    id:text0
                    color: "#ffffff"
                    width: parent.width
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.top : parent.top
                    text : "The conic sections play a fundamental role in space science.
        Any body under the influence of an inverse square law force
        (i.e., where force is inversely proportional to the square of distance)
        must have a trajectory that is one of the conic sections.
        In celestial mechanics the forces are gravitational;
        however, it is also of interest that the forces of attraction or repulsion
        between electrically charged particles obey an inverse square law,
        and such particles also have paths that are conic sections.
        No important scientific applications were found for conic sections until the 17th century,
        when Kepler discovered that planets move in ellipses
        and Galileo proved that projectiles travel in parabolas."
                    font.pointSize: 14
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignJustify
                    textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                Text {
                    id: text5
                    anchors.top: text0.bottom
                    anchors.topMargin: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    color: "#ffffff"
                    width: parent.width
                    text: "The conic sections were named and studied at least since 200 BC, when Apollonius of Perga undertook a systematic study of their properties.
        It is believed that the first definition of a conic section is due to Menaechmus.
        His work did not survive and is only known through secondary accounts.
        Euclid is said to have written four books on conics but these were lost as well.
        Archimedes is known to have studied conics, having determined the area bounded by a parabola and an ellipse.
        The only part of this work to survive is a book on the solids of revolution of conics.
        The greatest progress in the study of conics by the ancient Greeks is due to Apollonius of Perga
        whose eight-volume Conic Sections or Conics summarized and greatly extended existing knowledge.
        Apollonius's major innovation was to characterize a conic using properties within the plane and intrinsic to the curve; this greatly simplified analysis.
        With this tool, it was now possible to show that any plane cutting the cone,
        regardless of its angle, will produce a conic according to the earlier definition, leading to the definition commonly used today.
        Pappus of Alexandria is credited with discovering the importance of the concept of a conic's focus,
        and with the discovery of the related concept of a directrix.
        Apollonius's work was translated into Arabic (the technical language of the time)
        and much of his work only survives through the Arabic version.
        Persians found applications to the theory; the most notable of these was the Persian mathematician and poet Omar Khayyám
        who used conic sections to solve algebraic equations.
        Johannes Kepler extended the theory of conics through the \"principle of continuity\", a precursor to the concept of limits.
        Girard Desargues and Blaise Pascal developed a theory of conics using an early form of projective geometry
        and this helped to provide impetus for the study of this new field.
        Meanwhile, René Descartes applied his newly discovered Analytic geometry to the study of conics. This had the effect of reducing the geometrical problems
        of conics to problems in algebra."
                    font.pointSize: 14
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignJustify
                    textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }


            }
        }
    }
    Component.onCompleted: {
        GLCode.thetaSender.thetaChanged.connect(thetaSlider.setTheta);
        GLCode.draggingSender.draggingSignal.connect(mainview.setDragging);
        GLCode.phiSender.phiChanged.connect(phiSlider.setPhi);
        GLCode.distanceSender.distanceChanged.connect(distanceSlider.setDistance);
        //We set here the flickable content height property
        //because of a binding property issue
        //flickable.contentHeight = flickable.contentItem.childrenRect.height
        flickable.contentHeight = showControlsButton.height +
                showControlsButton.anchors.topMargin +
                restartButton.height +
                restartButton.anchors.topMargin +
                relativeMotionButton.height +
                relativeMotionButton.anchors.topMargin +
                evaluateButton.height +
                evaluateButton.anchors.topMargin +
                parametersButton.height +
                parametersButton.anchors.topMargin +
                analysisButton.height +
                analysisButton.anchors.topMargin +
                autoRotateButton.height +
                autoRotateButton.anchors.topMargin +
                distanceLabel.height +
                distanceLabel.anchors.topMargin +
                distanceSlider.height +
                distanceSlider.anchors.topMargin +
                zLabel.height +
                zLabel.anchors.topMargin +
                phiSlider.height +
                phiSlider.anchors.topMargin +
                xLabel.height +
                xLabel.anchors.topMargin +
                thetaSlider.height +
                thetaSlider.anchors.topMargin
        //parametersFlickable.contentHeight = parametersFlickable.contentItem.childrenRect.height
        //analysisFlickable.contentHeight = analysisFlickable.contentItem.childrenRect.height
        time = curr_time = (new Date).getTime();
        componentCompleted = true
    }
}
