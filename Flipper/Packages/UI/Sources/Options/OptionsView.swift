import Core
import SwiftUI

struct OptionsView: View {
    @StateObject var viewModel: OptionsViewModel

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Utils")) {
                    NavigationLink("Ping") {
                        PingView(viewModel: .init())
                    }
                    .disabled(!viewModel.isOnline)
                    NavigationLink("Stress Test") {
                        StressTestView(viewModel: .init())
                    }
                    .disabled(!viewModel.isOnline)
                    NavigationLink("Speed Test") {
                        SpeedTestView(viewModel: .init())
                    }
                    .disabled(!viewModel.isOnline)
                    NavigationLink("Logs") {
                        LogsView(viewModel: .init())
                    }
                    Button("Backup Keys") {
                        viewModel.backupKeys()
                    }
                    .disabled(!viewModel.hasKeys)
                }

                Section(header: Text("Remote")) {
                    NavigationLink("Screen Streaming") {
                        RemoteContolView(viewModel: .init())
                    }
                    NavigationLink("File Manager") {
                        FileManagerView(viewModel: .init())
                    }
                    Button("Reboot Flipper") {
                        viewModel.rebootFlipper()
                    }
                    .foregroundColor(viewModel.isOnline ? .accentColor : .gray)
                }
                .disabled(!viewModel.isOnline)

                Section {
                    NavigationLink("Widget Settings") {
                        WidgetSettingsView(viewModel: .init())
                    }
                }

                if viewModel.isDebugMode {
                    Section(header: Text("Debug")) {
                        Toggle(isOn: $viewModel.isProvisioningDisabled) {
                            Text("Disable provisioning")
                        }
                        NavigationLink("I'm watching you") {
                            CarrierView(viewModel: .init())
                        }
                        Button("Reset App") {
                            viewModel.showResetApp = true
                        }
                        .foregroundColor(.sRed)
                        .actionSheet(isPresented: $viewModel.showResetApp) {
                            .init(title: Text("Are you sure?"), buttons: [
                                .destructive(Text("Reset App")) {
                                    viewModel.resetApp()
                                },
                                .cancel()
                            ])
                        }
                    }
                }

                Section {
                } footer: {
                    VStack(alignment: .center) {
                        Text("Flipper Mobile App")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black20)
                        Text("Version: \(viewModel.appVersion)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black40)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.onVersionTapGesture()
                    }
                }
                .padding(.top, -40)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Options")
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
    }
}
