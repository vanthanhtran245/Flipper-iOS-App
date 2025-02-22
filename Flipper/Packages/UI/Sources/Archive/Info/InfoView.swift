import SwiftUI

struct InfoView: View {
    @StateObject var viewModel: InfoViewModel
    @StateObject var alertController: AlertController = .init()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.isEditing {
                    SheetEditHeader(
                        title: "Editing",
                        description: viewModel.item.name.value,
                        onSave: viewModel.saveChanges,
                        onCancel: viewModel.undoChanges
                    )
                    .padding(.bottom, 6)
                } else {
                    SheetHeader(
                        title: viewModel.item.isNFC ? "Card Info" : "Key Info",
                        description: viewModel.item.name.value
                    ) {
                        viewModel.dismiss()
                    }
                    .padding(.bottom, 6)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        CardView(
                            item: $viewModel.item,
                            isEditing: $viewModel.isEditing,
                            kind: .existing
                        )
                        .padding(.top, 14)
                        .padding(.horizontal, 24)

                        EmulateView(viewModel: .init(item: viewModel.item))
                            .opacity(viewModel.isEditing ? 0 : 1)
                            .environmentObject(alertController)

                        VStack(alignment: .leading, spacing: 20) {
                            if viewModel.item.isEditableNFC {
                                InfoButton(
                                    image: "HexEditor",
                                    title: "Edit Dump"
                                ) {
                                    viewModel.showDumpEditor = true
                                }
                                .foregroundColor(.primary)
                            }
                            InfoButton(
                                image: "Share",
                                title: "Share",
                                action: { viewModel.share() },
                                longPressAction: { viewModel.shareAsFile() }
                            )
                            .foregroundColor(.primary)
                            InfoButton(image: "Delete", title: "Delete") {
                                viewModel.delete()
                            }
                            .foregroundColor(.sRed)
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
                        .opacity(viewModel.isEditing ? 0 : 1)

                        Spacer()
                    }
                }
            }

            if alertController.isPresented {
                alertController.alert
            }
        }
        .fullScreenCover(isPresented: $viewModel.showDumpEditor) {
            NFCEditorView(viewModel: .init(item: $viewModel.item))
        }
        .alert(isPresented: $viewModel.isError) {
            Alert(title: Text(viewModel.error))
        }
        .onReceive(viewModel.dismissPublisher) {
            dismiss()
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct InfoButton: View {
    let image: String
    let title: String
    let action: () -> Void
    let longPressAction: () -> Void

    init(
        image: String,
        title: String,
        action: @escaping () -> Void,
        longPressAction: @escaping () -> Void = {}
    ) {
        self.image = image
        self.title = title
        self.action = action
        self.longPressAction = longPressAction
    }

    var body: some View {
        Button {
        } label: {
            HStack(spacing: 8) {
                Image(image)
                    .renderingMode(.template)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
        }
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            longPressAction()
        })
        .simultaneousGesture(TapGesture().onEnded {
            action()
        })
    }
}
