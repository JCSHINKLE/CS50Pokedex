import UIKit
var caughtPokemonDict = [String: Bool]()
class PokemonViewController: UIViewController {
    var url: String!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    
    @IBAction func toggleCatch() {
        if caughtPokemonDict[self.nameLabel.text!] == true {
            caughtPokemonDict[self.nameLabel.text!] = false
            catchButton.setTitle("Catch", for: [])
            return
        }
        caughtPokemonDict[self.nameLabel.text!] = true
        catchButton.setTitle("Release", for: [])
        return
    }
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        catchButton.setTitle("", for: [])
        
        loadPokemon()
    }

    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                    if caughtPokemonDict[self.nameLabel.text!] == true {
                        self.catchButton.setTitle("Release", for: [])
                    }
                    else if caughtPokemonDict[self.nameLabel.text!] == false || caughtPokemonDict[self.nameLabel.text!] == nil {
                        self.catchButton.setTitle("Catch", for: [])
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
}
