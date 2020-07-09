//
//  SelectCountryViewController.swift
//  Lego
//
//  Created by Shreyas Patankar on 3/23/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import UIKit

protocol SelectCountryDelegate {
    func changeCountry(country: Country)
}

class SelectCountryViewController: UIViewController {

    @IBOutlet weak var selectCountryBGLabel: UILabel!
    @IBOutlet weak var selectCountryLabel: UILabel!
    @IBOutlet weak var countriesTableView: UITableView!
    
    var delegate: SelectCountryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countriesTableView.dataSource = self
        countriesTableView.delegate = self

        selectCountryLabel.textColor = LegoColorConstants.white
        selectCountryBGLabel.backgroundColor = LegoColorConstants.darkBlue
    }
    
}

extension SelectCountryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loginSession.countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.item
        let country = loginSession.countries[index]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath) as? CountryTableCell {
            cell.flagLabel.text = country.flag
            cell.countryLabel.text = country.name + " (+\(country.code ?? 0))"
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenCountry = loginSession.countries[indexPath.item]
        delegate?.changeCountry(country: chosenCountry)
        self.dismiss(animated: true)
    }
    
}
