# Moving MKAnnotationView.#

This sample iPhone project uses HGMovingAnnotation and HGMovingAnnotationView to show moving annotations on a map. 

![](https://github.com/100grams/Moving-MKAnnotationView/raw/master/Screenshots/HGMovingAnnotation.png) 


HGMovingAnnotation 
------------------

This class derives from MKAnnotation and adds the capability of updating the coordinate (position) and the rotation of the annotation. 
In the sample project, location updates are read from an <code>HGMapPath</code>, which is a collection of MKMapPoints stored on file. 

The current implementation of this class reads the next point on the path every second and updates the annotation's coordinate. 

HGMovingAnnotationView
----------------------

This class extends MKAnnotationView by animating its position and rotation on the map. It does this by observing its HGMovingAnnotation object. 

## iOS7 Compatible ##

- Updated to use XCode5 project structure, iOS7 SDK. 
- Updated deployment target of sample project to iOS6. HGMovingAnnotationView + HGMovingAnnotation can be used on pre-iOS6 versions as well.  
- Added capability to update and animate the rotation of the annotation view. 


## Minimum requirements ##

- iOS 4.3 or later (Sample project was originally created with Xcode 3.2.6, iOS SDK 4.3 GM Seed)
 

## License ##

Moving-MKAnnotationView is released under MIT License.

Please report bugs/issues to info@100grams.nl. 

Any suggestions and/or code to help improve this source will be much appreciated.

Thanks!  
