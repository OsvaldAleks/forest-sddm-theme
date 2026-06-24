import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Column {
    id: inputContainer
    
    Layout.fillWidth: true

    property ComboBox exposeSession: sessionSelect.exposeSession
    property bool failed

    Item {
        id: usernameField

        height: root.font.pointSize * 3
        width: parent.width / 2.5
        anchors.horizontalCenter: parent.horizontalCenter

        TextField {
            id: username

            anchors.centerIn: parent
            height: root.font.pointSize * 2
            width: parent.width
            horizontalAlignment: TextInput.AlignHCenter
            z: 1

            text: "aleks"
            color: config.LoginFieldTextColor
            font.pointSize: root.font.pointSize
            font.capitalization: config.AllowUppercaseLettersInUsernames == "false" ? Font.AllLowercase : Font.MixedCase
            placeholderText: config.TranslatePlaceholderUsername || textConstants.userName
            placeholderTextColor: config.PlaceholderTextColor
            selectByMouse: true
            renderType: Text.QtRendering
            
            onFocusChanged:{
                if(focus)
                    selectAll()
            }

            background: Rectangle {
                color: config.LoginFieldBackgroundColor
                radius: config.RoundCorners
            }
            
            onAccepted: config.AllowUppercaseLettersInUsernames == "false" ? sddm.login(username.text.toLowerCase(), password.text, sessionSelect.selectedSession) : sddm.login(username.text, password.text, sessionSelect.selectedSession)
        }
    }
    
    Item {
        id: passwordField

        height: root.font.pointSize * 3
        width: parent.width / 2.5
        anchors.horizontalCenter: parent.horizontalCenter
        
        TextField {
            id: password

            height: root.font.pointSize * 2
            width: parent.width
            anchors.centerIn: parent
            horizontalAlignment: TextInput.AlignHCenter
            
            font.pointSize: root.font.pointSize
            color: config.PasswordFieldTextColor
            focus: config.PasswordFocus == "true" ? true : false
            echoMode: TextInput.Password
            placeholderText: config.TranslatePlaceholderPassword || textConstants.password
            placeholderTextColor: config.PlaceholderTextColor
            passwordCharacter: "•"
            passwordMaskDelay: config.HideCompletePassword == "true" ? undefined : 1000
            renderType: Text.QtRendering
            selectByMouse: true
            
            background: Rectangle {
                color: config.PasswordFieldBackgroundColor
                radius: config.RoundCorners || 0
            }
            onAccepted: config.AllowUppercaseLettersInUsernames == "false" ? sddm.login(username.text.toLowerCase(), password.text, sessionSelect.selectedSession) : sddm.login(username.text, password.text, sessionSelect.selectedSession)
            KeyNavigation.down: loginButton
        }

        states: [
            State {
                name: "focused"
                when: password.activeFocus
                PropertyChanges {
                    target: password.background
                }
                PropertyChanges {
                    target: password
                    color: config.LoginFieldTextColor
                }
            }
        ]
        transitions: [
            Transition {
                PropertyAnimation {
                    properties: "color, border.color"
                    duration: 150
                }
            }
        ]        
    }

    Item {
        id: login

        height: 0
        visible: false
        
        Button {
            id: loginButton

            height: root.font.pointSize
            implicitWidth: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            
            text: "Login"
            enabled: config.AllowEmptyPassword == "true" || username.text != "" && password.text != "" ? true : false
            hoverEnabled: true

            contentItem: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                font.bold: true
                font.pointSize: root.font.pointSize
                font.family: root.font.family
                color: config.LoginButtonTextColor
                text: parent.text
            }

            background: Rectangle {
                id: buttonBackground

                color: config.LoginButtonBackgroundColor
                radius: config.RoundCorners
            }

            onClicked: config.AllowUppercaseLettersInUsernames == "false" ? sddm.login(username.text.toLowerCase(), password.text, sessionSelect.selectedSession) : sddm.login(username.text, password.text, sessionSelect.selectedSession)
            Keys.onReturnPressed: clicked()
            Keys.onEnterPressed: clicked()
            
            KeyNavigation.down: systemButtons.children[0]
        }
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onLoginFailed() {
            failed = true
            resetError.running ? resetError.stop() && resetError.start() : resetError.start()
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: failed = false
        running: false
    }
}
