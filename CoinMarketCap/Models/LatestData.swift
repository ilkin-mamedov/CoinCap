import Foundation

struct LatestData: Codable {
    let id: Int
    let quote: [String : Quote]
}
