import UIKit
import MDCSwipeToChoose
import Parse
import ParseUI

class ChooseViewController: UIViewController, MDCSwipeToChooseDelegate {
    
    var currMsg:[Message] = []
    var messages:[[Message]] = [[]]
    let ChoosePersonButtonHorizontalPadding:CGFloat = 80.0
    let ChoosePersonButtonVerticalPadding:CGFloat = 20.0
    var frontCardView:ChooseView!
    var backCardView:ChooseView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //initData()
        //self.messages = defaultMessage()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //initData()
        //self.messages = defaultMessage()
    }

    override func viewDidLoad(){
        super.viewDidLoad()
        // Display the first ChoosePersonView in front. Users can swipe to indicate
        // whether they like or dislike the person displayed.
        self.setMyFrontCardView(self.popPhotoViewWithFrame(frontCardViewFrame())!)
        self.view.addSubview(self.frontCardView)
        
        // Display the second ChoosePersonView in back. This view controller uses
        // the MDCSwipeToChooseDelegate protocol methods to update the front and
        // back views after each user swipe.
        self.backCardView = self.popPhotoViewWithFrame(backCardViewFrame())!
        self.view.insertSubview(self.backCardView, belowSubview: self.frontCardView)
        
        // Add buttons to programmatically swipe the view left or right.
        constructLButton()//not used
        constructRButton()//not used
        }
    func suportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    // This is called when a user didn't fully swipe left or right.
    func viewDidCancelSwipe(view: UIView) {
        
    }
    
    // This is called then a user swipes the view fully left or right.
    func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void{

        if(wasChosenWithDirection == MDCSwipeDirection.Left){
            
        }
        else{
            
        }
        
        // MDCSwipeToChooseView removes the view from the view hierarchy
        // after it is swiped (this behavior can be customized via the
        // MDCSwipeOptions class). Since the front card view is gone, we
        // move the back card to the front, and create a new back card.
        if(self.backCardView != nil){
            self.setMyFrontCardView(self.backCardView)
        }
        
        backCardView = self.popPhotoViewWithFrame(self.backCardViewFrame())
        //if(true){
        // Fade the back card into view.
        if(backCardView != nil){
            self.backCardView.alpha = 0.0
            self.view.insertSubview(self.backCardView, belowSubview: self.frontCardView)
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.backCardView.alpha = 1.0
                },completion:nil)
        }
    }
    func setMyFrontCardView(frontCardView:ChooseView) {
        
        // Keep track of the phx currently being chosen.
        // Quick and dirty, just for the purposes of this sample app.
        self.frontCardView = frontCardView
        self.currMsg = frontCardView.msg
    }

    func initData(){
        var index = 0
        var section = 0
        var pid = ""
        var currentDate:NSDate?
        
        if messages.count <= 1
        {
            let query:PFQuery = PFQuery(className:"Messages")
            query.orderByAscending("pid")
            
            let contents:[PFObject]
            
            do {
                contents = try query.findObjects()
            } catch _ {
                return
            }
            for object in contents {
                
                let message = Message(incoming: object["incoming"] as! Bool, text: object["text"] as! String, sentDate: object["sentDate"] as! NSDate, imgurl: object["imgurl"] as! String, pid: object["pid"] as! String)
                
                if pid == "" {
                    pid = message.pid
                } else if pid == message.pid{
                    continue
                }
                
                if index == 0{
                    currentDate = message.sentDate
                }
                let timeInterval = message.sentDate.timeIntervalSinceDate(currentDate!)
                
                
                if timeInterval < 120 {
                    messages[section].append(message)
                }else{
                    section++
                    messages.append([message])
                }
                currentDate = message.sentDate
                index++
            }
        }
        
        
    }

    func popPhotoViewWithFrame(frame:CGRect) -> ChooseView?{
        if(self.messages.count == 0){
            return nil;
        }
        
        // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
        // Each take an "options" argument. Here, we specify the view controller as
        // a delegate, and provide a custom callback that moves the back card view
        // based on how far the user has panned the front card view.
        let options:MDCSwipeToChooseViewOptions = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.onPan = { state -> Void in
            if(self.backCardView != nil){
                let frame:CGRect = self.frontCardViewFrame()
                self.backCardView.frame = CGRectMake(frame.origin.x, frame.origin.y-(state.thresholdRatio * 10.0), CGRectGetWidth(frame), CGRectGetHeight(frame))
            }
        }
        options.nopeColor = UIColor.clearColor()
        options.likedColor = UIColor.clearColor()//not used
        
        // Create a View with the top phx in the phx array, then pop
        // that phx off the stack.
        initData()
        
        let phxView:ChooseView = ChooseView(frame: frame, msg: self.messages[0], options: options)
        self.messages.removeAtIndex(0)
        return phxView
        
    }
    func frontCardViewFrame() -> CGRect{
        let horizontalPadding:CGFloat = 10
        let topPadding:CGFloat = 10
        let bottomPadding:CGFloat = 100
        return CGRectMake(horizontalPadding,topPadding,CGRectGetWidth(self.view.frame) - (horizontalPadding * 2), CGRectGetHeight(self.view.frame) - bottomPadding)
    }
    func backCardViewFrame() ->CGRect{
        let frontFrame:CGRect = frontCardViewFrame()
        return CGRectMake(frontFrame.origin.x, frontFrame.origin.y + 10.0, CGRectGetWidth(frontFrame), CGRectGetHeight(frontFrame))
    }
    
    func constructLButton() {
        let button:UIButton =  UIButton(type: UIButtonType.System)
        let image:UIImage = UIImage(named:"nope")!
        button.frame = CGRectMake(ChoosePersonButtonHorizontalPadding, CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding, image.size.width, image.size.height)
        button.setImage(image, forState: UIControlState.Normal)
        button.tintColor = UIColor(red: 247.0/255.0, green: 91.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        button.addTarget(self, action: "nopeFrontCardView", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func constructRButton() {
        let button:UIButton = UIButton(type: UIButtonType.System)
        let image:UIImage = UIImage(named:"liked")!
        button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChoosePersonButtonHorizontalPadding, CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding, image.size.width, image.size.height)
        button.setImage(image, forState:UIControlState.Normal)
        button.tintColor = UIColor(red: 29.0/255.0, green: 245.0/255.0, blue: 106.0/255.0, alpha: 1.0)
        button.addTarget(self, action: "likeFrontCardView", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
        
    }
    
    func nopeFrontCardView() {
        self.frontCardView.mdc_swipe(MDCSwipeDirection.Left)
    }
    func likeFrontCardView() {
        self.frontCardView.mdc_swipe(MDCSwipeDirection.Right)
    }
}