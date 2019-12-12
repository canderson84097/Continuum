//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Chris Anderson on 12/10/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    // MARK: - Properties
    
    var results: [SearchableRecord] = []
    var isSearching = false
    var dataSource: [SearchableRecord] {
        return isSearching ? results : PostController.shared.posts
    }
    
    // MARK - Outlets
    
    @IBOutlet weak var postSearchBar: UISearchBar!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postSearchBar.delegate = self
        performFullSync(completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.results = PostController.shared.posts
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        let post = dataSource[indexPath.row] as? Post
        cell.post = post
        return cell
    }

   // MARK: - Custom Methods
    
    func performFullSync(completion: ((Bool) -> Void)?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PostController.shared.fetchPosts { (posts) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()
                completion?(posts != nil)
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPostDetail" {
            guard let destinationVC = segue.destination as? PostDetailTableViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let post = PostController.shared.posts[indexPath.row]
            destinationVC.post = post
        }
    }
}

extension PostListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            tableView.reloadData()
        } else {
            results = PostController.shared.posts.filter{ $0.matches(searchTerm: searchText) }
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        results = PostController.shared.posts
        tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
}
