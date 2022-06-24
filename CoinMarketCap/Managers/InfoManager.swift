import Foundation
import Alamofire

protocol InfoManagerDelegate {
    func didUpdateInfo(_ infoManager: InfoManager, _ info: Info)
    func didFailWithError(_ error: Error)
}

struct InfoManager {
    
    var delegate: InfoManagerDelegate?
    
    func fetchInfo(with id: Int) {
        performRequest(with: "\(Constants.INFO_URL)&id=\(id)")
    }
    
    func performRequest(with url: String) {
        AF.request(url).response { response in
            if let result = response.response {
                if result.statusCode == 200 {
                    if let safeData = response.data {
                        if let info = parseJSON(safeData) {
                            delegate?.didUpdateInfo(self, info)
                        }
                    }
                }
            }
        }
    }
    
    func parseJSON(_ data: Data) -> Info? {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(Info.self, from: data)
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
