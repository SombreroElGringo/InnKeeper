//
//  NewMessageController.swift
//  InnKeeper
//
//  Created by Florent on 25/03/2017.
//  Copyright © 2017 SombreroElGringo. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    var messagesController: MessagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    func fetchUser() {
        let ref = FIRDatabase.database().reference()
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:Any] {
                let user = User()
                user.id = snapshot.key
                user.name = dictionary["name"] as! String?
                user.email = dictionary["email"] as! String?
                user.avatarURL = dictionary["avatarURL"] as! String?
                self.users.append(user)
                
                //Will crash without the dispatch
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Better use dequeue for the memory of the app
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let imageAvatarURL = user.avatarURL {
            
            cell.profileImageView.loadImageUsingCacheWithURLString(urlString: imageAvatarURL)
        } else {
            cell.profileImageView.image = UIImage(named: "Logo_InnKeeper")
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true){
            
            let user = self.users[indexPath.row]
            self.messagesController?.handleShowChatControllerForUser(user: user)
            //print("Message dismissed!")
        }
    }
}
