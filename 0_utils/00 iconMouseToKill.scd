/*
iCon Evil Mouse to Kill

5: 	Usage name and page: 	undefined, 	GenericDesktop
Vendor name: 	iCON
Product name: 	iCON iControl V1.02
Vendor and product ID: 	7427, 26
Path: 	USB_1d03_001a_14100000
Serial Number: 	09101
Releasenumber and interfaceNumber: 	256, -1
*/
/*
// HID.postAvailable;
q.iconMouseToKill = HID.openAt(5);
q.iconMouseToKill = HID.open( 7427, 26, "USB_1d03_001a_14100000" );
q.iconMouseToKill = HID.open('USB_1d03_001a_14100000', 7427, 26);
*/

HID.findAvailable;
q=q?();
// q.iconMouseToKill =
try{
	q.iconMousesToKill = HID.findBy( 7427, 26 );
	q.iconMousesToKill.do(_.open);
};
