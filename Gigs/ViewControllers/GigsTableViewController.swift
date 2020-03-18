//
//  GigsTableViewController.swift
//  Gigs
//
//  Created by Chris Price on 3/17/20.
//  Copyright © 2020 com.chrispriiice. All rights reserved.
//

import UIKit

class GigsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var gigController = GigController()
    private var gigs: [String] = []
    
        // MARK: - View Lifecycle
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            if gigController.bearer == nil {
                performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
            }

        }

        // MARK: - Table view data source

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return gigs.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GigsCell", for: indexPath)

            // Configure the cell...
            cell.textLabel?.text = gigs[indexPath.row]

            return cell
        }

        // MARK: - Actions
        
        @IBAction func getGigs(_ sender: UIBarButtonItem) {
            // fetch all gigs from API
        }
        
        // MARK: - Navigation

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "LoginViewModalSegue",
                let loginVC = segue.destination as? LoginViewController {
                loginVC.gigController = gigController
            }
        }
    }
