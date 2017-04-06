//
//  MessagesController.swift
//  InnKeeper
//
//  Created by Florent on 23/03/2017.
//  Copyright © 2017 SombreroElGringo. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    var timer: Timer?
    
    //Button title NavBar Profile
    let buttonTitleNavBar: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle("Profile", for: .normal)
        button.addTarget(self, action: #selector(handleProfileView), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let image = UIImage(named: "list")
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.titleView = buttonTitleNavBar
        
        checkIfUserLoggedIn()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        observeUserMessages()
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------------- Functions ------------------------------------------------//
    
    func checkIfUserLoggedIn () {
        
        //user is not logged in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(uid).observeSingleEvent(of: .value, with:
            {(snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    
                    //let button =  UIButton(type: .custom)
                   // button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
                   self.buttonTitleNavBar.setTitle(dictionary["name"] as? String, for: .normal)
                   self.buttonTitleNavBar.addTarget(self, action: #selector(self.handleProfileView), for: .touchUpInside)
                   self.buttonTitleNavBar.setTitleColor(UIColor.black, for: .normal)
                   self.navigationItem.titleView = self.buttonTitleNavBar
                    
                   self.messages.removeAll()
                   self.messagesDictionnary.removeAll()
                   self.tableView.reloadData()
                   self.observeUserMessages()

                }
        }, withCancel: nil)
    }
    
    var messages = [Message]()
    var messagesDictionnary = [String:Message]()
    
    func observeUserMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user_messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            FIRDatabase.database().reference().child("user_messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageID(messageId: messageId)
            }, withCancel: nil)

        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionnary.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageID(messageId: String) {
        
        let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionnary[chatPartnerId] = message
                }
                self.attemptReloadTable()
            }
        }, withCancel: nil)
    }
    
    private func attemptReloadTable() {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }

    
     //--------------------------------------------- Table View Funtctions ------------------------------------------------//
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {return}
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.handleShowChatControllerForUser(user: user)
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId , for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            FIRDatabase.database().reference().child("user_messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                
                self.messagesDictionnary.removeValue(forKey: chatPartnerId)
                self.attemptReloadTable()
            })
        }
        
    }
    
    //--------------------------------------------- Handles ------------------------------------------------//
    
    
    /**
     * Handle Show Chat Controller
     */
    func handleShowChatControllerForUser(user: User) {
        let chatViewController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatViewController.user = user
        let navController = UINavigationController(rootViewController: chatViewController)
        present(navController, animated: true, completion: nil)
    }
    
    
    /**
     * Handle Profile View
     */
    func handleProfileView() {
        let profileViewController = ProfileViewController()
        let navController = UINavigationController(rootViewController: profileViewController)
        present(navController, animated: true, completion: nil)
    }
    
    
    /**
     * Handle Log out
     */
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionnary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp!.intValue > message2.timestamp!.intValue
        })
        
        //this will crash because of background thread, so we need to call this dispatch_asynch for correct it
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

