/*
same as gamePad for Joystick!
ToDo:
- replace allbutton nrs!
- check Cyborg Nametag

what to set:

X choice of current!
X- current's Vol !
X- preset/seed quartet + shift
X- Influx Wigglers				3 joy axes, (wheel),
latch them only if triggerShift pulled?

X- master Vol 					on throttle
- Center to current (+ make it Preset)


Data cach:
MKtl('joy'): hid, 'scroll_up' > 0 type: button
MKtl('joy'): hid, 'scroll_down' > 1 type: button
X	MKtl('joy'): hid, 'joy_z' > 1 type: joyAxis
X	MKtl('joy'): hid, 'lever_left' > 0.847 type: lever
X	MKtl('joy'): hid, 'lever_right' > 0.847 type: lever
X 	MKtl('joy'): hid, 'compass' > 0.133 type: joyAxis
X  	but 4 round compass:
X  	2,3,4,5 : lu ru, lo ro

but 4 bottom
6,7,8,9

10,11 vorne
14 hinten


MKtl('hid_5_cyborg', 'hid_5_cyborg_x');
// [ "Cyborg X", "Saitek" ]
// create from desc file:
MKtl('hid_5_cyborg', "saitek-cyborg-x");

MKtl.find(\hid)

MKtl(\joy, 'saitek-cyborg-x');

*/

