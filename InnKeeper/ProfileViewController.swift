//
//  ProfileViewController.swift
//  InnKeeper
//
//  Created by Florent on 26/03/2017.
//  Copyright © 2017 SombreroElGringo. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //--------------------------------------------- Initialization ------------------------------------------------//
    
     var user = User()
    
    //Container of the profil data
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    //Name label
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Name separator
    let nameSeparatorView: UIView  = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //Name label
    let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Button "update profile"
    let updateProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 90, g: 90, b: 90)
        button.setTitle("Update Profile", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleUpdateProfile), for: .touchUpInside)
        return button
    }()
    
    //Avatar of the profile
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectAvatarImageView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    
    //----------------------------------- View Did Load & Did Receive Memory Warning --------------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 60, g: 60, b: 60)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        
        fetchCurrentUser()
        
        view.addSubview(inputContainerView)
        view.addSubview(avatarImageView)
        view.addSubview(updateProfileButton)
        
        setupInputContainerView()
        setupAvatarImageView()
        setupUpdateProfileButton()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------------- Setup the elements -----------------------------------------//
    
    
    /**
     * Set up Input Container
     */
    
    func setupInputContainerView () {
        //need x, y, width & height constraints
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        inputContainerView.addSubview(nameLabel)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailLabel)
        
        //need x, y, width & height constraints
        nameLabel.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        nameLabel.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        //need x, y, width & height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width & height constraints
        emailLabel.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        emailLabel.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailLabel.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/2).isActive = true

    }
    
    
    /**
     * Setup Avatar
     */
    
    func setupAvatarImageView() {
        //need x, y, width & height constraints
        avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        avatarImageView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    
    /**
     * Setup Login Register Button
     */
    
    func setupUpdateProfileButton() {
        //need x, y, width & height constraints
        updateProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateProfileButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        updateProfileButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        updateProfileButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    //--------------------------------------------- Functions ------------------------------------------------//
    
    
    /**
     * Handle Avatar Image
     */
    
    func handleSelectAvatarImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    /**
     * Image Picker
     */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            avatarImageView.image = selectedImage
         }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /**
     * Handle Cancel
     */
    
    func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /**
     * Handle Update Profile Image and convert in jpeg the avatar image
     */
    
    func handleUpdateProfile() {
       
        //Current user id
        let uid = FIRAuth.auth()?.currentUser?.uid

        //Storage
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("Avatars").child("\(imageName).jpg")
        
        if let profileImage = avatarImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
            
        // Image loading too long and files fat but we lose in quality
        //if let uploadData = UIImagePNGRepresentation(avatarImageView.image!) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Error: Image fail!")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["avatarURL": imageUrl ]
                    self.profileUpdateDataIntoFireBaseWithUID(uid: uid!, values: values)
                }
            })
        }
    }
    
    /**
     * Update the avatar image in the firebase
     */
    
    private func profileUpdateDataIntoFireBaseWithUID(uid: String, values: [String: Any]) {
        //Database
        let ref = FIRDatabase.database().reference(fromURL: "https://userlogin-5741f.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            //Success
            self.dismiss(animated: true, completion: nil)
            print("User updated successfully into Firebase db!")
        })
    }
    
    /**
     * Get the current user data
     */
    
    func fetchCurrentUser() {
        //Current user id
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:Any] {
               
                self.user.name = dictionary["name"] as! String?
                self.user.email = dictionary["email"] as! String?
                self.user.avatarURL = dictionary["avatarURL"] as! String?
               
                //Name & email
                if let profileEmail = self.user.email, let profileName = self.user.name {
                    self.nameLabel.text = profileName
                    self.emailLabel.text = profileEmail
                } else {
                    self.nameLabel.text = "Name"
                    self.emailLabel.text = "Email"
                }
                
                // Avatar profile
                if let imageAvatarURL = self.user.avatarURL {
                    self.avatarImageView.loadImageUsingCacheWithURLString(urlString: imageAvatarURL)
                } else {
                    self.avatarImageView.image = UIImage(named: "Logo_InnKeeper")
                }
            }
        })
    }
}
