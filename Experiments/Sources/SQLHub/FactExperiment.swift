import Foundation
import HeatMap
import OSLog
import SharingGRDB
import SwiftUI
import Utils
import Dependencies

@Table
public struct Fact: Identifiable, Sendable {
    public let id: Int
    public var body: String
    public var count: Int
    public var updatedAt: Date
    public init(id: Int, body: String, count: Int = 1, updatedAt: Date) {
        self.id = id
        self.body = body
        self.count = count
        self.updatedAt = updatedAt
    }
}

extension Fact: HeatMapValue {
    public var heat: Double {
        Double(count)
    }
}

extension Fact {
    var heatColor: Color {
        switch count {
        case 1:
            return Color(hex: 0x66BB6A) // green
        case 2...4:
            return Color(hex: 0x42A5F5) // blue
        case 5...9:
            return Color(hex: 0xFFCA28) // yellow-orange
        case 10...14:
            return Color(hex: 0xEF5350) // red
        default:
            return Color(hex: 0xAB47BC) // purple for highest tier
        }
    }
}

public struct FactsView: View {
    @FetchAll(Fact.order { $0.updatedAt.desc() }, animation: .default) var facts
    @Dependency(\.defaultDatabase) var database

    public init() {}
    
    public var body: some View {
        Form {
            Section {
                HeatMapView(items: facts) { fact, _ in
                    RoundedRectangle(cornerRadius: 8, style: .circular)
                        .fill(fact.heatColor)
                        .overlay {
                            VStack {
                                Text("\(fact.id)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("\(fact.count)")
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                        }
                        .id(fact.id)
                }
                .frame(height: 400)
            }
            
            Section {
                ForEach(facts) { fact in
                    Text(fact.body)
                }
            }
        }
        .navigationTitle("Facts")
        .task {
            do {
                var count = 0
                while count < 20 {
                    count += 1
                    try await Task.sleep(for: .seconds(1))
                    let number = Int.random(in: 0...100)
                    let fact = try await String(
                        decoding: URLSession.shared.data(
                            from: URL(string: "http://numberapi.com/\(number)")!
                        ).0,
                        as: UTF8.self
                    )
                    let currentFact = facts.first(where: { $0.id == number })
                    try await database.write { db in
                        if let currentFact {
                            try Fact.upsert {
                                Fact.Draft(
                                    id: number,
                                    body: currentFact.body + "\n\n" + fact,
                                    count: currentFact.count + 1,
                                    updatedAt: Date()
                                )
                            }
                            .execute(db)
                        } else {
                            try Fact.insert {
                                Fact.Draft(
                                    id: number,
                                    body: fact,
                                    count: 1,
                                    updatedAt: Date()
                                )
                            }
                            .execute(db)
                        }
                    }
                }
            } catch {
                debugPrint("Fetch Fact Error: \(error)")
            }
        }
    }
}

