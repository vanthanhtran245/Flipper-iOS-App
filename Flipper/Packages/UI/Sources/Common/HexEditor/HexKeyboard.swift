import SwiftUI

// FIXME: limit keyboard frame size, remove height hack

struct HexKeyboard: View {
    var onButton: (String) -> Void = { _ in }
    var onBack: () -> Void = { }
    var onOK: () -> Void = { }

    var body: some View {
        HStack(alignment: .top) {
            VStack {
                HStack {
                    KeyboardButton(key: "7", onPressed: onButton)
                    KeyboardButton(key: "8", onPressed: onButton)
                    KeyboardButton(key: "9", onPressed: onButton)
                }
                HStack {
                    KeyboardButton(key: "4", onPressed: onButton)
                    KeyboardButton(key: "5", onPressed: onButton)
                    KeyboardButton(key: "6", onPressed: onButton)
                }
                HStack {
                    KeyboardButton(key: "1", onPressed: onButton)
                    KeyboardButton(key: "2", onPressed: onButton)
                    KeyboardButton(key: "3", onPressed: onButton)
                }
                HStack {
                    KeyboardButton(key: "0", onPressed: onButton)
                }
            }
            VStack {
                HStack {
                    KeyboardButton(key: "A", onPressed: onButton)
                    KeyboardButton(key: "B", onPressed: onButton)
                    KeyboardButton(key: "C", onPressed: onButton)
                }
                HStack {
                    KeyboardButton(key: "D", onPressed: onButton)
                    KeyboardButton(key: "E", onPressed: onButton)
                    KeyboardButton(key: "F", onPressed: onButton)
                }
                HStack {
                    KeyboardDeleteButton(onPressed: onBack)
                        .frame(height: 110)
                    KeyboardOKButton(onPressed: onOK)
                        .frame(height: 110)
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .darkGray))
    }
}

struct KeyboardButton: View {
    let key: String
    var onPressed: (String) -> Void

    var body: some View {
        Button {
            onPressed(key)
        } label: {
            Text(key)
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
        }
        .background(.gray)
        .cornerRadius(8)
    }
}

struct KeyboardDeleteButton: View {
    var onPressed: () -> Void

    var body: some View {
        Button {
            onPressed()
        } label: {
            Image(systemName: "delete.left")
                .foregroundColor(.primary)
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 13)
        .background(.gray)
        .cornerRadius(8)
    }
}

struct KeyboardOKButton: View {
    var onPressed: () -> Void

    var body: some View {
        Button {
            onPressed()
        } label: {
            VStack {
                Text("OK")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(.gray)
        .cornerRadius(8)
    }
}

struct HexKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        HexKeyboard()
    }
}
