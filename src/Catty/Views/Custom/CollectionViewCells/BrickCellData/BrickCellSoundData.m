/**
 *  Copyright (C) 2010-2019 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */


#import "BrickCellSoundData.h"
#import "BrickCell.h"
#import "Sound.h"
#import "Script.h"
#import "Brick.h"
#import "BrickSoundProtocol.h"

@implementation BrickCellSoundData

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell *)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    if(self = [super initWithFrame:frame]) {
        _brickCell = brickCell;
        _lineNumber = line;
        _parameterNumber = parameter;
        NSMutableArray *options = [[NSMutableArray alloc] init];
        [options addObject:kLocalizedNewElement];
        int currentOptionIndex = 0;
        if (!brickCell.isInserting) {
            int optionIndex = 1;
            if([brickCell.scriptOrBrick conformsToProtocol:@protocol(BrickSoundProtocol)]) {
                Brick<BrickSoundProtocol> *soundBrick = (Brick<BrickSoundProtocol>*)brickCell.scriptOrBrick;
                Sound *currentSound = [soundBrick soundForLineNumber:line andParameterNumber:parameter];
                for(Sound *sound in soundBrick.script.object.soundList) {
                    [options addObject:sound.name];
                    if([sound.name isEqualToString:currentSound.name])
                        currentOptionIndex = optionIndex;
                    optionIndex++;
                }
                if (currentSound && ![options containsObject:currentSound.name]) {
                    [options addObject:currentSound.name];
                    currentOptionIndex = optionIndex;
                }
            }

        }
        [self setValues:options];
        [self setCurrentValue:options[currentOptionIndex]];
        [self setDelegate:(id<iOSComboboxDelegate>)self];
    }
    return self;
}

- (void)comboboxDonePressed:(iOSCombobox *)combobox withValue:(NSString *)value
{
    [self.brickCell.dataDelegate updateBrickCellData:self withValue:value];
}

- (void)comboboxOpened:(iOSCombobox *)combobox
{
    /*
    [self.brickCell.dataDelegate disableUserInteractionAndHighlight:self.brickCell withMarginBottom:kiOSComboboxTotalHeight];
     */
    if( [Util topmostViewController] != self.actionSheet){
        self.actionSheet = [UIAlertController alertControllerWithTitle:@"Pick a variable" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self resignFirstResponder];
                                                             }];
        [self.actionSheet addAction:cancelButton];
        int rowCnt = 0;
        
        for(NSString* buttonText in self.values) {
            UIAlertAction* button = [UIAlertAction
                                     actionWithTitle:buttonText
                                     style:UIAlertActionStyleDefault
                                     handler: ^(UIAlertAction * action) {
                                         [self comboboxDonePressed: combobox withValue: buttonText];
                                         [self setCurrentImage:[self.images objectAtIndex:rowCnt]];
                                     }];
            
            [self.actionSheet addAction:button];
            rowCnt++;
        }
        
        [[Util topmostViewController] presentViewController:self.actionSheet animated:YES completion:nil];
    }
    
    
    
    [self.brickCell.dataDelegate disableUserInteractionAndHighlight:self.brickCell withMarginBottom:kiOSComboboxTotalHeight];
    if (combobox.values.count == 1) {
        [self comboboxDonePressed: combobox withValue:combobox.values.firstObject];
    }
}

# pragma mark - User interaction
- (BOOL)isUserInteractionEnabled
{
    return self.brickCell.scriptOrBrick.isAnimatedInsertBrick == NO;
}

@end
