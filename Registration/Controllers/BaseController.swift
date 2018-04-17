//
//  BaseController.swift
//  Registration
//
//  Created by Adrian Wobito on 2018-01-09.
//  Copyright © 2018 Adrian Wobito. All rights reserved.
//

import UIKit

class BaseController : UIViewController {
    
    func toggleNetworkIndicator(show: Bool = false) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = show
    }

}
