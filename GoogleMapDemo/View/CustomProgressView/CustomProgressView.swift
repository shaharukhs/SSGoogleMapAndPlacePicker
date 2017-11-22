//
//  CustomProgressView.swift
//  NSDL
//
//  Created by Ascratech on 9/16/17.
//  Copyright © 2017 Ascra. All rights reserved.
//

import UIKit

@IBDesignable  class CustomProgressView: UIView {

    @IBOutlet var mainView: UIView!
    var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emptyIcon: UIImageView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        self.emptyIcon.loadGif(name: "progressLoader@3x")
        self.emptyIcon.layer.cornerRadius = 10.0
        self.emptyIcon.layer.borderWidth = 1.5
        self.emptyIcon.layer.borderColor = UIColor(hexCode: DarkGreyCustomColor1B).cgColor
        
        mainView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomProgressView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func setUpLoaderText(_ message : String){
        self.titleLabel.text = message
    }

}
