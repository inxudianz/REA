//
//  FeedbackContent.swift
//  Creativ
//
//  Created by Owen Prasetya on 08/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation
import UIKit

struct Feedbacks {
    var image = UIImage()
    var title = String()
    var overviewText = String()
    var commentedText = String()
    var comment = String()
    var recommendation = String()
}

class FeedbackData {
    
    // Array yang berisi data feedback section
    var images: [UIImage] = []
    var titles: [String] = []
    var overviewTexts: [String] = []
    var commentedTexts: [String] = []
    
    var comments:[String] = []
    // var comment:[Int:String]?
    
    var recommendations:[String] = []
    // var recommendation:[Int:String]?

    func createFeedbackSection() {
        images = [UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp"), UIImage(named: "feedbackGlyphTemp")] as! [UIImage]
        titles = ["Summary", "Identity", "Education", "Working Experience", "Organisational Experience", "Skills"]
        overviewTexts = ["You have clear summary that explain about yourself. A brief description leaves a positive impression.", "You have given personal information completely. Company will be able to contact you with ease.", "You have shown clear information about your last education. Consider putting your recent education if you haven't", "Your working experiences are detailed. Your experiences  have shown that you are capable and accomplished individual.", "Your organisational experiences were great. You explained in detail on how you work in a team and gave amazing impact.", "Your skills should be things that can point out what's best in you. You have most skills that are needed by the company."]
        commentedTexts = ["You did Great!", "You did Great!", "You did Great!", "You did Great!", "You did Great!", "You did Great!"]
        comments = ["Feedback", "Feedback", "Feedback", "Feedback", "Feedback", "Feedback"]
        recommendations = ["- 200 characters for a summary is enough to explain a brief sentences about yourself.\n- Use first person when introducing yourself to be more approachable.\n- Be specific and highlight your specialties.\n- Show your passion and relevant interests.\n- Avoid vague statements that are not specific enough to carry any weight.\n- Needs to be punchy and outline personal characteristics as it’s related to the role you’re seeking.\n- All sections of a CV, excluding the personal details, should be appropriately labelled.","- Full name (large, bold letters, and centered on the page)\n- Email (should be professional)\n- Address (should not take up lots of space)\n- Phone number", "- Education must be in chronological order (most recent).\n- Remove irrelevant and outdated education.\n- Expand on important education (degree & relevant modules).\n- It’s advisable to show your GPA only if it’s more than equal to 3.", "- Company name, start-end dates, job title, main tasks must be explained well.\n- Employment history should show your achievements.\n- Omit irrelevant job or insignificant work experience.\n- Don’t use jargon or technical terms that are hard to understand.\n- It has to be in chronological order (most recent).", "- Organisation name, event name, start-end dates, position, tasks must be explained well.\n- Irrelevant experiences should not be put in your resume.\n- It has to be in chronological order (most recent).", "- Put skills that are relevant with the job.\n- Preferably skills that you are advance of."]
    }
}
