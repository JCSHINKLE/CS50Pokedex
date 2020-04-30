import UIKit

class PokemonViewController: UIViewController {
    var url: String!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var spriteImage: UIImageView!
    @IBOutlet var descriptionText: UITextView!

    
    @IBAction func toggleCatch() {
        if UserDefaults.standard.bool(forKey: self.nameLabel.text!) == true {
            UserDefaults.standard.set(false, forKey: self.nameLabel.text!)
            catchButton.setTitle("Catch", for: [])
        }
        else {
            UserDefaults.standard.set(true, forKey: self.nameLabel.text!)
            catchButton.setTitle("Release", for: [])
        }
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
        descriptionText.text = ""
        
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
                    do {
                        self.spriteImage.image = UIImage(data: try Data(contentsOf: URL(string: result.sprites.front_default)!))
                    }
                    catch let error {
                        print(error)
                    }
                    
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

                    if UserDefaults.standard.bool(forKey: self.nameLabel.text!) == true {
                        self.catchButton.setTitle("Release", for: [])
                    }
                    else if UserDefaults.standard.bool(forKey: self.nameLabel.text!) == false {
                        self.catchButton.setTitle("Catch", for: [])
                    }
                    self.loadDescription(id: result.id)
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    func loadDescription(id: Int) {
        URLSession.shared.dataTask(with: URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(id)")!) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let description = try JSONDecoder().decode(PokemonDescription.self, from: data)
                var first = true
                DispatchQueue.main.async {
                    for flavor in description.flavor_text_entries {
                        if flavor.language.name == "en" && first == true {
                            self.descriptionText.text = flavor.flavor_text
                            first = false
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
}
