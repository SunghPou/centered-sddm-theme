import QtQuick 2.15

Rectangle {
    id: root
    anchors.fill: parent
    color: "black"
    focus: true

    property int userIdx: Math.min(Math.max(userModel.lastIndex, 0), Math.max(userModel.count - 1, 0))
    property int sessionIdx: Math.min(Math.max(sessionModel.lastIndex, 0), Math.max(sessionModel.count - 1, 0))
    // shortcut: SDDM exposes these models as QAbstractItemModel, so instance enum lookup is undefined; use literal role ids
    property string userName: {
        var n = userModel.count ? userModel.data(userModel.index(userIdx, 0), 257) : ""
        return n ? n : userModel.lastUser
    }
    property string sessionName: {
        var n = sessionModel.count ? sessionModel.data(sessionModel.index(sessionIdx, 0), 260) : ""
        return n ? n : (sessionModel.count ? sessionModel.data(sessionModel.index(sessionIdx, 0), 258) : "")
    }
    property string layoutText: {
        if (keyboard.layouts.length === 0)
            return ""
        var i = keyboard.currentLayout
        return keyboard.layouts[i] ? keyboard.layouts[i].shortName : ""
    }

    function nextUser() {
        if (userModel.count > 1)
            userIdx = (userIdx + 1) % userModel.count
        password.forceActiveFocus()
    }

    function nextSession() {
        if (sessionModel.count > 1)
            sessionIdx = (sessionIdx + 1) % sessionModel.count
        password.forceActiveFocus()
    }

    function nextLayout() {
        if (keyboard.layouts.length > 1)
            keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
        password.forceActiveFocus()
    }

    function tryLogin() {
        if (password.text === "")
            return
        sddm.login(userName || userModel.lastUser, password.text, sessionIdx)
    }

    Column {
        anchors.centerIn: parent
        width: 320
        spacing: 12

        Item {
            width: 320
            height: 28
            Text {
                objectName: "userLabel"
                anchors.centerIn: parent
                text: root.userName
                color: "white"
                font.pixelSize: 20
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: root.nextUser()
            }
        }

        Rectangle {
            width: 320
            height: 56
            color: "#22000000"
            border.color: "white"
            border.width: 1
            radius: 0

            TextInput {
                objectName: "password"
                id: password
                focus: true
                anchors.fill: parent
                anchors.margins: 14
                echoMode: TextInput.Password
                color: "white"
                verticalAlignment: TextInput.AlignVCenter
                selectByMouse: true
                Keys.onReturnPressed: root.tryLogin()
                Keys.onEscapePressed: password.text = ""
            }
        }

        Row {
            width: 320
            height: 30

            Item {
                objectName: "sessionSwitch"
                width: 160
                height: 30
                Text {
                    objectName: "sessionLabel"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.sessionName
                    color: "#cccccc"
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: root.nextSession()
                }
            }

            Item {
                objectName: "layoutSwitch"
                width: 160
                height: 30
                Text {
                    objectName: "layoutLabel"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.layoutText
                    color: "#cccccc"
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: root.nextLayout()
                }
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            password.forceActiveFocus()
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
