//
//  ViewController.swift
//  SudokuSolve
//
//  Created by 黃健偉 on 2018/1/22.
//  Copyright © 2018年 黃健偉. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var area = [[UIView]]()
    var pixel = [[UIButton]]()
    var pixelValue = [[Int]]()
    var mark = [Int]()
    
    var btn = [UIButton]()
    var selectedPixel = UIButton()
    var isKeyBoardLive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        init9x9()
        addResetBtn()
        addSolveBtn()
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
            pixel.append([UIButton]())
            pixelValue.append([Int]())
            for y: Int in 0...8 {
                if x%3 == 0 && y%3 == 0 {
                    area[x/3].append(addArea(location: (x/3, y/3)))
                    view.addSubview(area[x/3][y/3])
                }
                pixel[x].append(addPixel(location: (x%3, y%3)))
                area[x/3][y/3].addSubview(pixel[x][y])
                pixelValue[x].append(0)
            }
        }
    }
    
    func addArea(location: (Int, Int)) -> UIView {
        let height = self.view.bounds.height
        let width = self.view.bounds.width
        
        let borderWidth = 2
        let edge: Int = Int(width / 20)
        let heightOffset = Int(height / 5)
        let size: Int = (Int(width) - edge * 2) / 3 - 3

        let (x, y) = location
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        view.center = CGPoint(x: edge+x*size+size/2-x*borderWidth, y: heightOffset+y*size+size/2-y*borderWidth)
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = CGFloat(borderWidth)
        
        return view
    }

    func addPixel(location: (Int, Int)) -> UIButton {
        let width = self.view.bounds.width
        
        let borderWidth = 1
        let edge: Int = Int(width / 20)
        let size: Int = (Int(width) - edge * 2) / 9

        let (x, y) = location
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
        button.center = CGPoint(x: x*size+size/2-x*borderWidth, y: y*size+size/2-y*borderWidth)
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = CGFloat(borderWidth)

        button.setValue(number: 0)
        button.addTarget(self, action: #selector(ViewController.clickButton(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc func clickButton(_ sender: UIButton!) {
        if !isKeyBoardLive {
            let buttonCenter = CGPoint(x: sender.bounds.origin.x + sender.bounds.size.width / 2, y: sender.bounds.origin.y + sender.bounds.size.height / 2)
            
            let position = sender.convert(buttonCenter, to: self.view)
            addNumberKeyboard(position: position)
            selectedPixel = sender
            isKeyBoardLive = true
        }
    }
    
    let number: [String] = ["1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🆓"]
    
    func addNumberKeyboard(position: CGPoint) {
        let size: Int = 25
        var pos: CGPoint = CGPoint(x: 0, y: 0)
        
        btn.removeAll()
        for x: Int in 0...8 {
            btn.append(UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size)))
            pos.x = position.x + CGFloat(x % 3 * size - size)
            pos.y = position.y + CGFloat(x / 3 * size - size)
            btn[x].center = CGPoint(x: pos.x, y: pos.y)
            btn[x].setTitle(number[x], for: .normal)
            btn[x].addTarget(self, action: #selector(ViewController.setNumber(_:)), for: .touchUpInside)
            view.addSubview(btn[x])
        }
        btn.append(UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size)))
        pos.x = position.x
        pos.y = position.y + CGFloat(size * 2)
        btn[9].center = CGPoint(x: pos.x, y: pos.y)
        btn[9].setTitle("🆓", for: .normal)
        btn[9].addTarget(self, action: #selector(ViewController.setNumber(_:)), for: .touchUpInside)
        view.addSubview(btn[9])
    }
    
    @objc func setNumber(_ sender: UIButton!) {
        let index = number.index(of: sender.currentTitle!)
        selectedPixel.setValue(number: Int((index!+1)%10))
        for x in 0...9 {
            btn[x].removeFromSuperview()
        }
        isKeyBoardLive = false
    }
    
    func addResetBtn() {
        let height = self.view.bounds.height
        let width = self.view.bounds.width
        
        let edge: Int = Int(width / 10)
        let sizeX: Int = (Int(width) - edge * 3) / 2
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/2))
        button.center = CGPoint(x: CGFloat(edge+sizeX/2), y: height/5*4)
        button.backgroundColor = UIColor.lightGray
        button.setTitle("RESET", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor.darkText, for: .highlighted)
        button.layer.cornerRadius = 6
        
        button.addTarget(self, action: #selector(reset9x9), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func reset9x9() {
        for y: Int in 0...8 {
            for x: Int in 0...8 {
                pixel[x][y].setValue(number: 0)
                pixelValue[x][y] = 0
            }
        }
    }

    func addSolveBtn() {
        let height = self.view.bounds.height
        let width = self.view.bounds.width
        
        let edge: Int = Int(width / 10)
        let sizeX: Int = (Int(width) - edge * 3) / 2
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: sizeX, height: sizeX/2))
        button.center = CGPoint(x: CGFloat(edge*2+sizeX*3/2), y: height/5*4)
        button.backgroundColor = UIColor.lightGray
        button.setTitle("SOLVE", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor.darkText, for: .highlighted)
        button.layer.cornerRadius = 6
        
        button.addTarget(self, action: #selector(solve), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func solve() {
        _ = getPixelMap()
        if !checkDuplicatesBeforeStart() {
            print("Fail")
        } else {
            //DPS -> fast
            depthFirstSearch()
            
            //only one solve + error try -> solw
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
    }
    
    func getPixelMap() -> [[Int]] {
        for y: Int in 0...8 {
            for x: Int in 0...8 {
                pixelValue[x][y] = pixel[x][y].getValue()
            }
        }
        return pixelValue
    }
    
    //Duplicates pixel = red color
    func checkDuplicatesBeforeStart() -> Bool {
        var isRight: Bool = true
        
        //row
        for x: Int in 0...8 {
            //found out duplicates except zero
            let duplicates = Array(Set(pixelValue[x].filter({ (i: Int) in pixelValue[x].filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
            if !duplicates.isEmpty
            {
                isRight = false
                for i in 0...duplicates.count-1 {
                    for y in 0...8 {
                        if pixelValue[x][y] == duplicates[i] {
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
                col.append(pixelValue[x][y])
            }

            //found out duplicates except zero
            let duplicates = Array(Set(col.filter({ (i: Int) in col.filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
            if !duplicates.isEmpty
            {
                isRight = false
                for i in 0...duplicates.count-1 {
                    for x in 0...8 {
                        if pixelValue[x][y] == duplicates[i] {
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
                        area.append(pixelValue[x*3+xx][y*3+yy])
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
                                if pixelValue[x*3+xx][y*3+yy] == duplicates[i] {
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
        
        //row
        for x: Int in 0...8 {
            if pixelValue[x].reduce(0, +) != 45 {
                isRight = false
            }
        }
        
        //col
        var col = [Int]()
        for y: Int in 0...8 {
            col.removeAll()
            for x: Int in 0...8 {
                col.append(pixelValue[x][y])
            }
            if col.reduce(0, +) != 45 {
                isRight = false
            }
        }
        
        //9x9
        var area = [Int]()
        for y: Int in 0...2 {
            for x: Int in 0...2 {
                area.removeAll()
                for yy: Int in 0...2 {
                    for xx: Int in 0...2 {
                        area.append(pixelValue[x*3+xx][y*3+yy])
                    }
                }
                if area.reduce(0, +) != 45 {
                    isRight = false
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
            mark[pixelValue[i][y]] = 1
            //col
            mark[pixelValue[x][i]] = 1
            //9x9
            mark[pixelValue[x/3*3+i%3][y/3*3+i/3]] = 1
            //print(pixelValue[i][y], pixelValue[x][i], pixelValue[x/3*3+i%3][y/3*3+i/3])
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
                if pixelValue[x][y] != 0 {
                    continue
                }
                let found = getNonUseNumber(x: x, y: y)
                print("get non-usd number(x,y): ", x, y, "count = ", found.count, found)
                if found.count == 1 {
                    pixelValue[x][y] = found[0]
                    pixel[x][y].setBlueValue(number: found[0])
                    result = true
                }
            }
        }
        print("-----step 1 finish-----")
        return result
    }
    
    //pixel had Duplicates = true
    func checkDuplicates(x: Int, y: Int) -> Bool {
        var isDuplicates: Bool = false
        var duplicates: [Int]
        
        //row
        duplicates = Array(Set(pixelValue[x].filter({ (i: Int) in pixelValue[x].filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
        if !duplicates.isEmpty
        {
            isDuplicates = true
        }
        
        //col
        var col = [Int]()
        for x: Int in 0...8 {
            col.append(pixelValue[x][y])
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
                area.append(pixelValue[x/3*3+xx][y/3*3+yy])
            }
        }
        duplicates = Array(Set(area.filter({ (i: Int) in area.filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
        if !duplicates.isEmpty
        {
            isDuplicates = true
        }
        
        return isDuplicates
    }

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
                if pixelValue[tempX][tempY] == 0 {
                    break
                }
            }
            if pixelValue[tempX][tempY] == 0 {
                break
            }
        }
        print("found first zero", tempX, tempY)

        repeat {
            pixelValue[tempX][tempY] += 1
            pixel[tempX][tempY].setBlueValue(number: pixelValue[tempX][tempY])
            print("set ", tempX, tempY, "=", pixelValue[tempX][tempY])
            if pixelValue[tempX][tempY] > 9 {
                print("answer wrong, clean and return")
                pixelValue[tempX][tempY] = 0
                pixel[tempX][tempY].setValue(number: 0)
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
                            if pixelValue[x][y] == 0 {
                                break
                            }
                        }
                        if pixelValue[tempX][tempY] == 0 {
                            break
                        }
                    }
                    print("found next zero", tempX, tempY)
                }
            }
        } while !(tempX == 8 && tempY == 8)

        if pixelValue[8][8] == 0 {
            let found = getNonUseNumber(x: 8, y: 8)
            if !found.isEmpty {
                pixelValue[tempX][tempY] = found[0]
                pixel[tempX][tempY].setBlueValue(number: found[0])
            } else {
                print("error!!!")
            }
        }
    }
    
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
                if pixelValue[x][y] == 0 {
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
                pixelValue[tempX][tempY] = found.removeFirst()
                print("set ", tempX, tempY, "=", pixelValue[tempX][tempY], "(", found.count, ")")
            } else {
                print("last is empty, clean and return")
                pixelValue[tempX][tempY] = 0
                pixel[tempX][tempY].setValue(number: 0)
                if !menoryX.isEmpty {
                    tempX = menoryX.popLast()!
                    tempY = menoryY.popLast()!
                    tempAns = answer.popLast()!
                    pixelValue[tempX][tempY] = 0
                    pixel[tempX][tempY].setValue(number: 0)
                    found = getNonUseNumber(x: tempX, y: tempY)
                    print(found.count)
                    //bug???
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
                pixelValue[tempX][tempY] = 0
                pixel[tempX][tempY].setValue(number: 0)
                if !menoryX.isEmpty {
                    tempX = menoryX.popLast()!
                    tempY = menoryY.popLast()!
                    tempAns = answer.popLast()!
                    pixelValue[tempX][tempY] = 0
                    pixel[tempX][tempY].setValue(number: 0)
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
                answer.append(pixelValue[tempX][tempY])
                pixel[tempX][tempY].setBlueValue(number: pixelValue[tempX][tempY])
                print("push", tempX, tempY, "=", pixelValue[tempX][tempY])
                //found out next pixel for minimum non use number
                min = 10
                for y in 0...8 {
                    for x in 0...8 {
                        if pixelValue[x][y] == 0 {
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

}

extension UIButton {
    func getValue() -> Int {
        let result = self.titleLabel?.text ?? "0"
        return Int(result)!
    }
    
    func setValue(number: Int) {
        self.setTitle(String(number), for: .normal)
        if number == 0 {
            self.setTitleColor(UIColor.clear, for: .normal)
        } else {
            self.setTitleColor(UIColor.darkText, for: .normal)
        }
    }

    func setBlueValue(number: Int) {
        self.setTitle(String(number), for: .normal)
        self.setTitleColor(UIColor.blue, for: .normal)
    }

    func finish() {
        self.backgroundColor = UIColor.lightGray
    }
}

