
import Foundation.NSDate

class Message {
    let incoming: Bool
    let text: String
    let sentDate: NSDate
    let imgurl: String
    let pid: String
    init(incoming: Bool, text: String, sentDate: NSDate, imgurl: String, pid: String) {
        self.incoming = incoming
        self.text = text
        self.sentDate = sentDate
        self.imgurl = imgurl
        self.pid = pid
    }
}