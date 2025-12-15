import Foundation
import Capacitor

@objc(EnhancedHttpPlugin)
public class EnhancedHttpPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "EnhancedHttpPlugin"
    public let jsName = "CapacitorEnhancedHttp"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "unsafeGet", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "unsafePost", returnType: CAPPluginReturnPromise)
    ]

    @objc public func unsafeGet(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url"),
            let url = URL(string: urlString) else {
            call.reject("Invalid URL")
            return
        }

        // Handling headers
        let rawHeaders = call.getObject("headers") ?? [:]
        var headers: [String: String] = [:]
        for (k, v) in rawHeaders {
            headers[k] = (v as? String) ?? String(describing: v)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // apply the headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let session = URLSession(
            configuration: .default,
            delegate: UnsafeTLSDelegate(),
            delegateQueue: nil
        )

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                call.reject(error.localizedDescription)
                return
            }

            guard let http = response as? HTTPURLResponse else {
                call.reject("Invalid response")
                return
            }

            call.resolve([
                "status": http.statusCode,
                "data": String(data: data ?? Data(), encoding: .utf8) ?? ""
            ])
        }.resume()
    }

    @objc public func unsafePost(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url"),
            let url = URL(string: urlString) else {
            call.reject("Invalid URL")
            return
        }

        // Handling headers
        let rawHeaders = call.getObject("headers") ?? [:]
        var headers: [String: String] = [:]
        for (k, v) in rawHeaders {
            headers[k] = (v as? String) ?? String(describing: v)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // apply headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Body: the type can be either JSON object or string, it depends on what the user provides
        if let bodyObj = call.getObject("data") {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bodyObj, options: [])
                request.httpBody = jsonData
                // if not set, set content-type to application/json
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } catch {
                call.reject("Invalid JSON body: \(error.localizedDescription)")
                return
            }
        } else if let bodyStr = call.getString("data") {
            request.httpBody = bodyStr.data(using: .utf8)
            // if not set, set content-type to application/json
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        let session = URLSession(
            configuration: .default,
            delegate: UnsafeTLSDelegate(),
            delegateQueue: nil
        )

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                call.reject(error.localizedDescription)
                return
            }

            guard let http = response as? HTTPURLResponse else {
                call.reject("Invalid response")
                return
            }

            call.resolve([
                "status": http.statusCode,
                "data": String(data: data ?? Data(), encoding: .utf8) ?? ""
            ])
        }.resume()
    }
}

class UnsafeTLSDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}