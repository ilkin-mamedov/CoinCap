import UIKit
import SDWebImage

class DetailsViewController: UIViewController {
    
    var id = 0

    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinSymbolLabel: UILabel!
    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var coinDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Overview"
        
        let infoManager = InfoManager(delegate: self)
        infoManager.fetchInfo(with: id)
        
        let latestManager = LatestManager(delegate: self)
        latestManager.fetchLatest()
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}

extension DetailsViewController: LatestManagerDelegate {
    
    func didUpdateLatest(_ latestManager: LatestManager, _ latest: Latest) {
        for item in latest.data {
            if item.id == id {
                if item.quote["USD"]!.volume_change_24h > 0 {
                    indicatorImageView.image = UIImage(systemName: "arrowtriangle.up.fill")
                    indicatorImageView.tintColor = .systemGreen
                    coinPriceLabel.textColor = .systemGreen
                    coinPriceLabel.tintColor = .systemGreen
                } else {
                    indicatorImageView.image = UIImage(systemName: "arrowtriangle.down.fill")
                    indicatorImageView.tintColor = .red
                    coinPriceLabel.textColor = .red
                    coinPriceLabel.tintColor = .red
                }
                let price = Double(round(100 * item.quote["USD"]!.price) / 100)
                let percent = Double(round(10 * item.quote["USD"]!.percent_change_1h) / 10)
                coinPriceLabel.text = "\(price)$ (\(percent)%)"
            }
        }
    }
}

extension DetailsViewController: InfoManagerDelegate {
    
    func didUpdateInfo(_ infoManager: InfoManager, _ info: Info) {
        coinImageView.sd_setImage(with: URL(string: info.data["\(id)"]!.logo))
        coinNameLabel.text = info.data["\(id)"]!.name
        coinSymbolLabel.text = info.data["\(id)"]!.symbol
        coinDescriptionLabel.text = info.data["\(id)"]!.description
    }
}
