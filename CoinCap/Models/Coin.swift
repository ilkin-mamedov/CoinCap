import Foundation

struct Coin: Codable {
    let id: String?
    let rank: String?
    let symbol: String?
    let name: String?
    let supply: String?
    let maxSupply: String?
    let marketCapUsd: String?
    let volumeUsd24Hr: String?
    let priceUsd: String?
    let changePercent24Hr: String?
    let vwap24Hr: String?
    let explorer: String?
    
    func getRoundedPrice() -> Double {
        return round((Double(priceUsd ?? "0.00") ?? 0.00) * 100) / 100.0
    }
    
    func getRoundedPercent() -> Double {
        return round((Double(changePercent24Hr ?? "0.00") ?? 0.00) * 100) / 100.0
    }
}
