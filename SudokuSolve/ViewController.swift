//
//  ViewController.swift
//  SudokuSolve
//
//  Created by 黃健偉 on 2018/1/22.
//  Copyright © 2018年 黃健偉. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var height: CGFloat = 0
    var width: CGFloat = 0
    var is16x9: Bool = false

    var area = [[UIView]]()
    var pixel = [[UIButton]]()
    var mark = [Int]()

    var pencilArea = [[UIView]]()
    var pencilX: Int = 0
    var pencilY: Int = 0

    var btn = [UIButton]()
    var selectedPixel = UIButton()
    var isKeyBoardLock: Bool = false
    
    var solveBtn = UIButton()
    var resetBtn = UIButton()

    var isGameMode: Bool = false
    var penBtn = UIButton()
    var isPencil: Bool = false
    var backBtn = UIButton()
    var newGameBtn = UIButton()
    var modeLabel = UILabel()

    var timerLabel = UILabel()
    var timer = Timer()
    var count = 0

    var backRec = [backRecord]()
    var rec = [record]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        height = self.view.bounds.height
        width = self.view.bounds.width
        print(height/width)
        if height/width > 1.5 {
            is16x9 = true
            print("16:9")
        } else {
            is16x9 = false
            print("4:3")
        }

        init9x9()
        addResetBtn()
        addSolveBtn()
        addGameModeBtn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func init9x9() {
        for x: Int in 0...8 {
            if x%3 == 0 {
                area.append([UIView]())
            }
            pencilArea.append([UIView]())
            pixel.append([UIButton]())
            for y: Int in 0...8 {
                if x%3 == 0 && y%3 == 0 {
                    area[x/3].append(addArea(location: (x/3, y/3)))
                    view.addSubview(area[x/3][y/3])
                }
                pencilArea[x].append(addPencilArea(location: (x%3, y%3)))
                area[x/3][y/3].addSubview(pencilArea[x][y])
                pixel[x].append(addPixel(location: (x%3, y%3)))
                pixel[x][y].x = x
                pixel[x][y].y = y
                pixel[x][y].value = 0
                pixel[x][y].status = UIButton.status.answer.rawValue
                area[x/3][y/3].addSubview(pixel[x][y])
            }
        }
    }
    
    func addArea(location: (Int, Int)) -> UIView {
        let borderWidth = 2
        let edge: Int = Int(width / 20)
        var heightOffset = Int(height / 5)
        if !is16x9 {
            heightOffset = heightOffset/4*3
        }
        let size: Int = (Int(width) - edge * 2) / 3 - 3

        let (x, y) = location
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        view.center = CGPoint(x: edge*5/4+x*size+size/2-x*borderWidth, y: heightOffset+y*size+size/2-y*borderWidth)
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = CGFloat(borderWidth)
        
        return view
    }

    func addPixel(location: (Int, Int)) -> UIButton {
        let borderWidth = 1
        let edge: Int = Int(width / 20)
        let size: Int = (Int(width) - edge * 2) / 9

        let (x, y) = location
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
        button.center = CGPoint(x: x*size+size/2-x*borderWidth, y: y*size+size/2-y*borderWidth)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = CGFloat(borderWidth)
        button.titleLabel?.font = UIFont(name: "Hiragino Maru Gothic ProN", size: CGFloat(size-20))
        button.addTarget(self, action: #selector(ViewController.clickButton(_:)), for: .touchUpInside)
        
        return button
    }
    
    func addPencilArea(location: (Int, Int)) -> UIView {
        let edge: Int = Int(width / 20)
        let size: Int = (Int(width) - edge * 2) / 9

        let (x, y) = location
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        view.center = CGPoint(x: x*size+size/2, y: y*size+size/2)
        
        return view
    }

    @objc func clickButton(_ sender: UIButton!) {
        if !isKeyBoardLock && sender.status != UIButton.status.gameQuestion.rawValue {
            let buttonCenter = CGPoint(x: sender.bounds.origin.x + sender.bounds.size.width / 2, y: sender.bounds.origin.y + sender.bounds.size.height / 2)
            
            let position = sender.convert(buttonCenter, to: self.view)
            if isPencil {
                if sender.value == 0 {
                    addPencilKeyboard(position: position)
                    isKeyBoardLock = true
                }
            } else {
                addNumberKeyboard(position: position)
                isKeyBoardLock = true
            }
            pencilX = sender.x
            pencilY = sender.y
            selectedPixel = sender
        }
    }
    
    func addNumberKeyboard(position: CGPoint) {
        let number: [String] = ["1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🆓"]
        let size: Int = 25
        var pos: CGPoint = CGPoint(x: 0, y: 0)
        
        btn.removeAll()
        for x: Int in 0...9 {
            btn.append(UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size)))
            if x != 9 {
                pos.x = position.x + CGFloat(x % 3 * size - size)
                pos.y = position.y + CGFloat(x / 3 * size - size)
            } else {
                pos.x = position.x
                pos.y = position.y + CGFloat(size * 2)
            }
            btn[x].center = CGPoint(x: pos.x, y: pos.y)
            btn[x].value = x+1
            btn[x].setTitle(number[x], for: .normal)
            btn[x].addTarget(self, action: #selector(ViewController.setNumber(_:)), for: .touchUpInside)
            view.addSubview(btn[x])
        }
    }

    func addPencilKeyboard(position: CGPoint) {
        let size: Int = 25
        var pos: CGPoint = CGPoint(x: 0, y: 0)
        
        btn.removeAll()
        for x: Int in 0...9 {
            btn.append(UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size)))
            btn[x].value = x+1
            if x != 9 {
                pos.x = position.x + CGFloat(x % 3 * size - size)
                pos.y = position.y + CGFloat(x / 3 * size - size)
            } else {
                pos.x = position.x
                pos.y = position.y + CGFloat(size * 2)
                btn[x].setTitle(String("x"), for: .normal)
            }
            btn[x].backgroundColor = UIColor.brown
            btn[x].titleLabel?.font = UIFont(name: "Noteworthy", size: CGFloat(size-10))
            btn[x].layer.cornerRadius = 6
            btn[x].center = CGPoint(x: pos.x, y: pos.y)
            btn[x].addTarget(self, action: #selector(ViewController.pencilMark(_:)), for: .touchUpInside)
            view.addSubview(btn[x])
        }
    }

    struct backRecord {
        var btn = UIButton()
        var value: Int
    }
    
    @objc func setNumber(_ sender: UIButton!) {
        if isGameMode {
            selectedPixel.status = UIButton.status.answer.rawValue
            backRec.append(backRecord(btn: selectedPixel, value: sender.value%10))
            backBtn.isEnabled = true
            if sender.value%10 != 0 {
                for label in pencilArea[pencilX][pencilY].subviews {
                    label.removeFromSuperview()
                }
            }
        } else if sender.value%10 != 0 {
            selectedPixel.status = UIButton.status.question.rawValue
        } else {
            selectedPixel.status = UIButton.status.answer.rawValue
        }
        selectedPixel.value = sender.value%10
        for x in 0...9 {
            btn[x].removeFromSuperview()
        }
        isKeyBoardLock = false
        _ = showDuplicates()
        if checkFinish() {
            if isGameMode {
                pauseTime()
                backRec = [backRecord]()
                backBtn.isEnabled = false
                let finishAlert = UIAlertController(title: "Congratulations", message: "You finished the game!!!", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in print("Ok button tapped")}
                finishAlert.addAction(OKAction)
                self.present(finishAlert, animated: true, completion:nil)
            }
        }
    }
    
    @objc func pencilMark(_ sender: UIButton!) {
        if sender.value%10 != 0 {
            let edge: Int = Int(width / 20)
            let size: Int = (Int(width) - edge * 2) / 9 / 3
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: size, height: size))
            label.center = CGPoint(x: (sender.value%10-1)%3*size+size/2+3, y: (sender.value%10-1)/3*size+size/2)
            label.text = String(sender.value%10)
            label.font = UIFont(name: "Noteworthy", size: CGFloat(size-3))
            pencilArea[pencilX][pencilY].addSubview(label)
        } else {
            for label in pencilArea[pencilX][pencilY].subviews {
                label.removeFromSuperview()
            }
        }
        
        for x in 0...9 {
            btn[x].removeFromSuperview()
        }
        isKeyBoardLock = false

    }

    func addResetBtn() {
        let edge: Int = Int(width / 10)
        let sizeX: Int = (Int(width) - edge * 3) / 2
        
        if is16x9 {
            resetBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/2))
            resetBtn.center = CGPoint(x: CGFloat(edge+sizeX/2), y: height/5*4)
        } else {
            resetBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/3))
            resetBtn.center = CGPoint(x: CGFloat(edge+sizeX/2), y: height/16*14)
        }
        resetBtn.backgroundColor = UIColor.lightGray
        resetBtn.setTitle("RESET", for: .normal)
        resetBtn.setTitleColor(UIColor.darkGray, for: .normal)
        resetBtn.setTitleColor(UIColor.darkText, for: .highlighted)
        resetBtn.layer.cornerRadius = 6
        resetBtn.addTarget(self, action: #selector(reset9x9), for: .touchUpInside)
        view.addSubview(resetBtn)
    }
    
    @objc func reset9x9() {
        for y: Int in 0...8 {
            for x: Int in 0...8 {
                pixel[x][y].value = 0
                pixel[x][y].status = UIButton.status.answer.rawValue
                pixel[x][y].finish(flag: false)
                for label in pencilArea[x][y].subviews {
                    label.removeFromSuperview()
                }
            }
        }
    }

    func addSolveBtn() {
        let edge: Int = Int(width / 10)
        let sizeX: Int = (Int(width) - edge * 3) / 2
        
        if is16x9 {
            solveBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/2))
            solveBtn.center = CGPoint(x: CGFloat(edge*2+sizeX*3/2), y: height/5*4)
        } else {
            solveBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/3))
            solveBtn.center = CGPoint(x: CGFloat(edge*2+sizeX*3/2), y: height/16*14)
        }
        solveBtn.backgroundColor = UIColor.lightGray
        solveBtn.setTitle("SOLVE", for: .normal)
        solveBtn.setTitleColor(UIColor.darkGray, for: .normal)
        solveBtn.setTitleColor(UIColor.darkText, for: .highlighted)
        solveBtn.layer.cornerRadius = 6
        solveBtn.addTarget(self, action: #selector(solve), for: .touchUpInside)
        view.addSubview(solveBtn)
    }
    
    @objc func solve() {
        if !showDuplicates() {
            let duplicatesAlert = UIAlertController(title: "Alert", message: "duplicates cell found!!!", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in print("Ok button tapped")}
            duplicatesAlert.addAction(OKAction)
            self.present(duplicatesAlert, animated: true, completion:nil)
        } else {
            //DPS -> fastest
            depthFirstSearch()
            
            //only one solve + error try -> solwest
//            //step 1 - only one solve pixel
//            var result = true
//            repeat {
//                result = firstSearch()
//            } while result
//            if !checkFinish() {
//                //step 2 - error try or DFS
//                print ("not finished yet")
//                errorTry()
//            } else {
//                print ("finished")
//            }
        }
        _ = checkFinish()
    }
    
    //Duplicates pixel = red color
    @objc func showDuplicates() -> Bool {
        var isRight: Bool = true
        
        //reset font color
        for y: Int in 0...8 {
            for x: Int in 0...8 {
                if pixel[x][y].value == 0 {
                    pixel[x][y].setTitleColor(UIColor.clear, for: .normal)
                } else {
                    if pixel[x][y].status == UIButton.status.question.rawValue {
                        pixel[x][y].setTitleColor(UIColor.darkText, for: .normal)
                    } else if pixel[x][y].status == UIButton.status.answer.rawValue {
                        pixel[x][y].setTitleColor(UIColor.blue, for: .normal)
                    } else if pixel[x][y].status == UIButton.status.gameQuestion.rawValue {
                        pixel[x][y].setTitleColor(UIColor.white, for: .normal)
                        pixel[x][y].backgroundColor = UIColor.darkGray
                    }
                }
            }
        }
        
        //row
        var row = [Int]()
        for x: Int in 0...8 {
            row.removeAll()
            for y: Int in 0...8 {
                row.append(pixel[x][y].value)
            }
            //found out duplicates except zero
            let duplicates = Array(Set(row.filter({ (i: Int) in row.filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
            if !duplicates.isEmpty
            {
                isRight = false
                for i in 0...duplicates.count-1 {
                    for y in 0...8 {
                        if pixel[x][y].value == duplicates[i] {
                            pixel[x][y].setTitleColor(UIColor.red, for: .normal)
                        }
                    }
                }
            }
        }
        
        //col
        var col = [Int]()
        for y: Int in 0...8 {
            col.removeAll()
            for x: Int in 0...8 {
                col.append(pixel[x][y].value)
            }
            //found out duplicates except zero
            let duplicates = Array(Set(col.filter({ (i: Int) in col.filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
            if !duplicates.isEmpty
            {
                isRight = false
                for i in 0...duplicates.count-1 {
                    for x in 0...8 {
                        if pixel[x][y].value == duplicates[i] {
                            pixel[x][y].setTitleColor(UIColor.red, for: .normal)
                        }
                    }
                }
            }
        }
        
        //9x9
        var area = [Int]()
        for x: Int in 0...2 {
            for y: Int in 0...2 {
                area.removeAll()
                for yy: Int in 0...2 {
                    for xx: Int in 0...2 {
                        area.append(pixel[x*3+xx][y*3+yy].value)
                    }
                }
                //found out duplicates except zero
                let duplicates = Array(Set(area.filter({ (i: Int) in area.filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
                if !duplicates.isEmpty
                {
                    isRight = false
                    for i in 0...duplicates.count-1 {
                        for yy: Int in 0...2 {
                            for xx: Int in 0...2 {
                                if pixel[x*3+xx][y*3+yy].value == duplicates[i] {
                                    pixel[x*3+xx][y*3+yy].setTitleColor(UIColor.red, for: .normal)
                                }
                            }
                        }
                    }
                }

            }
        }

        return isRight
    }
    
    //finish = true
    func checkFinish() -> Bool {
        var isRight: Bool = true
        
        //reset finish status
        for y: Int in 0...8 {
            for x: Int in 0...8 {
                pixel[x][y].finish(flag: false)
            }
        }

        //row
        var row = [Int]()
        for x: Int in 0...8 {
            row.removeAll()
            for y: Int in 0...8 {
                row.append(pixel[x][y].value)
            }
            if row.reduce(0, +) != 45 {
                isRight = false
            } else {
                for y: Int in 0...8 {
                    pixel[x][y].finish(flag: true)
                }
            }
        }
        
        //col
        var col = [Int]()
        for y: Int in 0...8 {
            col.removeAll()
            for x: Int in 0...8 {
                col.append(pixel[x][y].value)
            }
            if col.reduce(0, +) != 45 {
                isRight = false
            } else {
                for x: Int in 0...8 {
                    pixel[x][y].finish(flag: true)
                }
            }
        }
        
        //9x9
        var area = [Int]()
        for y: Int in 0...2 {
            for x: Int in 0...2 {
                area.removeAll()
                for yy: Int in 0...2 {
                    for xx: Int in 0...2 {
                        area.append(pixel[x*3+xx][y*3+yy].value)
                    }
                }
                if area.reduce(0, +) != 45 {
                    isRight = false
                } else {
                    for yy: Int in 0...2 {
                        for xx: Int in 0...2 {
                            pixel[x*3+xx][y*3+yy].finish(flag: true)
                        }
                    }
                }
            }
        }
        
        return isRight
    }

    func getNonUseNumber(x: Int, y: Int) -> [Int] {
        var found = [Int]()
        mark = Array(repeating: 0, count: 10)
        for i in 0...8 {
            //row
            mark[pixel[i][y].value] = 1
            //col
            mark[pixel[x][i].value] = 1
            //9x9
            mark[pixel[x/3*3+i%3][y/3*3+i/3].value] = 1
        }
        for i in 1...9 {
            if mark[i] == 0 {
                found.append(i)
            }
        }
        return found
    }

    func firstSearch() -> Bool {
        var result = false
        
        //found out only one number space on the pixel
        for y in 0...8 {
            for x in 0...8 {
                if pixel[x][y].value != 0 {
                    continue
                }
                let found = getNonUseNumber(x: x, y: y)
                print("get non-usd number(x,y): ", x, y, "count = ", found.count, found)
                if found.count == 1 {
                    pixel[x][y].value = found[0]
                    result = true
                }
            }
        }
        return result
    }
    
    //pixel had Duplicates = true
    func checkDuplicates(x: Int, y: Int) -> Bool {
        var isDuplicates: Bool = false
        var duplicates: [Int]
        
        //row
        var row = [Int]()
        for yy: Int in 0...8 {
            row.append(pixel[x][yy].value)
        }
        duplicates = Array(Set(row.filter({ (i: Int) in row.filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
        if !duplicates.isEmpty
        {
            isDuplicates = true
        }
        
        //col
        var col = [Int]()
        for xx: Int in 0...8 {
            col.append(pixel[xx][y].value)
        }
        duplicates = Array(Set(col.filter({ (i: Int) in col.filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
        if !duplicates.isEmpty
        {
            isDuplicates = true
        }
        
        //9x9
        var area = [Int]()
        for yy: Int in 0...2 {
            for xx: Int in 0...2 {
                area.append(pixel[x/3*3+xx][y/3*3+yy].value)
            }
        }
        duplicates = Array(Set(area.filter({ (i: Int) in area.filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
        if !duplicates.isEmpty
        {
            isDuplicates = true
        }
        
        return isDuplicates
    }

    //error try from first space to final spaec
    func errorTry() {
        var tempX: Int = -1
        var tempY: Int = -1
        var menoryX = [Int]()
        var menoryY = [Int]()

        //found out first space pixel
        for y in 0...8 {
            for x in 0...8 {
                tempX = x
                tempY = y
                if pixel[tempX][tempY].value == 0 {
                    break
                }
            }
            if pixel[tempX][tempY].value == 0 {
                break
            }
        }
        print("found first zero", tempX, tempY)

        repeat {
            pixel[tempX][tempY].value += 1
            print("set ", tempX, tempY, "=", pixel[tempX][tempY].value)
            if pixel[tempX][tempY].value > 9 {
                print("answer wrong, clean and return")
                pixel[tempX][tempY].value = 0
                if !menoryX.isEmpty {
                    tempX = menoryX.popLast()!
                    tempY = menoryY.popLast()!
                    print("pop", tempX, tempY)
                } else {
                    print("empty stack!!")
                    break
                }
            } else {
                if !checkDuplicates(x: tempX, y: tempY) {
                    menoryX.append(tempX)
                    menoryY.append(tempY)
                    print("push", tempX, tempY)
                    //found out next space pixel
                    for y in tempY...8 {
                        for x in 0...8 {
                            tempX = x
                            tempY = y
                            if pixel[x][y].value == 0 {
                                break
                            }
                        }
                        if pixel[tempX][tempY].value == 0 {
                            break
                        }
                    }
                    print("found next zero", tempX, tempY)
                }
            }
        } while !(tempX == 8 && tempY == 8)

        if pixel[8][8].value == 0 {
            let found = getNonUseNumber(x: 8, y: 8)
            if !found.isEmpty {
                pixel[tempX][tempY].value = found[0]
            } else {
                print("error!!!")
            }
        }
    }
    
    //DFS from minimum non use number to maximum non use number
    func depthFirstSearch() {
        var found = [Int]()
        var min: Int
        var tempX: Int = -1
        var tempY: Int = -1
        var tempAns: Int
        var menoryX = [Int]()
        var menoryY = [Int]()
        var answer = [Int]()
        
        //found out the initial pixel with minimum non use number
        min = 10
        for y in 0...8 {
            for x in 0...8 {
                if pixel[x][y].value == 0 {
                    found = getNonUseNumber(x: x, y: y)
                    if min > found.count {
                        min = found.count
                        tempX = x
                        tempY = y
                    }
                }
            }
        }
        found = getNonUseNumber(x: tempX, y: tempY)
        print("initial found ", tempX, tempY, "=", found.count, found)

        while true {
            if checkFinish() {
                break
            }
            
            if !found.isEmpty {
                pixel[tempX][tempY].value = found.removeFirst()
                print("set ", tempX, tempY, "=", pixel[tempX][tempY].value, "(", found.count, ")")
            } else {
                print("last is empty, clean and return")
                pixel[tempX][tempY].value = 0
                if !menoryX.isEmpty {
                    tempX = menoryX.popLast()!
                    tempY = menoryY.popLast()!
                    tempAns = answer.popLast()!
                    pixel[tempX][tempY].value = 0
                    found = getNonUseNumber(x: tempX, y: tempY)
                    print(found.count)
                    for _ in 0..<found.count {
                        let temp = found.removeFirst()
                        if temp == tempAns {
                            break
                        }
                    }
                    print("pop", tempX, tempY)
                    continue
                } else {
                    print("empty stack!!")
                    break
                }
            }
            
            if checkDuplicates(x: tempX, y: tempY) {
                print("answer wrong, clean and return")
                pixel[tempX][tempY].value = 0
                if !menoryX.isEmpty {
                    tempX = menoryX.popLast()!
                    tempY = menoryY.popLast()!
                    tempAns = answer.popLast()!
                    pixel[tempX][tempY].value = 0
                    found = getNonUseNumber(x: tempX, y: tempY)
                    print(found.count)
                    for _ in 0..<found.count {
                        let temp = found.removeFirst()
                        if temp == tempAns {
                            break
                        }
                    }
                    print("pop", tempX, tempY)
                    continue
                } else {
                    print("empty stack!!")
                    break
                }
            } else {
                menoryX.append(tempX)
                menoryY.append(tempY)
                answer.append(pixel[tempX][tempY].value)
                print("push", tempX, tempY, "=", pixel[tempX][tempY].value)
                //found out next pixel for minimum non use number
                min = 10
                for y in 0...8 {
                    for x in 0...8 {
                        if pixel[x][y].value == 0 {
                            found = getNonUseNumber(x: x, y: y)
                            if min > found.count {
                                min = found.count
                                tempX = x
                                tempY = y
                            }
                        }
                    }
                }
                found = getNonUseNumber(x: tempX, y: tempY)
                print("next found ", tempX, tempY, "=", found.count, found)
            }
        }
    }
    
    func addGameModeBtn() {
        let edge: Int = Int(width / 10)
        let sizeX: Int = (Int(width) - edge * 3) / 2
        
        reset9x9()
        
        var button = UIButton()
        if is16x9 {
            button = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/2))
            button.center = CGPoint(x: CGFloat(edge*2+sizeX*3/2), y: height/10)
        } else {
            button = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/3))
            button.center = CGPoint(x: CGFloat(edge*2+sizeX*3/2), y: height/14)
        }
        button.backgroundColor = UIColor.lightGray
        button.setTitle("To Game Mode", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor.darkText, for: .highlighted)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(gameMode(_:)), for: .touchUpInside)
        view.addSubview(button)
        
        if is16x9 {
            newGameBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX/2, height: sizeX/2))
            newGameBtn.center = CGPoint(x: CGFloat(edge/2+sizeX/4), y: height/10)
        } else {
            newGameBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX/2, height: sizeX/3))
            newGameBtn.center = CGPoint(x: CGFloat(edge/2+sizeX/4), y: height/14)
        }
        newGameBtn.backgroundColor = UIColor.lightGray
        newGameBtn.setTitle("New", for: .normal)
        newGameBtn.setTitleColor(UIColor.darkGray, for: .normal)
        newGameBtn.setTitleColor(UIColor.darkText, for: .highlighted)
        newGameBtn.layer.cornerRadius = 6
        newGameBtn.addTarget(self, action: #selector(newGame(_:)), for: .touchUpInside)
        view.addSubview(newGameBtn)
        newGameBtn.isHidden = true

        if is16x9 {
            backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX/2, height: sizeX/2))
            backBtn.center = CGPoint(x: CGFloat(edge/2+sizeX/4), y: height/5*4)
        } else {
            backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX/2, height: sizeX/3))
            backBtn.center = CGPoint(x: CGFloat(edge/2+sizeX/4), y: height/16*14)
        }
        backBtn.backgroundColor = UIColor.lightGray
        backBtn.setTitle("Back", for: .normal)
        backBtn.setTitleColor(UIColor.darkGray, for: .normal)
        backBtn.setTitleColor(UIColor.darkText, for: .highlighted)
        backBtn.setTitleColor(UIColor.groupTableViewBackground, for: .disabled)
        backBtn.layer.cornerRadius = 6
        backBtn.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.isHidden = true
        backBtn.isEnabled = false

        if is16x9 {
            penBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX/2, height: sizeX/2))
            penBtn.center = CGPoint(x: CGFloat(edge+sizeX*3/4), y: height/5*4)
        } else {
            penBtn = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX/2, height: sizeX/3))
            penBtn.center = CGPoint(x: CGFloat(edge+sizeX*3/4), y: height/16*14)
        }
        penBtn.backgroundColor = UIColor.lightGray
        penBtn.setTitle("Pen", for: .normal)
        penBtn.setTitleColor(UIColor.darkGray, for: .normal)
        penBtn.setTitleColor(UIColor.darkText, for: .highlighted)
        penBtn.layer.cornerRadius = 6
        penBtn.addTarget(self, action: #selector(pen(_:)), for: .touchUpInside)
        view.addSubview(penBtn)
        penBtn.isHidden = true
        
        if is16x9 {
            modeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/2))
            modeLabel.center = CGPoint(x: CGFloat(edge/2+sizeX), y: height/10)
        } else {
            modeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/3))
            modeLabel.center = CGPoint(x: CGFloat(edge/2+sizeX), y: height/14)
        }
        modeLabel.text = ""
        modeLabel.textAlignment = .center
        view.addSubview(modeLabel)
        modeLabel.isHidden = true

        if is16x9 {
            timerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: sizeX*3/2, height: sizeX/2))
            timerLabel.center = CGPoint(x: CGFloat(edge*3/2+sizeX*5/4), y: height/5*4)
        } else {
            timerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: sizeX*3/2, height: sizeX/3))
            timerLabel.center = CGPoint(x: CGFloat(edge*3/2+sizeX*5/4), y: height/16*14)
        }
        timerLabel.text = "00:00:00"
        timerLabel.textAlignment = .center
        view.addSubview(timerLabel)
        timerLabel.isHidden = true
    }
    
    @objc func gameMode(_ sender: UIButton!) {
        isGameMode = !isGameMode
        
        if isGameMode {
            sender.setTitle("To Solve Mode", for: .normal)
        } else {
            sender.setTitle("To Game Mode", for: .normal)
        }
        resetBtn.isHidden = !resetBtn.isHidden
        solveBtn.isHidden = !solveBtn.isHidden
        newGameBtn.isHidden = !newGameBtn.isHidden
        backBtn.isHidden = !backBtn.isHidden
        penBtn.isHidden = !penBtn.isHidden
        modeLabel.isHidden = !modeLabel.isHidden
        timerLabel.isHidden = !timerLabel.isHidden
        
        reset9x9()
        stopTime()
        modeLabel.text = ""
        backRec = [backRecord]()
        backBtn.isEnabled = false
        isPencil = false
        penBtn.setTitle("Pen", for: .normal)
    }
    
    @objc func newGame(_ sender: UIButton!) {
        //cell number:
        //38 - easy
        //30 - normal
        //25 - hard
        //23 - super hard
        let modeSelect = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let easyMode = UIAlertAction(title: "easy", style: .default) { (action:UIAlertAction!) in self.createGame(cell: 38); self.modeLabel.text = "easy"}
        let normalMode = UIAlertAction(title: "normal", style: .default) { (action:UIAlertAction!) in self.createGame(cell: 30); self.modeLabel.text = "normal"}
        let hardMode = UIAlertAction(title: "hard", style: .default) { (action:UIAlertAction!) in self.createGame(cell: 25); self.modeLabel.text = "hard"}
        let superHardMode = UIAlertAction(title: "super hard", style: .default) { (action:UIAlertAction!) in self.createGame(cell: 23); self.modeLabel.text = "super hard"}
        modeSelect.addAction(easyMode)
        modeSelect.addAction(normalMode)
        modeSelect.addAction(hardMode)
        modeSelect.addAction(superHardMode)
        self.present(modeSelect, animated: true, completion:nil)
    }

    @objc func back(_ sender: UIButton!) {
        let tempRec = backRec.popLast()
        tempRec?.btn.value = 0
        backRec.last?.btn.value = (backRec.last?.value)!
        _ = showDuplicates()
        sender.isEnabled = !backRec.isEmpty
    }
    
    @objc func pen(_ sender: UIButton!) {
        isPencil = !isPencil
        if isPencil {
            sender.setTitle("Pencil", for: .normal)
        } else {
            sender.setTitle("Pen", for: .normal)
        }
    }
    
    func SecondsToHoursMinutesSeconds(sec: Int) -> String {
        func getStringFrom(sec: Int) -> String {
            return sec < 10 ? "0\(sec)" : "\(sec)"
        }
        return getStringFrom(sec: sec/3600) + ":" + getStringFrom(sec: (sec%3600)/60) + ":" + getStringFrom(sec: (sec%3600)%60)
    }

    func startTime() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        count += 1
        timerLabel.text = SecondsToHoursMinutesSeconds(sec: count)
    }
    
    func pauseTime() {
        timer.invalidate()
    }

    func stopTime() {
        timer.invalidate()
        count = 0
        timerLabel.text = "00:00:00"
    }

    struct record {
        var x: Int
        var y: Int
        var value: Int
    }
    
    func createGame(cell: Int) {
        var tempCell = 5
        var targetCell = cell

        stopTime()
        backRec = [backRecord]()
        backBtn.isEnabled = false

        repeat {
            reset9x9()
            rec = [record]()
            repeat {
                let x = Int(arc4random_uniform(9))
                let y = Int(arc4random_uniform(9))
                let value = Int(arc4random_uniform(9)+1)
                if pixel[x][y].value == 0 {
                    pixel[x][y].value = value
                    if checkDuplicates(x: x, y: y) {
                        pixel[x][y].value = 0
                    } else {
                        tempCell -= 1
                    }
                }
            } while tempCell != 0
            depthFirstSearch()
        } while !checkFinish()
        
        repeat {
            let x = Int(arc4random_uniform(9))
            let y = Int(arc4random_uniform(9))
            if pixel[x][y].value != 0 {
                rec.append(record(x: x, y: y, value: pixel[x][y].value))
                pixel[x][y].value = 0
                targetCell -= 1
            }
        } while targetCell != 0

        reset9x9()
        for i in 0..<rec.count {
            pixel[rec[i].x][rec[i].y].status = UIButton.status.gameQuestion.rawValue
            pixel[rec[i].x][rec[i].y].value = rec[i].value
        }
        rec = [record]()
        
        startTime()
    }
}

