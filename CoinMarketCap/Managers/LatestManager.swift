import Foundation
import Alamofire

protocol LatestManagerDelegate {
    func didUpdateLatest(_ latestManager: LatestManager, _ latest: Latest)
    func didFailWithError(_ error: Error)
}

struct LatestManager {
    
    var delegate: LatestManagerDelegate?
    
    func fetchLatest() {
        performRequest(with: "\(Constants.LATEST_URL)")
    }
    
    func performRequest(with url: String) {
        AF.request(url).response { response in
            if let result = response.response {
                if result.statusCode == 200 {
                    if let safeData = response.data {
                        if let latest = parseJSON(safeData) {
                            delegate?.didUpdateLatest(self, latest)
                        }
                    }
                }
            }
        }
    }
    
    func parseJSON(_ data: Data) -> Latest? {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(Latest.self, from: data)
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}

