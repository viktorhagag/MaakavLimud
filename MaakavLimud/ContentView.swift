import SwiftUI

struct StudyItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var repetitions: Int
}

class StudyTracker: ObservableObject {
    @Published var items: [StudyItem] = [
        StudyItem(id: UUID(), title: "שולחן ערוך - סימן א'", repetitions: 0),
        StudyItem(id: UUID(), title: "משנה ברורה - סימן א'", repetitions: 0),
        StudyItem(id: UUID(), title: "מסכת ברכות", repetitions: 0),
        StudyItem(id: UUID(), title: "מסילת ישרים", repetitions: 0),
        StudyItem(id: UUID(), title: "תניא", repetitions: 0),
        StudyItem(id: UUID(), title: "בצור ירום", repetitions: 0),
        StudyItem(id: UUID(), title: "דרך השם", repetitions: 0),
        StudyItem(id: UUID(), title: "זוהר - מתוק מדבש", repetitions: 0)
    ]

    func addItem(title: String) {
        let newItem = StudyItem(id: UUID(), title: title, repetitions: 0)
        items.append(newItem)
    }

    func incrementRepetition(for item: StudyItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].repetitions += 1
        }
    }

    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func exportToJSON() -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(items)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("study_backup.json")
            try data.write(to: url)
            return url
        } catch {
            print("Error exporting: \\(error)")
            return nil
        }
    }
}

struct ContentView: View {
    @StateObject private var tracker = StudyTracker()
    @State private var newItemTitle = ""
    @State private var isSharing = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("הוסף לימוד חדש", text: $newItemTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("הוסף") {
                        guard !newItemTitle.isEmpty else { return }
                        tracker.addItem(title: newItemTitle)
                        newItemTitle = ""
                    }
                }.padding()

                List {
                    ForEach(tracker.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                Text("חזרות: \\(item.repetitions)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("+") {
                                tracker.incrementRepetition(for: item)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .onDelete(perform: tracker.deleteItems)
                }

                Button("📤 ייצוא גיבוי") {
                    if let url = tracker.exportToJSON() {
                        exportURL = url
                        isSharing = true
                    }
                }
                .padding(.bottom)
                .sheet(isPresented: $isSharing) {
                    if let url = exportURL {
                        ShareSheet(activityItems: [url])
                    }
                }
            }
            .navigationTitle("מעקב לימוד")
        }
    }
}

// ShareSheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
