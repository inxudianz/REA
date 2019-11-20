//
//  SegmentModel.swift
//  Creativ
//
//  Created by Robby Awalul Meviansyah Abdillah on 20/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation

struct Segment {
    var segment:[Segment]
    var contents:[SegmentedModel]
    
    init() {
        segment = []
        contents = []
    }
    mutating func addSegment(segment:Segment) {
        self.segment.append(segment)
    }
    
    mutating func addSegments(segments:[Segment]) {
        for segment in segments {
            self.segment.append(segment)
        }
    }
    
    mutating func addContent(content:SegmentedModel) {
        self.contents.append(content)
    }
    
    mutating func addContents(contents:[SegmentedModel]) {
        for content in contents {
            self.contents.append(content)
        }
    }
    
    func  showSegment() {
        dump(self)
    }
}
