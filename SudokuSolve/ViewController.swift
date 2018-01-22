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
    
    var btn = [UIButton]()
    var selectedPixel = UIButton()

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
        let buttonCenter = CGPoint(x: sender.bounds.origin.x + sender.bounds.size.width / 2, y: sender.bounds.origin.y + sender.bounds.size.height / 2)
        
        let position = sender.convert(buttonCenter, to: self.view)
        addNumberKeyboard(position: position)
        selectedPixel = sender
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
        for x: Int in 0...8 {
            for y: Int in 0...8 {
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
        let oriArray = getPixelValue()
        print(oriArray)
        if !check() {
            print("Fail")
        }
    }
    
    func getPixelValue() -> [[Int]] {
        for y: Int in 0...8 {
            for x: Int in 0...8 {
                pixelValue[x][y] = pixel[y][x].getValue()
            }
        }
        return pixelValue
    }
    
    func check() -> Bool {
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
                            pixel[y][x].setTitleColor(UIColor.red, for: .normal)
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
                            pixel[y][x].setTitleColor(UIColor.red, for: .normal)
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
                for xx: Int in 0...2 {
                    for yy: Int in 0...2 {
                        area.append(pixelValue[x*3+xx][y*3+yy])
                    }
                }
                
                //found out duplicates except zero
                let duplicates = Array(Set(area.filter({ (i: Int) in area.filter({ $0 == i }).count > 1}))).filter { $0 != 0 }
                if !duplicates.isEmpty
                {
                    isRight = false
                    for i in 0...duplicates.count-1 {
                        for xx: Int in 0...2 {
                            for yy: Int in 0...2 {
                                if pixelValue[x*3+xx][y*3+yy] == duplicates[i] {
                                    pixel[y*3+yy][x*3+xx].setTitleColor(UIColor.red, for: .normal)
                                }
                            }
                        }
                    }
                }

            }
        }

        return isRight
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

    func finish() {
        self.backgroundColor = UIColor.lightGray
    }
}

