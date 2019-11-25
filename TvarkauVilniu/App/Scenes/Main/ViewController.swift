//
//  ViewController.swift
//  webViewDemo
//
//  Created by Kyle Suchar on 2/26/17.
//  Copyright © 2017 Kyle Suchar. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let URL = NSURL(string: "https://tvarkaumiesta.lt") else { return }

        webView.scrollView.delegate = self
        webView.scrollView.bounces = false
        webView.loadRequest(NSURLRequest(url: URL as URL) as URLRequest)
        webView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func goAction(_ sender: Any) {
        guard
            let text = textField.text,
            let url = NSURL(string: text)
        else {
            return
        }
        let req = NSURLRequest(url:url as URL)
        self.webView.loadRequest(req as URLRequest)
    }
    
    @IBAction func goBack(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func goFoward(_ sender: Any) {
        webView.goForward()
    }
    
}

extension ViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

}

extension ViewController: UIWebViewDelegate {

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url, let host = url.host else { return true }
        
        if host.contains("vilnius.lt") && url.path.contains("m/m_problems/files/mobile2/") {
            guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else { return true }
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return true }

            urlComponents.scheme = "https"
            urlComponents.host = "tvarkaumiesta.lt"
            urlComponents.path = url.path.replacingOccurrences(of: "m/m_problems/files/mobile2/", with: "mob_api/")

            mutableRequest.url = urlComponents.url

            webView.loadRequest(mutableRequest as URLRequest)

            return false
        }

        return true
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        loadCookies()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        saveCookies()
    }
    
    func saveCookies() {
        guard let cookies = HTTPCookieStorage.shared.cookies else {
            return
        }
        let array = cookies.compactMap { (cookie) -> [HTTPCookiePropertyKey: Any]? in
            cookie.properties
        }
        UserDefaults.standard.set(array, forKey: "cookies")
        UserDefaults.standard.synchronize()
    }

    func loadCookies() {
        guard let cookies = UserDefaults.standard.value(forKey: "cookies") as? [[HTTPCookiePropertyKey: Any]] else {
            return
        }
        cookies.forEach { (cookie) in
            guard let cookie = HTTPCookie.init(properties: cookie) else {
                return
            }
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }
}
