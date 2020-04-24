import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
    var pokemon: [PokemonListResult] = []
    var filterpokemon: [PokemonListResult] = []
    
    var isFiltering: Bool = false

    @IBOutlet var searchBar: UISearchBar!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchValue = searchText
        
        isFiltering = true
        
        filterpokemon = pokemon.filter { (pokemon: PokemonListResult) -> Bool in
            return pokemon.name.lowercased().contains(searchValue.lowercased())
        }
        
        if searchText == "" {
            isFiltering = false
        }
        tableView.reloadData()
    }
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self

        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filterpokemon.count
        }
        return pokemon.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)

        if isFiltering {
            cell.textLabel?.text = capitalize(text: filterpokemon[indexPath.row].name)
            return cell
        }
        
        cell.textLabel?.text = capitalize(text: pokemon[indexPath.row].name)
        return cell
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            if isFiltering {
                destination.url = filterpokemon[index].url
            }
            else {
                destination.url = pokemon[index].url
            }
        }
    }
}
