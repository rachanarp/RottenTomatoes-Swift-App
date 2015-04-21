//
//  MovieDetailsViewController.swift
//  Rotten Tomatoes
//
//  Created by Rachana Bedekar on 4/18/15.
//  Copyright (c) 2015 Rachana Bedekar. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    var movie: NSDictionary!
    var movieDetails: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = movie["title"] as? String
        self.title = movie["title"] as? String
        
        let id = movie["id"] as! Double
        let idStr = String (format: "%.0f", id)
        
        SVProgressHUD.show()
        
        delay(0.5, closure: {
        // Query the Movie information
        let url = NSURL(string: String(format: "http://api.themoviedb.org/3/movie/" + idStr + "?api_key=" + APIkey))!
        
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!, data:NSData!, error: NSError!) ->
            Void in
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
            
            if let json = json{
                self.movieDetails = json
                println(json)
                self.synopsisLabel.text = self.movieDetails["overview"] as? String
                SVProgressHUD.dismiss()
            }
            })
            })
        
        
        var posterURL = NSURL ( string: "http://image.tmdb.org/t/p/w500" + (movie["poster_path"]! as! String))
        movieImageView.setImageWithURL(posterURL)
    
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
