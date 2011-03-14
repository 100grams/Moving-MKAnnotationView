# Moving MKAnnotationView.#

This sample iPhone project uses HGMovingAnnotation and HGMovingAnnotationView to show moving annotations on a map. 

![](https://github.com/100grams/Moving-MKAnnotationView/raw/master/Screenshots/HGMovingAnnotation.png) 


HGMovingAnnotation 
------------------

This class derives from MKAnnotation and adds the capability of updating its coordinate by reading it from an <code>HGMapPath</code>, which is a collection of MKMapPoints. 

The current implementation of this class reads the next point on the path every second and updates the annotaiton's coordinate. 

HGMovingAnnotationView
----------------------

This class extends MKAnnotationView by animating its position on the map. It does this by observing its HGMovingAnnotation object. 


## Requirements ##

- iOS 4.3 or later (Sample project was created with Xcode 3.2.6, iOS SDK 4.3 GM Seed)
 

## License ##

HGPageScrollView is released under MIT License.

Please report bugs/issues to help improve this code. 

Any suggestions and/or code to help improve this source will be much appreciated.

Thanks!  