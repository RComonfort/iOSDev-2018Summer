//
//  ViewController.swift
//  TicTacToeVoiceControlled
//
//  Created by Comonfort on 6/7/18.
//  Copyright © 2018 Comonfort. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    //MARK: - Speech Recognition Members
    
    let speechRecognizer = SFSpeechRecognizer (locale: Locale.init (identifier: "en-US"));
    var request: SFSpeechAudioBufferRecognitionRequest?;
    var task: SFSpeechRecognitionTask?;
    let audioEngine = AVAudioEngine();
    
    @IBOutlet weak var voiceRecordButton: UIButton!
    
    //MARK: - TicTacToe Members
    
    var userTurn = true;
    var board = ["-", "-", "-", "-", "-", "-", "-", "-","-"];
    
    let OsColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1);
    let XsColor = UIColor(red: 148/255, green: 17/255, blue: 0, alpha: 1);
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label9: UILabel!
    
    //MARK: - VC Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        voiceRecordButton.isEnabled = false;
        speechRecognizer?.delegate = self;
        SFSpeechRecognizer.requestAuthorization{ (authorizationStatus) in
            switch (authorizationStatus){
            case .authorized:
                OperationQueue.main.addOperation {
                    self.voiceRecordButton.isEnabled = true;
                }
                break;
            case .denied:
                print ("Used denied permission");
                break;
            case .restricted:
                print ("Speech recognition is restricted for this device");
                break;
            case .notDetermined:
                print ("Speech recognition has not been authorized yet");
                break;
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - Speech Recognizer Functions
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if (available) {
            voiceRecordButton.isEnabled = true;
        }
        else {
            voiceRecordButton.isEnabled = false;
            
        }
    }
    
    
    //MARK: - IBActions
    
    @IBAction func didPressRecordButton(_ sender: Any) {
        if (audioEngine.isRunning) {
            audioEngine.stop();
            audioEngine.inputNode.removeTap(onBus: 0);
            request?.endAudio();
            voiceRecordButton.setTitle("Voice Command", for: .normal);
        } else {
            record();
            voiceRecordButton.setTitle("Stop Recording", for: .normal);
        }
    }
    
    @IBAction func start() {
        board = ["-", "-", "-", "-", "-", "-", "-", "-", "-"]
        
        label1.text = "-";
        label1.textColor = .white;
        
        label2.text = "-";
        label2.textColor = .white;
        
        label3.text = "-";
        label3.textColor = .white;
        
        label4.text = "-";
        label4.textColor = .white;
        
        label5.text = "-";
        label5.textColor = .white;
        
        label6.text = "-";
        label6.textColor = .white;
        
        label7.text = "-";
        label7.textColor = .white;
        
        label8.text = "-";
        label8.textColor = .white;
        
        label9.text = "-";
        label9.textColor = .white;
    }
    
    
    //MARK: - Functions
    
    func record() {
        if (task != nil) {
            task?.cancel();
            task = nil;
        }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryRecord);
            try session.setMode (AVAudioSessionModeMeasurement);
            try session.setActive(true, with: .notifyOthersOnDeactivation);
        } catch {
            print( "Error: setting audio session properties");
        }
        
        request = SFSpeechAudioBufferRecognitionRequest();
        let inputNode = audioEngine.inputNode;
        guard request != nil else {
            fatalError("Error: could not create a request object");
        }
        request?.shouldReportPartialResults = true;
        task = speechRecognizer?.recognitionTask(with: request!, resultHandler: {
            (result, error) in
            if (result != nil)
            {
                let text = result?.bestTranscription.formattedString;
                self.processVoiceCommand (message: text!.lowercased());
            }
            
            if (error != nil) {
                self.audioEngine.stop();
                inputNode.removeTap(onBus: 0);
                self.request = nil;
                self.task = nil;
                self.voiceRecordButton.isEnabled = true;
            }
        })
        
        let format = inputNode.outputFormat(forBus: 0);
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) {
            (buffer, when) in
            self.request?.append(buffer);
        }
        
        audioEngine.prepare();
        do {
            try audioEngine.start();
        } catch {
            print ("Error: starting audioengine");
        }
    }
    
    func processVoiceCommand (message: String) {
        
        if (message == "play"){
            start();
        }
        else if (message == "top left") {
            handleTapLabel1(message);
        }
        else if (message == "top center" || message == "top") {
            handleTapLabel2(message);
        }
        else if (message == "top right") {
            handleTapLabel3(message);
        }
        else if (message == "center left") {
            handleTapLabel4(message);
        }
        else if (message == "center") {
            handleTapLabel5(message);
        }
        else if (message == "center right") {
            handleTapLabel6(message);
        }
        else if (message == "bottom left") {
            handleTapLabel7(message);
        }
        else if (message == "bottom center" || message == "bottom") {
            handleTapLabel8(message);
        }
        else if (message == "bottom right") {
            handleTapLabel9(message);
        }
        else {
            showAlert(message: "Could not understand that :( try again.", title: "Unrecognized Command")
        }
    }
    
    func checkGameOver() -> Bool {
        var isGameOver = false
        
        if board[0] == "X" && board[1] == "X" && board[2] == "X" ||
            board[3] == "X" && board[4] == "X" && board[5] == "X" ||
            board[6] == "X" && board[7] == "X" && board[8] == "X" ||
            board[0] == "X" && board[4] == "X" && board[8] == "X" ||
            board[2] == "X" && board[4] == "X" && board[6] == "X" ||
            board[0] == "X" && board[3] == "X" && board[6] == "X" ||
            board[1] == "X" && board[4] == "X" && board[7] == "X" ||
            board[2] == "X" && board[5] == "X" && board[8] == "X" {
            isGameOver = true
            userTurn = false
            showAlert(message: "User WINS")
        }
        else if board[0] == "O" && board[1] == "O" && board[2] == "O" ||
            board[3] == "O" && board[4] == "O" && board[5] == "O" ||
            board[6] == "O" && board[7] == "O" && board[8] == "O" ||
            board[0] == "O" && board[4] == "O" && board[8] == "O" ||
            board[2] == "O" && board[4] == "O" && board[6] == "O" ||
            board[0] == "O" && board[3] == "O" && board[6] == "O" ||
            board[1] == "O" && board[4] == "O" && board[7] == "O" ||
            board[2] == "O" && board[5] == "O" && board[8] == "O" {
            isGameOver = true
            userTurn = false
            showAlert(message: "Computer WINS")
        }
        else if  board[0] != "-" && board[1] != "-" && board[2] != "-"
            && board[3] != "-" && board[4] != "-" && board[5] != "-"
            && board[6] != "-" && board[7] != "-" && board[8] != "-"{
            isGameOver = true
            userTurn = false
            showAlert(message: "It's a DRAW")
        }
        return isGameOver
    }
    
    func showAlert(message: String, title: String = "Game Over"){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil);
        
        alert.addAction(ok);
        
        present(alert, animated: true, completion: { () in
            
            //Enable dismiss when tapped outside the alert
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        });
    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setMove(number: Int, mark: String, isPlayerMove bIsPlayerMove: Bool = false){
        board[number] = mark
        switch(number) {
            case 0: label1.text = mark;
            label1.textColor = bIsPlayerMove ? XsColor : OsColor;
                break
            case 1: label2.text = mark;
            label2.textColor = bIsPlayerMove ? XsColor : OsColor;
                break
            case 2: label3.text = mark;
            label3.textColor = bIsPlayerMove ? XsColor : OsColor;
                break
            case 3: label4.text = mark;
            label4.textColor = bIsPlayerMove ? XsColor : OsColor;
                break
            case 4: label5.text = mark;
            label5.textColor = bIsPlayerMove ? XsColor : OsColor;
                break
            case 5: label6.text = mark;
            label6.textColor = bIsPlayerMove ? XsColor : OsColor;
                break
            case 6: label7.text = mark;
            label7.textColor = bIsPlayerMove ? XsColor : OsColor;
                break
            case 7: label8.text = mark;
            label8.textColor = bIsPlayerMove ? XsColor : OsColor;
                break
            case 8: label9.text = mark;
            label9.textColor = bIsPlayerMove ? XsColor : OsColor;
                break
        default: fatalError("Bad move!");
        }

    }
    
    func setFirstEmptyPosition(){
        var moved = false
        for index in 0...8{
            if(!moved && board[index] == "-"){
                setMove(number: index, mark: "O")
                moved = true
            }
        }
    }

    
    // MARK: - AI TicTacToe Functions
    
    func checkTwoInARow(check1: Int, check2: Int, check3: Int, checkMark: String, setMark: String) -> Bool {
        var moved = false
        if board[check1] == checkMark && board[check2] == checkMark && board[check3] == "-"{
            setMove(number: check3, mark: setMark)
            moved = true
        } else if board[check1] == checkMark && board[check3] == checkMark && board[check2] == "-"{
            setMove(number: check2, mark: setMark)
            moved = true
        } else if board[check2] == checkMark && board[check3] == checkMark && board[check1] == "-"{
            setMove(number: check1, mark: setMark)
            moved = true
        }
        return moved
    }
    
    func checkWin() -> Bool{
        var moved = checkTwoInARow(check1: 0, check2: 1, check3: 2, checkMark: "O", setMark: "O")
        if !moved {
            moved = checkTwoInARow(check1: 3, check2: 4, check3: 5, checkMark: "O", setMark: "O")
            if !moved{
                moved = checkTwoInARow(check1: 6, check2: 7, check3: 8, checkMark: "O", setMark: "O")
                if !moved{
                    moved = checkTwoInARow(check1: 0, check2: 3, check3: 6, checkMark: "O", setMark: "O")
                    if !moved{
                        moved = checkTwoInARow(check1: 1, check2: 4, check3: 7, checkMark: "O", setMark: "O")
                        if !moved{
                            moved = checkTwoInARow(check1: 2, check2: 5, check3: 8, checkMark: "O", setMark: "O")
                            if !moved {
                                moved = checkTwoInARow(check1: 0, check2: 4, check3: 8, checkMark: "O", setMark: "O")
                                if !moved {
                                    moved = checkTwoInARow(check1: 2, check2: 4, check3: 6, checkMark: "O", setMark: "O")
                                }
                            }
                        }
                    }
                }
            }
        }
        return moved
    }
    
    func checkBlock() -> Bool{
        var moved = checkTwoInARow(check1: 0, check2: 1, check3: 2, checkMark: "X", setMark: "O")
        if !moved {
            moved = checkTwoInARow(check1: 3, check2: 4, check3: 5, checkMark: "X", setMark: "O")
            if !moved{
                moved = checkTwoInARow(check1: 6, check2: 7, check3: 8, checkMark: "X", setMark: "O")
                if !moved{
                    moved = checkTwoInARow(check1: 0, check2: 3, check3: 6, checkMark: "X", setMark: "O")
                    if !moved{
                        moved = checkTwoInARow(check1: 1, check2: 4, check3: 7, checkMark: "X", setMark: "O")
                        if !moved{
                            moved = checkTwoInARow(check1: 2, check2: 5, check3: 8, checkMark: "X", setMark: "O")
                            if !moved {
                                moved = checkTwoInARow(check1: 0, check2: 4, check3: 8, checkMark: "X", setMark: "O")
                                if !moved {
                                    moved = checkTwoInARow(check1: 2, check2: 4, check3: 6, checkMark: "X", setMark: "O")
                                }
                            }
                        }
                    }
                }
            }
        }
        return moved
    }
    
    func checkCenter() -> Bool {
        var moved = false
        if board[4] == "-" {
            setMove(number: 4, mark: "0")
            moved = true
        }
        return moved
    }
    
    func checkOppositeCorner() -> Bool {
        var moved = false
        if board[0] == "X" && board[8] == "-" {
            setMove(number: 8, mark: "O")
            moved = true
        } else if board[8] == "X" && board[0] == "-" {
            setMove(number: 0, mark: "O")
            moved = true
        } else if board[2] == "X" && board[6] == "-" {
            setMove(number: 6, mark: "O")
            moved = true
        } else if board[6] == "X" && board[2] == "-" {
            setMove(number: 2, mark: "O")
            moved = true
        }
        return moved
    }
    
    func checkEmptyCorner() -> Bool {
        var moved = false
        if board[0] == "-" {
            setMove(number: 0, mark: "O")
            moved = true
        } else if board[8] == "-" {
            setMove(number: 8, mark: "O")
            moved = true
        } else if board[6] == "-" {
            setMove(number: 6, mark: "O")
            moved = true
        } else if board[2] == "-" {
            setMove(number: 2, mark: "O")
            moved = true
        }
        return moved
    }
    func makeMove(){
        if !checkGameOver(){
            if !checkWin(){
                if !checkBlock(){
                    if !checkCenter(){
                        if !checkOppositeCorner(){
                            if !checkEmptyCorner(){
                                setFirstEmptyPosition()
                            }
                        }
                    }
                }
            }
            if !checkGameOver(){
                userTurn = true
            }
        }
    }
    
    //MARK: - Labels IBActions
    
    @IBAction func handleTapLabel1(_ sender: Any) {
        if board[0] == "-" {
            setMove(number: 0, mark: "X", isPlayerMove: true)
            userTurn = false
            makeMove()
        }
    }
    
    @IBAction func handleTapLabel2(_ sender: Any) {
        if board[1] == "-" {
            setMove(number: 1,  mark: "X", isPlayerMove: true)
            userTurn = false
            makeMove()
        }
    }
    
    @IBAction func handleTapLabel3(_ sender: Any) {
        if board[2] == "-" {
            setMove(number: 2,  mark: "X", isPlayerMove: true)
            userTurn = false
            makeMove()
        }
    }
    
    @IBAction func handleTapLabel4(_ sender: Any) {
        if board[3] == "-" {
            setMove(number: 3,  mark: "X", isPlayerMove: true)
            userTurn = false
            makeMove()
        }
    }
    
    @IBAction func handleTapLabel5(_ sender: Any) {
        if board[4] == "-" {
            setMove(number: 4,  mark: "X", isPlayerMove: true)
            userTurn = false
            makeMove()
        }
    }
    
    @IBAction func handleTapLabel6(_ sender: Any) {
        if board[5] == "-" {
            setMove(number: 5,  mark: "X",isPlayerMove: true)
            userTurn = false
            makeMove()
        }
    }
    
    @IBAction func handleTapLabel7(_ sender: Any) {
        if board[6] == "-" {
            setMove(number: 6,  mark: "X", isPlayerMove: true)
            userTurn = false
            makeMove()
        }
    }
    
    @IBAction func handleTapLabel8(_ sender: Any) {
        if board[7] == "-" {
            setMove(number: 7,  mark: "X", isPlayerMove: true)
            userTurn = false
            makeMove()
        }
    }
    
    @IBAction func handleTapLabel9(_ sender: Any) {
        if board[8] == "-" {
            setMove(number: 8,  mark: "X", isPlayerMove: true)
            userTurn = false
            makeMove()
        }
    }

}

