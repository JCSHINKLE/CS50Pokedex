import UIKit

//var caughtPokemonDict = [String: Bool]()

class PokemonViewController: UIViewController {
    var url: String!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var spriteImage: UIImageView!
    
    @IBAction func toggleCatch() {
        if UserDefaults.standard.bool(forKey: self.nameLabel.text!) == true {
            UserDefaults.standard.set(false, forKey: self.nameLabel.text!)
            catchButton.setTitle("Catch", for: [])
            //print("Toggle False = \(UserDefaults.standard.bool(forKey: self.nameLabel.text!))")
        }
        else {
            UserDefaults.standard.set(true, forKey: self.nameLabel.text!)
            catchButton.setTitle("Release", for: [])
            //print("Toggle True = \(UserDefaults.standard.bool(forKey: self.nameLabel.text!))")
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
        //print("Before Load = \(UserDefaults.standard.bool(forKey: self.nameLabel.text!))")
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
                    //print("Loading = \(UserDefaults.standard.bool(forKey: self.nameLabel.text!))")
                    if UserDefaults.standard.bool(forKey: self.nameLabel.text!) == true {
                        self.catchButton.setTitle("Release", for: [])
                    }
                    else if UserDefaults.standard.bool(forKey: self.nameLabel.text!) == false /*|| UserDefaults.standard.bool(forKey: self.nameLabel.text!) == nil*/ {
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
