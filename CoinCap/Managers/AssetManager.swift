import Foundation
import Alamofire

protocol AssetManagerDelegate {
    func didUpdateAsset(_ assetManager: AssetManager, _ asset: Asset)
    func didFailWithError(_ error: Error)
}

struct AssetManager {
    
    var delegate: AssetManagerDelegate?
    
    func fetchAsset(by id: String) {
        performRequest(with: "https://api.coincap.io/v2/assets/\(id)?api=7c43-Kis93RZINMxgTTQkQ1jLINrJXhU")
    }
    
    func performRequest(with url: String) {
        if NetworkReachabilityManager()!.isReachable {
            AF.request(url).response { response in
                if let result = response.response {
                    if result.statusCode == 200 {
                        if let safeData = response.data {
                            if let asset = parseJSON(safeData) {
                                delegate?.didUpdateAsset(self, asset)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func parseJSON(_ data: Data) -> Asset? {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(Asset.self, from: data)
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
