import Foundation
import Moya
import RxSwift
import Contacts

enum ChallengeAPI {
  case activity
}

extension ChallengeAPI: TargetType {
  var headers: [String : String]? {
    return nil
  }
  
  var baseURL: URL {
    switch self {
      case .activity:
        return URL(string: "https://file.notion.so")!
    }
  }
  
  var path: String {
    switch self {
      case .activity:
        return "f/f/e430ac3e-ca7a-48f9-804c-8fe9f7d4a267/174c6c45-c116-4762-8550-607cddb04270/activity-response-ios.json"
    }
  }
  
  var method: Moya.Method {
    return .get
  }
  
  var sampleData: Data {
    return stubbedResponse("MockGChatEligibilityResponse")
  }
  
  var task: Task {
    switch self {
      case .activity:
        return .requestParameters(
          parameters: ["table": "block",
                       "id": "111284a8-e7d3-80ea-a701-fad40b7b30ca",
                       "spaceId": "e430ac3e-ca7a-48f9-804c-8fe9f7d4a267",
                       "expirationTimestamp": "1732701600000",
                       "signature": "IZnVkkW2zSp82H07c-bNlV1sambDIt2OmFWLA42vOds",
                       "downloadName": "activity-response-ios.json"],
          encoding: URLEncoding.queryString)
    }
  }
}
