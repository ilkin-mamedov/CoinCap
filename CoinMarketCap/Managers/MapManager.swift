import Foundation
import Alamofire
import SPAlert

protocol MapManagerDelegate {
    func didUpdateMap(_ mapManager: MapManager, _ map: Map)
    func didFailWithError(_ error: Error)
}

struct MapManager {
    
    var delegate: MapManagerDelegate?
    
    func fetchMap() {
        performRequest(with: Constants.MAP_URL)
    }
    
    func performRequest(with url: String) {
        if NetworkReachabilityManager()!.isReachable {
            AF.request(url).response { response in
                if let result = response.response {
                    if result.statusCode == 200 {
                        if let safeData = response.data {
                            if let map = parseJSON(safeData) {
                                delegate?.didUpdateMap(self, map)
                            }
                        }
                    }
                }
            }
        } else {
            SPAlert.present(title: "No internet connection.", message: "Please, check your internet connection and try again.", preset: .error)
        }
    }
    
    func parseJSON(_ data: Data) -> Map? {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(Map.self, from: data)
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
