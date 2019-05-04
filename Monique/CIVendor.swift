//
//  StreamClient.h
//  Monique
//
//  Created by Shavit Tzuriel on 5/04/19.
//  Copyright © 2019 Shavit Tzuriel. All rights reserved.
//

import CoreImage

class CIVendor: NSObject, CIFilterConstructor {
  

  static func register(){
    CIFilter.registerName("ConvFace",
                           constructor: CIVendor(),
                           classAttributes: [
                             kCIAttributeFilterCategories: [
                               kCICategoryVideo,
                             ]
                           ])
  }


  func filter(withName name: String) -> CIFilter? {
    // TODO: Call convfilters
    // ...
    return nil
  }
}
