//
//  NSAttributedString+AMUtils.m
//  suggest_ios
//
//  Created by Andrey Yurkevich on 11/16/12.
//
//

#import "NSAttributedString+SIO.h"

static const CGFloat kParagraphSpacing = 6;
static const CGFloat kLineSpacing = 1;
static const CGFloat kMaxHeight = 4200.0f; // text rectangle max height - should be a reasonably big number
                                           // that *definitely* exceeds the expected text frame height

@implementation NSAttributedString (SIO)

- (CGSize) sizeToFitForWidth:(CGFloat)maxWidth withFont:(UIFont *)font alignment:(CTTextAlignment)alignment
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    CGSize suggestedSize;

//    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)(font.familyName), font.pointSize, NULL);

        //    create paragraph style and assign text alignment to it
//        CTTextAlignment alignment = kCTJustifiedTextAlignment;
        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        CGFloat lineSpacing = kLineSpacing;
        CGFloat spaceBefore = kParagraphSpacing;
        CTParagraphStyleSetting _settings[] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
            {kCTParagraphStyleSpecifierLineBreakMode, sizeof(lineBreakMode), &lineBreakMode},
            {kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing},
            {kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(spaceBefore), &spaceBefore}
        };
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, 4);

        // set paragraph style attribute
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)(attrStr),
                                       CFRangeMake(0, CFAttributedStringGetLength((__bridge CFAttributedStringRef)(attrStr))),
                                       kCTParagraphStyleAttributeName, paragraphStyle);

        // set font attribute
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)(attrStr),
                                       CFRangeMake(0, CFAttributedStringGetLength((__bridge CFAttributedStringRef)(attrStr))),
                                       kCTFontAttributeName,
                                       fontRef);

        // release paragraph style and font
        CFRelease(paragraphStyle);
        CFRelease(fontRef);

        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attrStr));
        int textLength = [self length];
        CFRange range;
        CGSize constraint = (CGSize){maxWidth, kMaxHeight};
        CGSize framesetterSuggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, textLength), nil, constraint, &range);
        suggestedSize = framesetterSuggestedSize;
        CFRelease(framesetter);
//    }
//    else { // iOS 6.0 and higher
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.alignment = alignment; //NSTextAlignmentJustified;
//        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//        paragraphStyle.hyphenationFactor = 0.5;
//        paragraphStyle.lineSpacing = kLineSpacing;
//        paragraphStyle.paragraphSpacingBefore = kParagraphSpacing;
//
//        [attrStr setAttributes:@{ NSFontAttributeName:           font,
//                                  NSParagraphStyleAttributeName: paragraphStyle}
//                         range:(NSRange){0, self.length}];
//
//        CGRect boundingRect = [attrStr boundingRectWithSize:CGSizeMake(maxWidth, 0)
//                                                    options:NSStringDrawingUsesLineFragmentOrigin
//                                                    context:nil];
//        suggestedSize = boundingRect.size;
//    }

    suggestedSize.height += (font.lineHeight / 2.0);
    // DLog(@"Suggested text size: %.1fx%.1f", suggestedSize.width, suggestedSize.height);

    return (CGSize){ceilf(suggestedSize.width), ceilf(suggestedSize.height)};
}


- (void) renderInRect:(CGRect)rect withFont:(UIFont *)font color:(UIColor *)color  alignment:(CTTextAlignment)alignment
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:self];

//    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);

        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)(font.familyName), font.pointSize, NULL);

        // create paragraph style and assign text alignment to it
        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        CGFloat lineSpacing = kLineSpacing;
        CGFloat spaceBefore = kParagraphSpacing * 2;
        CTParagraphStyleSetting _settings[] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
            {kCTParagraphStyleSpecifierLineBreakMode, sizeof(lineBreakMode), &lineBreakMode},
            {kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing},
            {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(spaceBefore), &spaceBefore}
        };
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, 4);

        // set paragraph style attribute
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)(attrStr),
                                       CFRangeMake(0, CFAttributedStringGetLength((__bridge CFAttributedStringRef)(attrStr))),
                                       kCTParagraphStyleAttributeName, paragraphStyle);

        // set font attribute
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)(attrStr),
                                       CFRangeMake(0, CFAttributedStringGetLength((__bridge CFAttributedStringRef)(attrStr))),
                                       kCTFontAttributeName,
                                       fontRef);

        // set the foreground color
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)(attrStr),
                                       CFRangeMake(0, CFAttributedStringGetLength((__bridge CFAttributedStringRef)(attrStr))),
                                       kCTForegroundColorAttributeName,
                                       color.CGColor);

        // release paragraph style and font
        CFRelease(paragraphStyle);
        CFRelease(fontRef);

        // Flip the coordinate system
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        // Create a path to render text in
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, rect);
        // create the framesetter
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attrStr));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                    CFRangeMake(0, attrStr.length), path, NULL);
        //handle text hyphenation
        CFArrayRef lines = CTFrameGetLines(frame);
        NSInteger count = CFArrayGetCount(lines);
        CGPoint *origins = (CGPoint*) malloc(count * sizeof(CGPoint));
        CTFrameGetLineOrigins(frame, CFRangeMake(0, count), origins);
        NSInteger lineIndex = 0;
        NSString *str = [self string];

        while (count > lineIndex) {
            CTLineRef line = (__bridge CTLineRef)([((__bridge NSArray *)lines) objectAtIndex:lineIndex]);
            CFRange cfStringRange = CTLineGetStringRange(line);
            NSRange stringRange = NSMakeRange(cfStringRange.location, cfStringRange.length);

            static const unichar softHypen = 0x00AD;
            unichar lastChar = [str characterAtIndex:stringRange.location + stringRange.length-1];

            if (softHypen == lastChar) {
                NSMutableAttributedString* lineAttrString = [[attrStr attributedSubstringFromRange:stringRange] mutableCopy];
                NSRange replaceRange = NSMakeRange(stringRange.length - 1, 1);
                [lineAttrString replaceCharactersInRange:replaceRange withString:@"-"];

                CTLineRef hyphenLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)lineAttrString);
                CTLineRef justifiedLine = CTLineCreateJustifiedLine(hyphenLine, 1.0, rect.size.width);

                CGContextSetTextPosition(context, rect.origin.x + origins[lineIndex].x, rect.origin.y - 8.0 + origins[lineIndex].y);
                CTLineDraw(justifiedLine, context);
            }
            else {
                CGContextSetTextPosition(context, rect.origin.x + origins[lineIndex].x, rect.origin.y - 8.0 + origins[lineIndex].y);
                CTLineDraw(line, context);
            }

            lineIndex += 1;
        }

        // Clean up
        CFRelease(frame);
        CFRelease(path);
        CFRelease(framesetter);
        free(origins);

        // Restore the graphics context
        CGContextRestoreGState(context);

//    }
//    else {
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.alignment = alignment; //NSTextAlignmentJustified;
//        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//        paragraphStyle.lineSpacing = kLineSpacing;
//        paragraphStyle.hyphenationFactor = 0.5;
//        paragraphStyle.paragraphSpacingBefore = kParagraphSpacing;
//
//        [attrStr setAttributes:@{ NSFontAttributeName: font,
//                                  NSParagraphStyleAttributeName: paragraphStyle,
//                                  NSForegroundColorAttributeName: color}
//                         range:(NSRange){0, [self string].length}];
//
//        rect.origin.y += kParagraphSpacing;
//
//        [attrStr drawWithRect:rect
//                      options:NSStringDrawingUsesLineFragmentOrigin
//                      context:nil];
//    }
}


@end
