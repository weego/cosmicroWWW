/*
wins for now

- Influx win
- PresetGui
- NdefMixer
- Server Wind
- s.scope
- FaceOsc win
- faceMod Chain
- Master FX

give them all a
q.views
var name and position them all from this folder

*/
q=q?();
q.views = q.views ? ();

q.views.influx;

q.views.presetWin.bounds_(Rect(0, 0, 487, 450));

q.views.ndm = NdefMixer(s);
q.views.ndm.moveTo(493, -98);
q.views.ndm.switchSize(2, true);

try{
	q.views.faceOsc.bounds_(Rect(345, 493, 460, 362));
};

q.views.faceModChain;
q.views.faceModChain.parent.bounds_(Rect(707, 500, 473, 592));

q.views.masterFX;
q.views.masterFX.parent.bounds_(Rect(1182, 500, 471, 772));

q.views.scop = s.scope(q.numChans, zoom: 0.2);
q.views.scop.view.bounds_( Rect(348, 478, 363, 277));

{
	s.makeGui;
	q.views.serverV = s.window;
	q.views.serverV.bounds_(Rect(353, 356, 288, 98))
}.defer(0.1);
