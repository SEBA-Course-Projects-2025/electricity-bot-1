//
//  Helpers.swift
//  electricityBot
//
//  Created by Dana Litvak on 18.06.2025.
//

import UIKit

extension UIApplication {
    static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
