//
//  MoviesViewController.swift
//  tomatoes
//
//  Created by Zheng Wu on 4/9/15.
//  Copyright (c) 2015 Zheng Wu. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var movies: [NSDictionary]! = [NSDictionary]()
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var ErrorView: UIView!
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
          refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
            self.tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        self.ErrorView.hidden = true;
        
        var url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5")!
        var request = NSURLRequest(URL: url)
        //[SVProgressHUD show];
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            SVProgressHUD.showWithStatus("Connecting", maskType: SVProgressHUDMaskType.Black)
            if(error != nil) {
                self.ErrorView.hidden = false;
            } else {
                var json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                self.movies = json["movies"] as [NSDictionary]
                self.tableView.reloadData()
            }
            SVProgressHUD.dismiss()
        }
        //[SVProgressHUD dismiss];
        
        
        

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath:indexPath) as MovieCell
        
        var movie = movies[indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        var url = movie.valueForKeyPath("posters.thumbnail") as? String
        cell.posterView.setImageWithURL(NSURL(string: url!)!)
        return cell
    
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath
    , animated: true)
    }


    func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
    }

    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var movieDetailViewController = segue.destinationViewController as MovieDetailViewController
        var cell = sender as UITableViewCell
        var indexPath = tableView.indexPathForCell(cell)!
        movieDetailViewController.movie = movies[indexPath.row]
    }


}
