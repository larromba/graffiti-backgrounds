import Foundation

// sourcery: name = URLSession
protocol URLSessioning: Mockable {
    func dataTask(with url: URL,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func downloadTask(with url: URL,
                      completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
}
extension URLSession: URLSessioning {}