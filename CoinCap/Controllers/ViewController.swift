import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    var filterActions: [UIAction] {
        return [
            UIAction(title: "Sort by alphabet", image: nil, handler: { (_) in
                UserDefaults.standard.set("alphabet", forKey: "sort")
                self.loadCoins(notification: nil)
            }),
            UIAction(title: "Sort by price (low)", image: nil, handler: { (_) in
                UserDefaults.standard.set("lowPrice", forKey: "sort")
                self.loadCoins(notification: nil)
            }),
            UIAction(title: "Sort by price (high)", image: nil, handler: { (_) in
                UserDefaults.standard.set("highPrice", forKey: "sort")
                self.loadCoins(notification: nil)
            }),
            UIAction(title: "Sort by change (low)", image: nil, handler: { (_) in
                UserDefaults.standard.set("lowChange", forKey: "sort")
                self.loadCoins(notification: nil)
            }),
            UIAction(title: "Sort by change (high)", image: nil, handler: { (_) in
                UserDefaults.standard.set("highChange", forKey: "sort")
                self.loadCoins(notification: nil)
            })
        ]
    }

    var filterMenu: UIMenu {
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: filterActions)
    }

    var searchController = UISearchController(searchResultsController: nil)
    var coins = [Coin]()
    var filteredCoins = [Coin]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var assetManager = AssetManager()
    let realm = try! Realm()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCoins(notification: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadCoins(notification:)), name: NSNotification.Name(rawValue: "loadCoins"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoinCap"
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.tintColor = UIColor(named: "AccentColor")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItems!.append(UIBarButtonItem(title: "Sort", image: UIImage(systemName: "slider.horizontal.3"), primaryAction: nil, menu: filterMenu))

        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CoinTableViewCell", bundle: nil), forCellReuseIdentifier: "CoinTableViewCell")
        tableView.rowHeight = 50
        
        assetManager.delegate = self
    }
    
    @objc func loadCoins(notification: NSNotification?) {
        coins.removeAll()
        if realm.objects(CoinObject.self).isEmpty {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
            for coin in realm.objects(CoinObject.self) {
                assetManager.fetchAsset(by: coin.id)
            }
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
        
        if filteredCoins.isEmpty {
            filteredCoins = coins.filter { asset in
                guard let symbol = asset.symbol else { return false }
                return symbol.lowercased().contains(text.lowercased())
            }
        }
        
        tableView.reloadData()
    }
}

extension ViewController: AssetManagerDelegate {
    
    func didUpdateAsset(_ assetManager: AssetManager, _ asset: Asset) {
        coins.append(asset.data)
        sortCoins()
        tableView.reloadData()
    }
    
    func sortCoins() {
        switch UserDefaults.standard.string(forKey: "sort") {
        case "alphabet":
            coins.sort { coin1, coin2 in
                coin1.name ?? "Unknown" < coin2.name ?? "Unknown"
            }
        case "lowPrice":
            coins.sort { coin1, coin2 in
                Double(coin1.priceUsd ?? "0.00") ?? 0.00 < Double(coin2.priceUsd ?? "0.00") ?? 0.00
            }
        case "highPrice":
            coins.sort { coin1, coin2 in
                Double(coin1.priceUsd ?? "0.00") ?? 0.00 > Double(coin2.priceUsd ?? "0.00") ?? 0.00
            }
        case "lowChange":
            coins.sort { coin1, coin2 in
                Double(coin1.changePercent24Hr ?? "0.00") ?? 0.00 < Double(coin2.changePercent24Hr ?? "0.00") ?? 0.00
            }
        case "highChange":
            coins.sort { coin1, coin2 in
                Double(coin1.changePercent24Hr ?? "0.00") ?? 0.00 > Double(coin2.changePercent24Hr ?? "0.00") ?? 0.00
            }
        default:
            coins.sort { coin1, coin2 in
                coin1.name ?? "Unknown" < coin2.name ?? "Unknown"
            }
        }
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
            if UIImage(named: "\(safeCoin.symbol?.lowercased() ?? "")") == nil {
                cell.coinImageView.image = UIImage(named: "coin")
            } else {
                cell.coinImageView.image = UIImage(named: "\(safeCoin.symbol?.lowercased() ?? "")")
            }
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
                
                self.assetManager.delete(at: indexPath)
                self.coins.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.emptyLabel.isHidden = !self.coins.isEmpty
                
                completionHandler(true)
            }
            
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        }
    }
}
