//
//  FlickrPhotoTVC.m
//  Shutterbug
//
//  Created by Martin Mandl on 02.03.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrPhotoTVC.h"
#import "FlickrFetcher.h"
#import "Photo.h"
#import "Recent+Photo.h"

@interface FlickrPhotoTVC ()

@end

@implementation FlickrPhotoTVC

- (void)setupFetchedResultsController
{
    if (self.tag.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"%@ in tags", self.tag];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.tag.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)setTag:(Tag *)tag
{
    _tag = tag;
    self.title = [tag.name capitalizedString];
    [self setupFetchedResultsController];
}

- (void)sendDataforIndexPath:(NSIndexPath *)indexPath toViewController:(UIViewController *)vc
{
    if ([vc respondsToSelector:@selector(setImageURL:)]) {
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [Recent recentPhoto:photo];
        [vc performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
        [vc performSelector:@selector(setTitle:) withObject:photo.title];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                [self sendDataforIndexPath:indexPath
                          toViewController:segue.destinationViewController];
            }
        }
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self sendDataforIndexPath:indexPath
              toViewController:[self.splitViewController.viewControllers lastObject]];
}

@end