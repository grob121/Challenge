import Foundation
import Moya
import RxSwift

typealias ChallengeResult = Result<ChallengeActivityResponse, ChallengeActivityErrorResponse>

protocol ChallengeAdapterType {
  func getActivity() -> Observable<ChallengeResult>
}

class ChallengeAdapter: ChallengeAdapterType {
  var provider: MoyaProvider<ChallengeAPI>!
  
  init() {
    self.provider = MoyaProvider<ChallengeAPI>()
  }
  
  func getActivity() -> Observable<ChallengeResult> {
    let decoder = JSONDecoder()
    return Observable.create { observer in
      
      _ = self.provider
        .rx
        .request(.activity)
        .filterSuccessfulStatusAndRedirectCodes()
        .subscribe(onSuccess: { (response) in
          guard (200...299).contains(response.statusCode) else {
            observer.onNext(.failure(ChallengeActivityErrorResponse()))
            return
          }
          
          do {
            let response = try decoder.decode(ChallengeActivityResponse.self, from: response.data)
            observer.onNext(.success(response))
          } catch {
            observer.onNext(.failure(ChallengeActivityErrorResponse()))
          }
        }, onFailure: { error in
          observer.onError(error)
        })
      
      return Disposables.create()
    }
  }
}
