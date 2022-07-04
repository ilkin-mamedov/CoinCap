import UIKit
import RealmSwift

class ViewController: UIViewController {

    var searchController = UISearchController(searchResultsController: nil)
    var coinObjects: Results<CoinObject>?
    var coins = [Coin]()
    var filteredCoins = [Coin]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var assetManager = AssetManager()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoinCap"
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.tintColor = UIColor(named: "AccentColor")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CoinTableViewCell", bundle: nil), forCellReuseIdentifier: "CoinTableViewCell")
        tableView.rowHeight = 50
        
        assetManager.delegate = self
        
        loadCoins(notification: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadCoins(notification:)), name: NSNotification.Name(rawValue: "loadCoins"), object: nil)
    }
    
    @objc func loadCoins(notification: NSNotification?) {
        coins.removeAll()
        coinObjects = realm.objects(CoinObject.self)
        for coin in realm.objects(CoinObject.self) {
            assetManager.fetchAsset(by: coin.id)
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}

extension ViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredCoins = coins.filter { asset in
            guard let name = asset.name else { return false }
            return name.lowercased().contains(text.lowercased())
        }
        tableView.reloadData()
    }
}

extension ViewController: AssetManagerDelegate {
    
    func didUpdateAsset(_ assetManager: AssetManager, _ asset: Asset) {
        coins.append(asset.data)
        coins.sort { coin1, coin2 in
            coin1.name ?? "Unknown" < coin2.name ?? "Unknown"
        }
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            return filteredCoins.count
        } else {
            return coins.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinTableViewCell", for: indexPath) as! CoinTableViewCell
        
        let coin: Coin?
        
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            coin = filteredCoins[indexPath.row]
        } else {
            coin = coins[indexPath.row]
        }
        
        if let safeCoin = coin {
            cell.rankLabel.text = "\(indexPath.row + 1)"
            cell.nameLabel.text = "\(safeCoin.name ?? "Unknown")"
            cell.symbolLabel.text = "\(safeCoin.symbol ?? "Unknown")"
            cell.priceLabel.text = "$\(safeCoin.getRoundedPrice())"
            if safeCoin.getRoundedPercent() < 0 {
                cell.percentLabel.textColor = .systemRed
                cell.percentLabel.text = "\(safeCoin.getRoundedPercent())%"
            } else {
                cell.percentLabel.textColor = .systemGreen
                cell.percentLabel.text = "+\(safeCoin.getRoundedPercent())%"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        if self.searchController.isActive && !searchController.searchBar.text!.isEmpty {
            return nil
        } else {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                
                if let coinObject = self.coinObjects?[indexPath.row] {
                    do {
                        try self.realm.write {
                            self.realm.delete(coinObject)
                        }
                    } catch {
                        print(error)
                    }
                    
                    self.coins.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
                
                completionHandler(true)
            }
            
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        }
    }
}
