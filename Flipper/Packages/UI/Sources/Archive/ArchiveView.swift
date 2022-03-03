import Core
import SwiftUI
import Combine

struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel
    @State var showSearchView = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Content")
            }
            .edgesIgnoringSafeArea(.top)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Archive")
                        .font(.system(size: 20, weight: .bold))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSearchView = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showSearchView) {
                ArchiveSearchView()
            }
            .navigationTitle("")
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .orange)
    }
}
