import Foundation
import Moya
import RxSwift

func stubbedResponse(_ filename: String) -> Data! {
  @objc class TestClass: NSObject { }
  
  let bundle = Bundle(for: TestClass.self)
  let path = bundle.path(forResource: filename, ofType: "json")
  return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
}
