//
//  APIServiceStub.swift
//  burgershop-finder
//
//  Created by e.vanags on 17/01/2019.
//  Copyright © 2019 esesmuedgars. All rights reserved.
//

import Foundation
import RxSwift

// TODO: Revisit
final class APIServiceStub: APIServiceProtocol {

    var description: String {
        return "application programming interface service stub"
    }

    func fetchVenues(authToken token: String) -> Observable<FSIdentifiers> {
        return Observable.create { observer -> Disposable in
            do {
                guard let path = Bundle.main.path(forResource: "identifiers", ofType: "json") else {
                    throw "Failed to find identifiers.json in application bundle."
                }

                let data = try Data(contentsOf: path, options: .mappedIfSafe)

                observer.onNext(try FSIdentifiers.parse(data: data))
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    
    func inspectVenue(authToken token: String, venueId identifier: String) -> Observable<FSDetails> {
        return Observable.create { observer -> Disposable in
            do {
                // TODO: Replace resource name with dynamic using identifier
                guard let path = Bundle.main.path(forResource: "details", ofType: "json") else {
                    throw "Failed to find details.json in application bundle."
                }

                // TODO: Investigate Data.ReadingOptions (eg. mappedIfSafe)
                let data = try Data(contentsOf: path, options: .mappedIfSafe)

                observer.onNext(try JSONDecoder().decode(FSDetails.self, from: data))
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }
}
