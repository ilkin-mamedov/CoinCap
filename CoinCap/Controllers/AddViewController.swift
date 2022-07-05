import UIKit

class AddViewController: UIViewController {
    
    var searchController = UISearchController(searchResultsController: nil)
    var coins = [Coin]()
    var filteredCoins = [Coin]()
    
    var assetsManager = AssetsManager()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.tintColor = UIColor(named: "AccentColor")
        navigationItem.searchController = searchController
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CoinTableViewCell", bundle: nil), forCellReuseIdentifier: "CoinTableViewCell")
        tableView.rowHeight = 50
        
        assetsManager.delegate = self
        assetsManager.fetchAssets()
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension AddViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
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

extension AddViewController: AssetsManagerDelegate {
    
    func didUpdateAssets(_ assetsManager: AssetsManager, _ assets: Assets) {
        self.coins = assets.data
        tableView.reloadData()
    }
}

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            
            if assetsManager.isAlreadyExists(by: safeCoin.id ?? "") {
                if UIImage(named: "\(safeCoin.symbol?.lowercased() ?? "")") == nil {
                    cell.coinImageView.image = imageMonochrome(UIImage(named: "coin")!)
                } else {
                    cell.coinImageView.image = imageMonochrome(UIImage(named: "\(safeCoin.symbol?.lowercased() ?? "")")!)
                }
                
                cell.rankLabel.textColor = .gray
                cell.nameLabel.textColor = .gray
                cell.symbolLabel.textColor = .gray
            } else {
                if UIImage(named: "\(safeCoin.symbol?.lowercased() ?? "")") == nil {
                    cell.coinImageView.image = UIImage(named: "coin")
                } else {
                    cell.coinImageView.image = UIImage(named: "\(safeCoin.symbol?.lowercased() ?? "")")
                }
                
                cell.rankLabel.textColor = .label
                cell.nameLabel.textColor = .label
                cell.symbolLabel.textColor = .label
            }
            
            cell.rankLabel.text = "\(safeCoin.rank ?? "Unknown")"
            cell.nameLabel.text = "\(safeCoin.name ?? "Unknown")"
            cell.symbolLabel.text = "\(safeCoin.symbol ?? "Unknown")"
            cell.priceLabel.isHidden = true
            cell.percentLabel.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            if !assetsManager.isAlreadyExists(by: filteredCoins[indexPath.row].id ?? "") {
                assetsManager.add(by: filteredCoins[indexPath.row].id ?? "")
                dismiss(animated: true)
                dismiss(animated: true)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            if !assetsManager.isAlreadyExists(by: coins[indexPath.row].id ?? "") {
                assetsManager.add(by: coins[indexPath.row].id ?? "")
                dismiss(animated: true)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    func imageMonochrome(_ image: UIImage) -> UIImage? {
        guard let currentCGImage = image.cgImage else { return nil }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(currentCIImage, forKey: "inputImage")

        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")

        filter?.setValue(1.0, forKey: "inputIntensity")
        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        } else {
            return nil
        }
    }
}
