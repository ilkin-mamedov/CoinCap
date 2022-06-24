import Foundation

struct Constants {
    public static let API_KEY = ""
    
    public static let BASE_URL = "https://pro-api.coinmarketcap.com/v1/cryptocurrency"
    
    public static let MAP_URL = "\(BASE_URL)/map?CMC_PRO_API_KEY=\(API_KEY)"
    
    public static let INFO_URL = "\(BASE_URL)/info?CMC_PRO_API_KEY=\(API_KEY)"
    
    public static let LATEST_URL = "\(BASE_URL)/listings/latest?CMC_PRO_API_KEY=\(API_KEY)"
}
