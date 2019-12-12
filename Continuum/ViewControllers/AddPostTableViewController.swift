//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Chris Anderson on 12/11/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    // MARK: - Properties
    
    var selectedImage: UIImage?
    
    // MARK: - Outlets
    
    @IBOutlet weak var captionTextField: UITextField!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captionTextField.text = nil
    }
    
    // MARK: - Actions
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        guard let photo = selectedImage,
            let caption = captionTextField.text, !caption.isEmpty else { return }
        PostController.shared.createPostWith(photo: photo, caption: caption) { (post) in
            DispatchQueue.main.async {
               self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoSelector" {
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
        }
    }
}

extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
    }
}
