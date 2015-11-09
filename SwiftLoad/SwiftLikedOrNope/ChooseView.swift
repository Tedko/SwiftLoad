import UIKit
import Parse
import ParseUI
import MDCSwipeToChoose
import SnapKit

class ChooseView: MDCSwipeToChooseView, UITableViewDelegate, UITableViewDataSource {
    
    let ChooseViewImageLabelWidth:CGFloat = 42.0;
    var tableView: UITableView!
    
    var msg:[Message]=[]
    init(frame: CGRect, msg: [Message], options: MDCSwipeToChooseViewOptions) {
        
        super.init(frame: frame, options: options)
        self.msg = msg
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) { () -> Void in
            let url  = NSURL(string: msg[0].imgurl)!
            let data = NSData(contentsOfURL: url)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let data = data {
                    self.imageView.contentMode = .ScaleAspectFill
                    self.imageView.image = UIImage(data: data)
                }
            })
        }
    
        self.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        UIViewAutoresizing.FlexibleBottomMargin
        
        self.imageView.autoresizingMask = self.autoresizingMask
        constructTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        constructTableView()
    }
//    func initData(){
//        var index = 0
//        var section = 0
//        var pid = ""
//        var imgLoaded = false
//        var currentDate:NSDate?
//        
//        if messages.count <= 1
//        {
//            var query:PFQuery = PFQuery(className:"Messages")
//            query.orderByAscending("pid")
//            
//            
//            let contents:[PFObject]
//            
//            do {
//                contents = try query.findObjects()
//            } catch _ {
//                return
//            }
//            for object in contents {
//                
//                
//                let message = Message(incoming: object["incoming"] as! Bool, text: object["text"] as! String, sentDate: object["sentDate"] as! NSDate, imgurl: object["imgurl"] as! String, pid: object["pid"] as! String)
//                
//                if pid == "" {
//                    pid = message.pid
//                } else if pid != message.pid{
//                    return
//                } else {
//                    imgLoaded = true
//                }
//                if index == 0{
//                    currentDate = message.sentDate
//                }
//                let timeInterval = message.sentDate.timeIntervalSinceDate(currentDate!)
//                
//                
//                if timeInterval < 120 {
//                    messages[section].append(message)
//                }else{
//                    section++
//                    messages.append([message])
//                }
//                currentDate = message.sentDate
//                index++
//            }
//        }
//        
//        
//    }
    
    func constructTableView() {
        tableView = UITableView(frame: self.bounds)
        tableView.backgroundColor = UIColor.clearColor()
        //tableView.scrollEnabled = false //trun off if needed
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.registerClass(MessageSentDateTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(MessageSentDateTableViewCell))
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.addSubview(tableView)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            
            let cellIdentifier = NSStringFromClass(MessageSentDateTableViewCell)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath: indexPath) as! MessageSentDateTableViewCell
            //let message = messages[indexPath.section][0]
            
            let message = msg[0]

            cell.backgroundColor = UIColor.clearColor()
            
            
            cell.sentDateLabel.text = formatDate(message.sentDate)
            
            return cell
            
        }else{
            let cellIdentifier = NSStringFromClass(MessageBubbleTableViewCell)
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MessageBubbleTableViewCell!
            if cell == nil {
                
                cell = MessageBubbleTableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            }
            
            
            
            //let message = messages[indexPath.section][indexPath.row - 1]
            
            let message = msg[indexPath.row - 1]
            
            cell.configureWithMessage(message)
            cell.backgroundColor = UIColor.clearColor()
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return messages[section].count + 1
        return msg.count + 1

    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        //return messages.count
    }
    
    func formatDate(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        var dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
        
        let last18hours = (-18*60*60 < date.timeIntervalSinceNow)
        let isToday = calendar.isDateInToday(date)
        let isLast7Days = (calendar.compareDate(NSDate(timeIntervalSinceNow: -7*24*60*60), toDate: date, toUnitGranularity: NSCalendarUnit.Day) == NSComparisonResult.OrderedAscending)
        
        if last18hours || isToday {
            dateFormatter.dateFormat = "a HH:mm"
        } else if isLast7Days {
            dateFormatter.dateFormat = "MM月dd日 a HH:mm EEEE"
        } else {
            dateFormatter.dateFormat = "YYYY年MM月dd日 a HH:mm"
            
        }
        return dateFormatter.stringFromDate(date)
    }
    
    
    
}
