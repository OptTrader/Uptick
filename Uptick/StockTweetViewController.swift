//
//  StockTweetViewController.swift
//  Uptick
//
//  Created by Chris Kong on 12/20/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit

class StockTweetViewController: UIViewController {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var sinceCreatedDate: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedTweet: EquityTweet?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureData()
    }

    fileprivate func configureView() {
        view.backgroundColor = ColorScheme.primaryBackgroundColor
        userLabel.textColor = ColorScheme.cellSecondaryTextColor
        sinceCreatedDate.textColor = ColorScheme.cellSecondaryTextColor
        tweetTextView.textColor = ColorScheme.cellPrimaryTextColor
        tweetTextView.sizeToFit()
        
        // Profile Picture
        profilePictureImageView.layer.borderWidth = 1
        profilePictureImageView.layer.masksToBounds = false
        profilePictureImageView.layer.borderColor = UIColor.black.cgColor
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.height/2
        profilePictureImageView.clipsToBounds = true
        
        
    }
    
    fileprivate func configureData() {
        if let tweet = selectedTweet {
            title = tweet.title!
            userLabel.text = "\(tweet.name!) @\(tweet.userName!)"
            sinceCreatedDate.text = tweet.sinceCreated!
            tweetTextView.text = tweet.tweet!
            profilePictureImageView.image = nil
            profilePictureImageView.downloadedFrom(link: tweet.avatarUrl!)
            imageView.image = nil
            imageView.downloadedFrom(link: tweet.imageUrl!)
        } else {
            title = ""
            userLabel.text = ""
            sinceCreatedDate.text = ""
            tweetTextView.text = ""
            profilePictureImageView.image = nil
            imageView.image = nil
        }
    }
    

    
    
}