extension UIButton {
    enum status: Int {
        case question = 1
        case answer = 0
        case gameQuestion = 11
    }
    
    private struct cell {
        static var value: Int = 0
        static var status: Int = 0
        static var x: Int = 0
        static var y: Int = 0
    }
    
    var value: Int {
        get {
            return objc_getAssociatedObject(self, &cell.value) as! Int
        }
        set {
            objc_setAssociatedObject(self, &cell.value, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.setTitle(String(newValue), for: .normal)
            if newValue == 0 {
                self.setTitleColor(UIColor.clear, for: .normal)
            } else {
                if let status: Int = objc_getAssociatedObject(self, &cell.status) as? Int {
                    if status == UIButton.status.question.rawValue {
                        self.setTitleColor(UIColor.darkText, for: .normal)
                    } else if status == UIButton.status.answer.rawValue {
                        self.setTitleColor(UIColor.blue, for: .normal)
                    } else if status == UIButton.status.gameQuestion.rawValue {
                        self.setTitleColor(UIColor.white, for: .normal)
                        self.backgroundColor = UIColor.darkGray
                    }
                }
            }
        }
    }

    var status: Int {
        get {
            return objc_getAssociatedObject(self, &cell.status) as! Int
        }
        set {
            objc_setAssociatedObject(self, &cell.status, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var x: Int {
        get {
            return objc_getAssociatedObject(self, &cell.x) as! Int
        }
        set {
            objc_setAssociatedObject(self, &cell.x, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var y: Int {
        get {
            return objc_getAssociatedObject(self, &cell.y) as! Int
        }
        set {
            objc_setAssociatedObject(self, &cell.y, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }


    func finish(flag: Bool) {
        if self.status != status.gameQuestion.rawValue {
            if flag {
                self.backgroundColor = UIColor.groupTableViewBackground
            } else {
                self.backgroundColor = UIColor.clear
            }
        } else {
            self.backgroundColor = UIColor.darkGray
        }
    }
}

