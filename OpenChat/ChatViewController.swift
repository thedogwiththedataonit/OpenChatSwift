//
//  ChatViewController.swift
//  OpenChat
//
//  Created by Thomas Park on 4/26/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}


class ChatViewController: MessagesViewController {
    
    let currentUser = Sender(senderId: "Human", displayName:"Me")
    let AIUser = Sender(senderId: "AI", displayName: "AI")
    var messages = [MessageType]()
    var AIResponse: String = ""
    
    private struct Returned: Codable {
        var response: String?
    }
    
    private struct LogReturned: Codable {
        var conversation_log: [log]
    }
    
    struct log: Codable {
        var user: String
        var response: String
    }

    var log_list:[log] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getConversationLog(convo: title!){
            DispatchQueue.main.async {
                print("done")
                for i in self.log_list {
                    print(i.user)
                    print(i.response)
                    self.messages.append(Message(sender: Sender(senderId: i.user, displayName: i.user),
                                            messageId: String(Date().timeIntervalSince1970),
                                            sentDate: Date().addingTimeInterval(-86400),
                                            kind: .text(i.response)
                                            ))
                    print(self.messages)
                    self.messagesCollectionView.reloadData()
                }
            }}
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagesCollectionView.scrollToLastItem()
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    func getConversationLog(convo: String, completed: @escaping () -> ()){
        guard let url = URL(string: "https://www.thomasapigateway.com/chat_history") else {
            print("Url did not work.")
            return
        }
        var conversationName:String = ""
        switch title! {
                case "Classic AI":
                    print("classicAI")
                    conversationName = "classicAI"
                case "Marv the sarcastic AI":
                    print("marv")
                    conversationName = "marv"
                case "Friendly Francis AI":
                    print("friend")
                    conversationName = "friend"
                default:
                    print("ERROR")
                }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
                    //"username": username,
                    //"chat": chat,
                    "convo":conversationName
                ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                        print("Error")
                        return
                    }
                do {
                    let returnedlog = try JSONDecoder().decode(LogReturned.self, from: data!)
                    print("COMPLETED")
                    self.log_list = returnedlog.conversation_log
                    print(self.log_list)
                    }
                catch {
                    print("JSON error")
                    return
                    }
                    completed()
                })
                task.resume()
            }
    
    
    func makePostRequest(text_input: String, completion: @escaping (_ response: String?) -> Void ) {
        guard let url = URL(string: "https://www.thomasapigateway.com/chat") else {
            print("Url did not work.")
            return
        }
        
        var conversationName:String = ""
        switch title! {
                case "Classic AI":
                    print("classicAI")
                    conversationName = "classicAI"
                case "Marv the sarcastic AI":
                    print("marv")
                    conversationName = "marv"
                case "Friendly Francis AI":
                    print("friend")
                    conversationName = "friend"
                default:
                    print("ERROR")
                }
        
        var request = URLRequest(url: url)
        // set the method, body, headers
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            //"username": username,
            "conversation": conversationName,
            "text":text_input
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error")
                return
            }
            do {
                let returned = try JSONDecoder().decode(Returned.self, from: data!)
                completion(returned.response)
            }
            catch {
                print("JSON error")
                return
            }
        })
        task.resume()
    }

}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { //empty cases
            return
        }
        
        //send message
        print("Sending: \(text)")
        inputBar.inputTextView.text = ""
        self.messagesCollectionView.reloadData()
        
        messages.append(Message(sender: currentUser, messageId: String(Date().timeIntervalSince1970), sentDate: Date().addingTimeInterval(-86400), kind: .text(text)))
        
        messagesCollectionView.scrollToLastItem()
        
        
        makePostRequest(text_input: text, completion: { (response) in
            if response != nil {
                //print("not nil"
                self.AIResponse = response ?? "..."
                self.messages.append(Message(sender: self.AIUser, messageId: String(Date().timeIntervalSince1970), sentDate: Date().addingTimeInterval(-86400), kind: .text(self.AIResponse)))
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                }
            }
        })
        
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
