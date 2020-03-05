//
//  ComposeViewController.swift
//  NotificationStudy
//
//  Created by 김정민 on 2020/03/05.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit

// Text Field용 Notification 이름 생성 (1)
extension NSNotification.Name{
    static let NewValueDidInsert = NSNotification.Name("NewValueDidInputNotification")
}

class ComposeViewController: UIViewController {

    /*
       Notification Center and Notification
     1. Textfield값을 전송해주는 notification 전송
     --> 새로운 이름을 정할땐 Notification.Name 의 구조 그대로 가야 좋음
     --> 이름은 기존 것과 겹치면 안됨
    2. Notification을 Background Thread에서 처리하도록 추가
    */
    
    @IBOutlet weak var inputField: UITextField!
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // TextField 값을 가져가는 Notification 전송 (1)
    @IBAction func postValue(_ sender: Any) {
        guard let text = inputField.text else{return}
        // object에는 notification을 보낸 곳을 설정할때 씀
        // nil을 쓸 경우 구분을 안지음
        // 동일한 Notification이라도 동작이 다를땐 구분지어서 보내줘야함
        // 이상태에서는 Main Thread에서 보냄
        NotificationCenter.default.post(name: NSNotification.Name.NewValueDidInsert, object: nil, userInfo: ["NewValue" : text])
        
        dismiss(animated: true, completion: nil)
    }
    
    // Main이 아닌 Background Thread에서 처리 (2)
    @IBAction func postValue2(_ sender: Any) {
        guard let text = inputField.text else{return}
        
        DispatchQueue.global().async {
            NotificationCenter.default.post(name: NSNotification.Name.NewValueDidInsert, object: nil, userInfo: ["NewValue" : text])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        inputField.resignFirstResponder()
    }
}
