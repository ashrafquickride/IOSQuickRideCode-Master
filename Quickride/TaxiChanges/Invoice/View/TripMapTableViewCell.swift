//
//  TripMapTableViewCell.swift
//  Quickride
//
//  Created by HK on 27/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline

class TripMapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: UIView!
    
    //MARK: Variables
    weak var viewMap: GMSMapView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var taxiTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var journeyTypeLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var taxiCancellationImage: UIImageView!
    
    func initalizeRoute(taxiTripReportViewModel: TaxiTripReportViewModel?){
        var endlat: Double?
        var endlng: Double?
        var polyline: String?
        if taxiTripReportViewModel?.taxiRideInvoice?.tripType == TaxiRidePassenger.TRIP_TYPE_RENTAL {
            endlat = taxiTripReportViewModel?.rentalStopPointList?.last?.stopPointLat
            endlng = taxiTripReportViewModel?.rentalStopPointList?.last?.stopPointLng
            polyline = taxiTripReportViewModel?.getRentalPolyline()
        } else {
            endlat = taxiTripReportViewModel?.taxiRide?.endLat
            endlng = taxiTripReportViewModel?.taxiRide?.endLng
            polyline = taxiTripReportViewModel?.taxiRide?.routePolyline
        }
        fromLabel.text = taxiTripReportViewModel?.taxiRide?.startAddress
        toLabel.text = taxiTripReportViewModel?.taxiRide?.endAddress
        taxiTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiTripReportViewModel?.taxiRide?.pickupTimeMs, timeFormat: DateUtils.DATE_FORMAT_D_MMM_YYYY_h_mm_a)
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapView)
        viewMap.padding = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        if taxiTripReportViewModel?.taxiRide?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION{
            journeyTypeLabel.text = taxiTripReportViewModel?.taxiRide?.journeyType
        }
        GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude:taxiTripReportViewModel?.taxiRide?.startLat ?? 0,longitude : taxiTripReportViewModel?.taxiRide?.startLng ?? 0), shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5)).zIndex = 12
        GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude: endlat ?? 0,longitude: endlng ?? 0), shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5)).zIndex = 12
        GoogleMapUtils.drawRoute(pathString: polyline ?? "", map: viewMap, colorCode: UIColor.black, width: GoogleMapUtils.POLYLINE_WIDTH_4, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        GoogleMapUtils.fitToScreen(route: polyline ?? "", map: viewMap)
        viewMap.animate(toZoom: 11)
        if taxiTripReportViewModel?.taxiRide?.status == TaxiRidePassenger.STATUS_CANCELLED{
            taxiCancellationImage.isHidden = false
            distanceLabel.text = String(taxiTripReportViewModel?.taxiRide?.distance?.roundToPlaces(places: 1) ?? 0) + " Km"
        }else{
            distanceLabel.text = String(taxiTripReportViewModel?.taxiRide?.finalDistance?.roundToPlaces(places: 1) ?? 0) + " Km"
            taxiCancellationImage.isHidden = true
            idLabel.text = "ID " + StringUtils.getStringFromDouble(decimalNumber: taxiTripReportViewModel?.taxiRideInvoice?.id)
        }
    }
}
