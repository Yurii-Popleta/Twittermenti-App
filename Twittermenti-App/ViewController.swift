
import UIKit
import CoreML
import SwifteriOS
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
     
    let tweetCount = 100
    
    let sentimentClassifier = MyTextClassifier_1()
    
    let swifter = Swifter(consumerKey: "LTReJyreyyuz4SWjVABuA1WKI", consumerSecret: "ajf107xfd6869heCG8Ptn8iztfFHBWPIxLkFGvsmoEwI7MKZcz")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
    }

    @IBAction func predictPressed(_ sender: Any) {
          fetchTweets()
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fetchTweets()
        textField.text = ""
        return textField.endEditing(true)
    }
    
    
     func fetchTweets() {
         
         if let searchText = textField.text {
             
             swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended) { results, searchMetadata in
                 
                 var tweets = [MyTextClassifier_1Input]()
                 
                 for i in 0..<self.tweetCount {
                     if let tweet = results[i]["full_text"].string {
                         let tweetForClassification = MyTextClassifier_1Input(text: tweet)
                         tweets.append(tweetForClassification)
                     }
                 }
                 self.makePrediction(with: tweets)
             } failure: { error in
                 print("There was an error with the Twitter api Request, \(error)")
             }
         }
     }
     
     func makePrediction(with tweets: [MyTextClassifier_1Input]) {
         
         do {
            let prediction = try self.sentimentClassifier.predictions(inputs: tweets)
             
             var sentimentScore = 0
             
             for pred in prediction {
                 let sentiment = pred.label
                 
                 if sentiment == "Pos" {
                     sentimentScore += 1
                 } else if sentiment == "Neg" {
                     sentimentScore -= 1
                 }
             }
             
             updateUI(sentimentScore)
             
         } catch {
             print("There was error with making a prediction, \(error)")
         }
         
     }
     
     func updateUI(_ sentimentScore: Int) {
         
         if sentimentScore > 20 {
             self.sentimentLabel.text = "😍"
         } else if sentimentScore > 10 {
             self.sentimentLabel.text = "😀"
         } else if sentimentScore > 0 {
             self.sentimentLabel.text = "🙂"
         } else if sentimentScore == 0 {
             self.sentimentLabel.text = "😐"
         } else if sentimentScore > -10 {
             self.sentimentLabel.text = "😕"
         } else if sentimentScore > -20 {
             self.sentimentLabel.text = "😡"
         } else {
             self.sentimentLabel.text = "🤮"
         }
         
     }
     
}


