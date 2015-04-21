//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Rachana Bedekar on 4/18/15.
//  Copyright (c) 2015 Rachana Bedekar. All rights reserved.
//

import UIKit

    //TODO: Set the TMDB Developer API key here (You can request it from https://www.themoviedb.org)
    let APIkey : String = ""

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var networkErrorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //Check network reachability
        if (false == hasNetworkConnectivity()){
            networkErrorView.hidden = false
        }
        else {
            networkErrorView.hidden = true
            onRefresh()
        }

        tableView.setContentOffset(CGPointMake(0, networkErrorView.frame.size.height), animated: true)

        
        monitorNetworkConnectivity()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hasNetworkConnectivity() -> Bool {
        return AFNetworkReachabilityManager.sharedManager().reachable;
    }
    
    func monitorNetworkConnectivity() {
        var connected = true
        // -- Start monitoring network reachability (globally available) -- //
        AFNetworkReachabilityManager.sharedManager()!.startMonitoring()
        AFNetworkReachabilityManager.sharedManager()!.setReachabilityStatusChangeBlock( { (status:AFNetworkReachabilityStatus)in
            switch (status) {
            case AFNetworkReachabilityStatus.ReachableViaWWAN:
                connected = true
            case AFNetworkReachabilityStatus.ReachableViaWiFi:
                connected = true
                
            case AFNetworkReachabilityStatus.NotReachable:
                connected = false
                
            default:
                connected = false
            }
        })
    }

    func onRefresh() {
        let url = NSURL(string: "http://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=" + APIkey)!
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!, data:NSData!, error: NSError!) ->
            Void in
            if data == nil
            {
                self.networkErrorView.hidden = false
                self.tableView.headerViewForSection(0)?.hidden = false
            }
            else {
                self.networkErrorView.hidden = true
                self.tableView.headerViewForSection(0)?.hidden = true
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
            
            if let json = json{
                self.movies = json["results"] as? [NSDictionary]
                println(json)
                self.tableView.reloadData()
            }
            }
        })
            self.refreshControl.endRefreshing()
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        let vote = (movie["vote_average"] as? Double)!
        cell.synopsisLabel.text =  String(format:"%0.1f/10", vote)
        var posterURL = NSURL ( string: "http://image.tmdb.org/t/p/w500" + (movie["poster_path"]! as! String))
        cell.posterView.setImageWithURL(posterURL)
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        let movie = movies![indexPath.row]
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        
        movieDetailsViewController.movie = movie
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
