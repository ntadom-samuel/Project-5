//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController,
                      UITableViewDataSource{
    
    
    
    private var posts: [Post] = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        // Get the movie-associated table view row
        let post = posts[indexPath.row]
        
        // Configure the cell (i.e., update UI elements like labels, image views, etc.)
    
        
        // Unwrap the optional poster path
        if let posterPath = post.photos,

            // Create a url by appending the poster path to the base url. https://developers.themoviedb.org/3/getting-started/images
           let imageUrl = URL(string:"\( posterPath[0].originalSize.url)") {

            // Use the Nuke library's load image function to (async) fetch and load the image from the image URL.
            Nuke.loadImage(with: imageUrl, into: cell.posterImageView)
        }
        
        // Set the text on the labels
        cell.titleLabel.text = post.caption
        cell.overviewLabel.text = post.summary
        
        // Return the cell for use in the respective table view row
        return cell
    }
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        
        fetchPosts()
    }
    
    
    
    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("❌ Data is NIL")
                return
            }
            
            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)
                let posts = blog.response.posts
                
                DispatchQueue.main.async { [weak self] in
                    
                    self?.posts = posts
                    
                    self?.tableView.reloadData()
                    
                    let posts = blog.response.posts
                    
                    
                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                }
                
            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
