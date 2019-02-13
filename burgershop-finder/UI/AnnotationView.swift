//
//  AnnotationView.swift
//  burgershop-finder
//
//  Created by e.vanags on 10/12/2018.
//  Copyright © 2018 esesmuedgars. All rights reserved.
//

import UIKit
import MapKit

final class AnnotationView: SetupAnnotationView {

    var button = UIButton(type: .detailDisclosure)

    convenience init(annotation: MKAnnotation?) {
        self.init(annotation: annotation, reuseIdentifier: "AnnotationView")
    }

    override func setup() {
        canShowCallout = true

        let size = CGSize(width: 25, height: 35)
        image = UIImage(named: "Marker")?.withSize(size)
        rightCalloutAccessoryView = button

    }

    func setImage(_ image: UIImage?) {
        let size = CGSize(width: 20, height: 20)
        leftCalloutAccessoryView = UIImageView(image: image?.withSize(size))
    }
}
