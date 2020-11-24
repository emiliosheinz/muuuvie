//
//  MovieDetailViewModel.swift
//  Muuuvie
//
//  Created by Emilio Heinzmann on 30/10/20.
//

import Foundation

class MovieDetailViewModel: ObservableObject, ViewModelWithRequest {

    @Published var movie: MovieDetailModel?
    @Published var artists: [ArtistModel]?
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    @Published var isFavorited: Bool = false
    var message: String = ""


    func fetchMovie(id: Int) {
        self.isLoading = true
        Api.instance.request(with: .movieDetail(id: id)) { [weak self] (result: Result<MovieDetailModel, APIError>) in
            switch result {
            case .success(let movie):
                Api.instance.request(with: .movieCast(id: id)) { [weak self] (result2: Result<CastApiReturnModel, APIError>) in
                    switch result2 {
                    case .success(let castResp):
                        DispatchQueue.main.async {
                            self?.movie = movie
                            self?.artists = castResp.cast
                            self?.isLoading = false
                            self?.isFavorited = Favorites.instance.isInFavoritesList(item: movie)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self?.hasError = true
                            self?.isLoading = false
                            self?.message = error.message
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.hasError = true
                    self?.isLoading = false
                    self?.message = error.message
                }
            }
        }
    }
    
    func toggleFavorite() {
        self.isFavorited = Favorites.instance.toggle(item: movie!)
    }

}
