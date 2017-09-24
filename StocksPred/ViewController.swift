//
//  ViewController.swift
//  StocksPred
//
//  Created by Shashank Mandil on 9/23/17.
//  Copyright © 2017 Shashank Mandil. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var stockSymbolTextField: UITextField!
    @IBOutlet weak var selectedDatePicker: UIDatePicker!
    @IBOutlet weak var predictButton: UIButton!
    @IBOutlet weak var predictedTextField: UITextField!
    @IBOutlet weak var oneYearTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: Actions
    @IBAction func predictStockPrice(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year: String = dateFormatter.string(from: selectedDatePicker.date)
        dateFormatter.dateFormat = "MM"
        let month: String = dateFormatter.string(from: selectedDatePicker.date)
        dateFormatter.dateFormat = "dd"
        let day: String = dateFormatter.string(from: selectedDatePicker.date)

        let predictionEndpoint: String = """
        http://e2delivery.com:5000/prediction/\(stockSymbolTextField.text ?? "AAPL")/\(day)/\(month)/\(year)
        """
        guard let url = URL(string: predictionEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)

        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest){
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on e2delivery.com")
                print(error!)
                return
            }

            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }

            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                DispatchQueue.main.sync(){
                    let outputStr = """
                    \(todo["prediction"] ?? "0.00000000")
                    """
                    let index = outputStr.index(outputStr.startIndex, offsetBy: 5)
                    self.predictedTextField.text = outputStr.substring(to: index)
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }

        task.resume()
    }
    
}

