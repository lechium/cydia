/* Cydia - iPhone UIKit Front-End for Debian APT
 * Copyright (C) 2008-2015  Jay Freeman (saurik)
*/

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydia.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#include "CyteKit/UCPlatform.h"

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#include "CyteKit/NavigationController.h"
#include "CyteKit/ViewController.h"

#include "iPhonePrivate.h"
#include <Menes/ObjectHandle.h>

@implementation UINavigationController (Cydia)

- (NSArray *) navigationURLCollection {
    NSMutableArray *stack([NSMutableArray array]);

    for (CyteViewController *controller in [self viewControllers]) {
        NSString *url = [[controller navigationURL] absoluteString];
        if (url != nil)
            [stack addObject:url];
    }

    return stack;
}

- (void) reloadData {
    [super reloadData];
    
    UIViewController *visible([self visibleViewController]);
    if (visible != nil)
        [visible reloadData];
    
    extern bool IsWildcat_;
    
    // Something weird happens in rootless 15+, the code above isn't sufficient to get our 'visible' view
    // to reload properly. If the top controller is CYPackageController || SourcesController and != visible
    // we trigger reloadData on those views to make sure changes are populated as necessary.
    
    if (kCFCoreFoundationVersionNumber >= 1854 && !IsWildcat_) { // >= 15.0 & !iPad
        UIViewController *top = [self topViewController];
        if (top && top != visible) {
            Class packageClass = NSClassFromString(@"CYPackageController");
            Class scClass = NSClassFromString(@"SourcesController");
            if ([top isKindOfClass:packageClass] || [top isKindOfClass:scClass]){
                [top reloadData];
            }
        }
    }

    // on the iPad, this view controller is ALSO visible. :(
    if (IsWildcat_)
        if (UIViewController *modal = [self modalViewController])
            if ([modal modalPresentationStyle] == UIModalPresentationFormSheet)
                if (UIViewController *top = [self topViewController])
                    if (top != visible)
                        [top reloadData];
}

- (void) unloadData {
    for (CyteViewController *page in [self viewControllers])
        [page unloadData];

    [super unloadData];
}

@end
