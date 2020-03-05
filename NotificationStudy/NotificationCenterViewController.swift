//
//  NotificationCenterViewController.swift
//  NotificationStudy
//
//  Created by 김정민 on 2020/03/05.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit

class NotificationCenterViewController: UIViewController {

    /*
        Notification Center and Notification
     1. 텍스트가 입력받았을때 해당 텍스트 값을 전달해주는 notification 생성
     --> ComposeViewController 에서부터 시작
     2. Compose에서 보낸 Notification 을 받아서 Label에 보여줄 메서드 생성
     --> selector로 만들어야함
     3. Notification을 받을 observer 생성
     --> selector를 매개변수로 주는 observer로 생성
     4. 기존에 생성된 Observer가 있으면 deinit을 통해 제거해줘야함
     5. Notification을 메인 스레드가 아닌 다른 스레드에서 처리하게 할 수 있음
     --> 다시 ComposeViewController 에서 작업
     6. 이 때 옵저버는 메인에서 실행하도록 처리해줘야함
     --> 이건 UILabel의 경우고, 경우에 따라서 다름. 스레드 때문에 에러 나면 다 표시됨
     --> 2번에 구현한 메서드에 thread에 따라 다르게 처리하도록 분기
     7. clouser와 thread를 직접 설정해주는 observer 생성
     --> 이 경우 삭제를 위해 NSObjectProtocol을 상속받는 변수를 만들어서 그 변수에 담아서 사용해줘야함
     --> weak self 사용 (이부분은 강의 다시 들어야할듯...)
     8. 기 생성된 옵저버를 해지해줘야함
     */
    
    @IBOutlet weak var valueLabel: UILabel!
    
    // observer 받을 변수 (7)
    var token : NSObjectProtocol?
    
    // Text Field 값을 받아서 보여줌 메서드 (2)
    @objc func process(notification : Notification){
        guard let value = notification.userInfo?["NewValue"] as? String else {return}
        
        // 쓰레드에 다르게 처리하도록 분기해줌 (6)
        if Thread.isMainThread{     // Main Thread
            valueLabel.text = value
        }else{                      // Background Thread
            DispatchQueue.main.async {
                self.valueLabel.text = value
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // selector로 처리해주는 observer 생성 (3)
        // object를 통해 특정 sender를 확인할 수 있음. nil로 쓸 경우 확인안함
        NotificationCenter.default.addObserver(self, selector: #selector(process(notification:)), name: NSNotification.Name.NewValueDidInsert, object: nil)
        
        // 또다른 방법의 observer 생성 (7)
        token = NotificationCenter.default.addObserver(forName: NSNotification.Name.NewValueDidInsert, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            // 값을 string으로 넘겨주기 때문에 타입캐스팅을 꼭 해줘야함
            guard let value = noti.userInfo?["NewValue"] as? String else {return}
            
            self?.valueLabel.text = value
        })
    }
    
    deinit {
        // 기 생성된 Observer 제거 (4)
        NotificationCenter.default.removeObserver(self)
        
        // 기 생성된 두번째 Observer 제거 (8)
        if let token = token{
            NotificationCenter.default.removeObserver(token)
        }
    }

}
