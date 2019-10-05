//
//  HomeViewModel.swift
//  burgershop-finder
//
//  Created by e.vanags on 24/11/2018.
//  Copyright © 2018 esesmuedgars. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

final class HomeViewModel {

    private let locationService: LocationServiceProtocol
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol

    private lazy var userAuthorized = false

    private(set) lazy var disposeBag = DisposeBag()

    public lazy var items = BehaviorRelay(value: FSIdentifiers())

    private(set) lazy var details: BehaviorSubject<FSDetails?> = BehaviorSubject(value: nil)

    let userLocationUpdated: Driver<CLLocationCoordinate2D>

    let userLocationUpdate = PublishSubject<MKUserLocation>()
    let focusLocationTaps = PublishSubject<Void>()

    private let _requestLocationServices = ReplaySubject<Void>.create(bufferSize: 1)
    var requestLocationServices: Observable<Void> {
        return _requestLocationServices.asObservable()
    }

    init(apiService: APIServiceProtocol = Dependencies.shared.apiService(),
         authService: AuthServiceProtocol = Dependencies.shared.authService(),
         locationService: LocationServiceProtocol = Dependencies.shared.locationService()) {
        self.locationService = locationService
        self.apiService = apiService
        self.authService = authService

        let initialUserLocation = userLocationUpdate.take(1)

        let focusUserLocation = focusLocationTaps
            .withLatestFrom(userLocationUpdate)

        userLocationUpdated = Observable<MKUserLocation>.merge(initialUserLocation, focusUserLocation)
            .map { $0.coordinate }
            .startWith(.default)
            .asDriver(onErrorJustReturn: .default)

        bindRx()
    }

    // TODO:
    // Gives this more taught.
    // Location is not used with APIs, don't want to block from using app without location
    // Should force user to grant location permission?
    private var permitted = false

    private func bindRx() {
        authService.authToken
            .subscribe(onNext: { [weak self] authToken in
                self?.fetchVenues(authToken: authToken!)
            }, onError: { [weak self] error in
                self?.userAuthorized = false
                print(error)
            })
            .disposed(by: disposeBag)

        locationService.initialAuthorizationStatus
            .subscribe(onSuccess: { [weak self] status in
                if status == .notDetermined || status == .restricted || status == .denied {
                    self?._requestLocationServices.onNext(())
                }

                self?.permitted = true
            })
            .disposed(by: disposeBag)
    }

    func authorize(_ viewController: UIViewController) {
        if !userAuthorized && permitted {
            authService.authorize(viewController)
            userAuthorized = true
        }
    }

    private func fetchVenues(authToken: String) {
        apiService.fetchVenues(authToken: authToken)
            .subscribe(onNext: { [items] venues in
                items.accept(venues)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }

    func cellModel(forVenueWith identifier: String) -> VenueCellModel {
        let cellModel = VenueCellModel(forVenueWith: identifier)
        cellModel.venueDetails.bind(to: details).disposed(by: disposeBag)

        return cellModel
    }
}
