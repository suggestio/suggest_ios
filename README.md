suggest_ios
===========

Suggest.io live search for iOS

Requirements
============

Suggest.io live search works on iOS version 5.0 and later, currently only on the iPhone (full iPad support is coming soon) and is compatible ARC-enabled projects. It depends on the following Apple frameworks:

* Foundation.framework
* UIKit.framework
* CoreText.framework

Adding Suggest.io live search to your project
=============================================

The simplest way to add Suggest.io search to your project is to directly add source files from the _suggest_ios_ group to your project.

1. Download the latest code version from the repository (you can simply use the Download Source button and get the zip or tar archive of the master branch).
2. Extract the archive.
3. Open your project in Xcode, than drag and drop `suggest_ios` group to your classes group (in the Groups & Files view). 
4. Make sure to select Copy items when asked.

If you have a git tracked project, you can add suggest_ios as a submodule to your project.

Usage
=====

In order to add Suggest.io live search to your project you will need the following:

1. Creare an instance of SIOSearchBar

You can create an instance of SIOSearchBar in code add it as a subview to a UIView by calling
```objective-c
SIOSearchBar *sb = [[SIOSearchBar alloc] initWithStyle:searchBarStyle rect:searchBarFrame];
[myView addSubview: sb];
```
or by adding a custom view to your view's XIB and setting its class to SIOSearchBar in the Interface Builder.

2. Set the delegate and datasource of the SIOSearchBar.

See the SIOSearchBar.h header for details on the SIOSearchBarDelegate and SIOSearchBarDataSource protocols definition.

In a nutshell, the delegate should provide the FQDN for the website you want to search by implementing the `searchBarQueryDomain:` method; when the search results are available, the delegate's `searchBar:didEndSearching:returningResults:` method is called - you can then display the results passed as an NSArray of SIOSearchResult objects in any way that is suitable for your application. There are also a few other delegate methods available that notify the delegate when the search is started/cancelled and when the search bar has been dismissed.

SIOSearchBar datasource is responsible for network operations for the search request. There is a default implementation that does an NSURLRequest, parses the response data and returns the array of SIOSearchResult objects that incapsulate the search response data. To use the default datasource implementation simply get a shared SIOSearchRequest instance and set it as a datasource for the SIOSearchBar:  
```objective-c
searchBar.datasource = [SIOSearchRequest sharedSearchRequest];
```

See the _Suggest.ios Example_ project for reference and more details.

License
=======

This code is distributed under the terms and conditions of the MIT license.

Copyright (c) 2012 Suggest.io

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Changelog
=========

**Version 0.1** @ 14-Dec-2012

- Initial release.
