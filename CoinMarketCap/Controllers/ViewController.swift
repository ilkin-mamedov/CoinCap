import UIKit
import Alamofire
import SPAlert

class ViewController: UIViewController {
    
    var id = 0
    var cryptocurrencies = [Cryptocurrency]()
    var filteredCryptocurrencies = [Cryptocurrency]()
    var searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoinMarketCap"
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.searchController = searchController
        
        let mapManager = MapManager(delegate: self)
        mapManager.fetchMap()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { timer in
            self.setUpSearchPlaceholder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let detailsViewController = segue.destination as! DetailsViewController
            detailsViewController.id = id
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}

extension ViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredCryptocurrencies = cryptocurrencies.filter { cryptocurrency in
            return cryptocurrency.name.lowercased().contains(text.lowercased())
        }
        tableView.reloadData()
    }
}

extension ViewController: MapManagerDelegate {
    
    func didUpdateMap(_ mapManager: MapManager, _ map: Map) {
        for i in 0..<map.data.count {
            let id = map.data[i].id
            let rank = map.data[i].rank
            let name = map.data[i].name
            let symbol = map.data[i].symbol
            cryptocurrencies.append(Cryptocurrency(id: id, rank: rank, name: name, symbol: symbol))
        }
        sortCryptocurrencies()
        setUpSearchPlaceholder()
        tableView.reloadData()
    }
    
    func sortCryptocurrencies() {
        cryptocurrencies = cryptocurrencies.sorted { c1, c2 in
            c1.rank < c2.rank
        }
    }
    
    func setUpSearchPlaceholder() {
        let firstRandomName = cryptocurrencies[Int.random(in: 0...15)].name
        let secondRandomName = cryptocurrencies[Int.random(in: 0...15)].name
        searchController.searchBar.placeholder = "\(firstRandomName), \(secondRandomName) and etc."
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            return filteredCryptocurrencies.count
        } else {
            return cryptocurrencies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
        let cryptocurrency: Cryptocurrency?
        
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            cryptocurrency = filteredCryptocurrencies[indexPath.row]
        } else {
            cryptocurrency = cryptocurrencies[indexPath.row]
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "\(cryptocurrency!.rank). \(cryptocurrency!.name)"
        cell.detailTextLabel?.text = cryptocurrency!.symbol
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if NetworkReachabilityManager()!.isReachable {
            if searchController.isActive && !searchController.searchBar.text!.isEmpty {
                id = filteredCryptocurrencies[indexPath.row].id
            } else {
                id = cryptocurrencies[indexPath.row].id
            }
            performSegue(withIdentifier: "showDetails", sender: self)
        } else {
            SPAlert.present(title: "No internet connection.", message: "Please, check your internet connection and try again.", preset: .error)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
