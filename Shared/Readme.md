#  Readme

# Parts
1. App
2. Main views (views) 
3. Titlebar views (views) 
4. Document storage (model) 
5. Hypertext view (views), state and standard data extensions (state becomes part of document) 
6. Support (logs, performance)

# To Do
- What is needed to finish???
- 1 month (July)???
- Platform specific top level views:  IOS (NavigationView), iPadOS (NavigationView) and MacOS (HSplitView). No HSplitView on iPadOS until iPadOS 16. Start with existing platform (Mac?). Currently uses SplitNavigationView, which is just custom NavigationView. This does not work too well for Mac. Better to use HSplitView on Mac? (See ScreenSize for platform adaptation.) 
- App vision and technology: Linked notes. Automatic hypertext.  
- AppStore registration.  
- App icon
- App site

This is basic working hypertext editor, which save to file. 

Need to add and delete documents (pages?). 
Need default document if document is empty or becomes empty. 
Adjust text size?
Set document type and extension. 

Limitations
- Page limitation based on total file size and read-write performance. 
- No import or export: individual or bulk.
- No sync: folder or cloud. 
- No print?
- No find and replace? (Available Mac Hypertexts.) 

# Automatic Link Test Cases
This is a test. 
This is test1. Self links are excluded. 

This is test 3. 
Do we have link to test2? Yes we do. 
Do links work to test1.

- Row selection
Need to extend row selection from text to entire row. 

- Edit update
This is test1. Self links are excluded. (Why does self link sometimes link.? Why do all links sometimes disappear? When editing in middle of existing document?) Appear to link for test1 during inital load, but not during edit?

- All documents excluding self. 
Link to test1.
Link to test2.
Link to test3.

- External document.
Link to external document: http://www.google.com. (Yes, this works.) 

This is much simpler than Hypertexts, which included Core Data database store and CloudKit cloud sync, bulk import and export and optimizations for larger collections. 

# Differences
- IOS opens to File Browser (full screen), which can open new default document. 
- Mac opens File Open chooser (popup) with new default document button??? 
- IOS split screen is 50-50. Need to limit sidebar size. 

# SwiftUI Bugs
- Toolbar placement on Mac of .principal (center) and .primaryAction (trailing). Result is center.         

