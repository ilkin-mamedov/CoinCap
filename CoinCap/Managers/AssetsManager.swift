import Foundation
import Alamofire
import RealmSwift

protocol AssetsManagerDelegate {
    func didUpdateAssets(_ assetsManager: AssetsManager, _ assets: Assets)
    func didFailWithError(_ error: Error)
}

struct AssetsManager {
    
    var delegate: AssetsManagerDelegate?
    
    let realm = try! Realm()
    
    func fetchAssets() {
        performRequest(with: "https://api.coincap.io/v2/assets?api=7c43-Kis93RZINMxgTTQkQ1jLINrJXhU")
    }
    
    func performRequest(with url: String) {
        if NetworkReachabilityManager()!.isReachable {
            AF.request(url).response { response in
                if let result = response.response {
                    if result.statusCode == 200 {
                        if let safeData = response.data {
                            if let assets = parseJSON(safeData) {
                                delegate?.didUpdateAssets(self, assets)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func parseJSON(_ data: Data) -> Assets? {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(Assets.self, from: data)
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
    
    func add(by id: String) {
        do {
            try realm.write {
                let coin = CoinObject()
                coin.id = id
                realm.add(coin)
            }
        } catch {
            print(error)
        }
    }
}
