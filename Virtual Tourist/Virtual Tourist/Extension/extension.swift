//
//  extension.swift
//  Virtual Tourist
//
//  Created by بشاير الخليفه on 03/05/1441 AH.
//  Copyright © 1441 -. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