try{
	q=q?();

	// MKtl(\joy).free;
//	MKtl(\joy, 'hid_5_cyborg_x');
	MKtl(\joy, "saitek-cyborg-x"); // STRING OF FILE NAME
	q.joyst = MKtl(\joy);
	q.joyst.gui;
	/*
	q.joyst.elements;
	q.joyst.trace;
	q.joyst.trace(false);
	*/
	q.currCybPx = q.getActivePxsAsList.wrapAt(0); // init to something, eh?

	q.gpFuncs = q.gpFuncs ? ();
	// cache button 9 as shift button. Same for left shldr.
	q.gpFuncs.joyTrig = false;
	q.joyst.elAt('trig').action = ({|el|
		q.gpFuncs.joyTrig = el.value > 0;
		if(el.value > 0){
			q.gpFuncs.startFunc(q.currCybPx);
		}{
			q.gpFuncs.stopFunc(q.currCybPx);
		}
	});
	q.gpFuncs.joyShift1 = false;
	q.joyst.elAt('bt','14').action = ({|el|
		q.gpFuncs.joyShift1 = el.value > 0;
	});

	/*
	// start/stop
	q.joyst.elAt('bt', '6').action = ({|el|
	if(el.value==1){
	q.gpFuncs.startStopToggle( q.currCybPx );
	}
	});
	*/

	// vol
	q.joyst.elAt('lever','left').action = ({|el|
		q.gpFuncs.volFunc(q.currCybPx, (1-el.value).squared);
	});
	q.joyst.elAt('lever','right').action = ({|el|
		var vol = (1-el.value * 1.4).squared.ampdb;
		Server.default.volume = vol;
	});

	// choose active PX ! 7 possibilities, 8th is bad. shift button for more if not enough.
	// odd nrs are hard to catch; hmmm. increment?
	(
		q.joyst.elAt('compass').action = ({|el|
			var val = (el.deviceValue * 7).round.asInteger;
			var chosen;
			//	[val, "    ", el.deviceValue].postcln;
			if(val <= 7){
				// val.postcln;
				chosen = q.getActivePxsAsList.wrapAt(val);
				if(chosen.notNil){
					q.currCybPx = chosen;
					"selected Px: %\n".postf(q.currCybPx);
					// manage Influx: detach all,
					q.getActivePxsAsList.do({ |pxn| q.trinflux.detach(pxn) });
					// just attach the one. Not faceMod
					if(chosen != Ndef(\n6_faceMod)){
						q.trinflux.attachMapped( q.currCybPx  );
					};
					q.centerToCurrent(q.trinflux, q.currCybPx);
					// manage uniwin GUI:
					defer{
						q.switchPxINGui(q.currCybPx);
						q.views.presetWin.addHalo(\active1, val);
					};
				}{ "no proxy here".warn }
			}
		})
	);


	/////////////////////////// 4 5
	//// PRESET MANAGEMENT //// 2 3
	///////////////////////////

	// function macros are in file 4_inphlukx.scd
	(
		// WEST/left side of quartet: N/S for preset change;
		q.joyst.elAt('bt', '2').action = ({|el|
			if(el.value==1){
				q.gpFuncs.incPreset(q.currCybPx, q.trinflux, -1, q.gpFuncs.joyShift1);
		}});
		q.joyst.elAt('bt', '4').action = ({|el|
			if(el.value==1){
				q.gpFuncs.incPreset(q.currCybPx, q.trinflux, 1, q.gpFuncs.joyShift1);
		}});

		// EAST/right side of quartet: N/S for random preset xset;
		q.joyst.elAt('bt', '3').action = ({|el|
			if(el.value==1){
				q.gpFuncs.incSeed(q.currCybPx, q.trinflux, -1, q.gpFuncs.joyShift1, q.gpFuncs.joySeedMuch);
		}});
		q.joyst.elAt('bt', '5').action = ({|el|
			if(el.value==1){
				q.gpFuncs.incSeed(q.currCybPx, q.trinflux, 1, q.gpFuncs.joyShift1, q.gpFuncs.joySeedMuch);
		}});
	);


	///////////////////////////////////////////
	/////// Util Buttons for left hand! ///////
	///////////////////////////////////////////

	//// random preset RESET////
	q.joyst.elAt('bt', '6').action = ({|el|
		if(el.value==1){
			var seed = 0;
			var px = q.currCybPx;
			px.addHalo(\seed, seed);
			postf("re-set to new Seed set % \n", seed );
			q.centerToNewRandSeed(
				q.trinflux,
				px,
				seed, 1
			);
		}
	});
	// clutch in/out  da Influx via the Scroll wheel;
	q.gpFuncs.influxLock = false;
	q.joyst.elAt('bt', '8').action = ({|el|
		if(el.value==1){
			q.gpFuncs.influxLock = q.gpFuncs.influxLock.not;
			postf("influx active: % \n", q.gpFuncs.influxLock);

		}
	});
	// set all influx axes to center
	q.joyst.elAt('bt', '9').action = ({|el|
		if(el.value==1){
			"centering px ".postln;
			q.centerToCurrent(q.trinflux, q.currCybPx)
		}
	});


	///////////////////////////
	// Influx on JoyStix:
	///////////////////////////
	(
		//  Joy: continuous
		q.joyst.elAt(\joy, 'x').action = ({|el|
			if(q.gpFuncs.influxLock){
				var val = el.value;
				val = val.round(1/6).unibi;
				q.trinflux.set(\x, val)
			}
		});
		q.joyst.elAt(\joy, 'y').action = ({|el|
			if(q.gpFuncs.influxLock){
				q.trinflux.set(\y, el.value.unibi.neg);
			}
		});
		q.joyst.elAt(\joy, \rot).action = ({|el|
			if(q.gpFuncs.influxLock){
				q.trinflux.set(\z, el.value.unibi);
			}
		});

	);


	///////////////////////////
	// SCROLL //
	///////////////////////////
	(
		q.gpFuncs.joySeedMuch = 0.9;
		q.joyst.elAt('scroll', 'up').action = ({|el|
			q.gpFuncs.joySeedMuch = (q.gpFuncs.joySeedMuch + 0.05).clip(0.033, 1);
			q.trinflux.inScaler = q.gpFuncs.joySeedMuch * 1.5;
			postf("seed deviation: %\n", q.gpFuncs.joySeedMuch.round(0.01));
		});
		q.joyst.elAt('scroll', 'down').action = ({|el|
			q.gpFuncs.joySeedMuch = (q.gpFuncs.joySeedMuch - 0.1).clip(0.025, 1);
			q.trinflux.inScaler = q.gpFuncs.joySeedMuch * 1.5;
			postf("seed deviation: %\n", q.gpFuncs.joySeedMuch.round(0.01));
		});

	);

}