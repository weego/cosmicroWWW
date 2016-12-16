/*
settings afterh loading
*/

q.getActivePxsKeys.do{|key| Ndef(key).resume.vol_(0).play.fadeTime_(3)};
