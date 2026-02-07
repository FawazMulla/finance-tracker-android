import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), balance: 0.0, transactionCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), balance: 0.0, transactionCount: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.example.finance_tracker")
        let balance = sharedDefaults?.double(forKey: "balance") ?? 0.0
        let transactionCount = sharedDefaults?.integer(forKey: "transaction_count") ?? 0
        
        let entry = SimpleEntry(date: Date(), balance: balance, transactionCount: transactionCount)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let transactionCount: Int
}

struct FinanceWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.16, blue: 0.23)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Finance Tracker")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Current Balance")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Text("₹\(String(format: "%.2f", entry.balance))")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Link(destination: URL(string: "financetracker://addtransaction")!) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Transaction")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.39, green: 0.40, blue: 0.95))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

@main
struct FinanceWidget: Widget {
    let kind: String = "FinanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FinanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Finance Tracker")
        .description("Quick access to add transactions and view balance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FinanceWidget_Previews: PreviewProvider {
    static var previews: some View {
        FinanceWidgetEntryView(entry: SimpleEntry(date: Date(), balance: 1234.56, transactionCount: 10))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
