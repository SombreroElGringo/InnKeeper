//
//  ChatMessageCell.swift
//  InnKeeper
//
//  Created by Florent on 30/03/2017.
//  Copyright © 2017 SombreroElGringo. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var message: Message?
    var chatLogController: ChatLogController?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    let activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.font = .systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.isEditable = false
        return tv
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let uv = UIView()
        uv.backgroundColor = blueColor
        uv.translatesAutoresizingMaskIntoConstraints = false
        uv.layer.cornerRadius = 16
        uv.layer.masksToBounds = true
        return uv
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo_InnKeeper")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    var bubbleViewWidth: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLefttAnchor: NSLayoutConstraint?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        
        // Constraint anchors: x, y, width, height
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        
        bubbleView.addSubview(playButton)
        
        // Constraint anchors: x, y, width, height
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(activityIndicator)
        
        // Constraint anchors: x, y, width, height
        activityIndicator.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Constraint anchors: x, y, width, height
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor ).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
        // Constraint anchors: x, y, width, height
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLefttAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        //bubbleViewLeftAnchor?.isActive = false
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleViewWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidth?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        // Constraint anchors: x, y, width, height
        //textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    func handlePlay() {
        if let videoURLString = message?.videoUrl, let url = NSURL(string: videoURLString) {
            player = AVPlayer(url: url as URL)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicator.startAnimating()
            playButton.isHidden = true
            print("Play video ...")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicator.stopAnimating()
    }
}
