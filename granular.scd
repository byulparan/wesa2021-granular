// 사칙연산
10 + 20
10 - 20
10 * 20
10 / 20


// ====================================================================================
// Sound Generate
s.boot;  // 서버 부팅

(// Make Signal
{
	SinOsc.ar(440, 0, 0.1);
}.play;
)


(// Multichannel Signal
{
	SinOsc.ar([440, 880], 0, 0.1);
}.play;
)


(// use Panning
{
	Pan2.ar(SinOsc.ar(440, 0, 0.1));
}.play;
)



(// Saw
{
	Pan2.ar(Saw.ar(440, 0, 0.2));
}.play;
)


(// Pulse
{
	Pan2.ar(Pulse.ar(440, 0.5 0.2));
}.play;
)



(// WhiteNoise
{
	Pan2.ar(WhiteNoise.ar(0.04));
}.play;
)


// ====================================================================================
// Envenlope

(// WhiteNoise
{
	var env = EnvGen.kr(Env.new([0, 1, 0], [1, 1]), doneAction:2);
	Pan2.ar(WhiteNoise.ar(0.04) * env);
}.play;
)


(// SinOsc
{
	var env = EnvGen.kr(Env.new([0, 1, 0], [1, 1]), doneAction:2);
	Pan2.ar(SinOsc.ar(440, 0, 0.1) * env);
}.play;
)





// ====================================================================================
// SynthDef

(// SinOsc
SynthDef(\sinewave, {|freq = 440, dur = 1.0, attk = 0.0, pan =0.0|
	var env = EnvGen.kr(Env.new([0, 1, 0], dur * [attk, 1.0-attk]), doneAction:2);
	var sig = Pan2.ar(SinOsc.ar(freq, 0, 0.1) * env, pan);
	Out.ar(0, sig);
}).send;
)

Synth(\sinewave);
Synth(\sinewave, [attk: 0.9]);


(
Routine{
	inf.do{
		Synth(\sinewave, [freq: [48, 55 ,60, 71, 74].choose.midicps]);
		1.0.wait;
	}
}.play;
)




// ====================================================================================
// Buffer

~drum = Buffer.read(s,  "/Users/byul/Dropbox/now/wesa/granular/samples/drum.wav" );
~drum.plot

(
{
	Pan2.ar(PlayBuf.ar(1, ~drum, 1));
}.play;
)



// rate, pitch and direction

(
{
	PlayBuf.ar(b.numChannels, ~drum, 1);
}.play;
)







(
SynthDef(\sample, {|buffer = 0, rate = 1, dur = 1, start = 0|
	var sig = PlayBuf.ar(1, buffer, rate, 1, start*44100);
	Line.kr(0,0,dur,doneAction:2);
	Out.ar(0, Pan2.ar(sig));
}).send;
)

(
Routine{
	inf.do{
		Synth(\sample, [buffer: ~drum, dur: 0.125, start: 0]);
		0.125.wait;
	}
}.play;
)








// ====================================================================================
// Granular


// TGrains
(
{
	TGrains.ar(2, Impulse.kr(1), ~drum, 1, 0.0, 0.1, 0.0, 0.1);
}.play;
)




// TGrains with GUI
(
var buf = ~drum;
var synth;


synth = {
	var centerpos = LFNoise1.kr(1).range(0,4);
	SendReply.kr(Impulse.kr(30), '/setPos', centerpos);
	TGrains.ar(2, Impulse.ar(1), buf, 1, centerpos, 0.1, 0.0, 0.1);
}.play;



y = Window.screenBounds.height - 120;
w = Window.new("soundfile test", Rect(200, y, 740, 340)).alwaysOnTop_(true);
w.front;
a = SoundFileView.new(w, Rect(20,20, 700, 300));

f = SoundFile.new;
f.openRead(buf.path);
a.gridOn_(false);
a.timeCursorOn_(true);
a.soundfile = f;
a.read(0, f.numFrames);
a.refresh;


OSCFunc({|msg|
	{a.timeCursorPosition_(msg[3] * 44100)}.defer;
}, "/setPos");

w.onClose_({synth.free;});
)





// ====================================================================================
// RecordBuf
~record = Buffer.alloc(s, s.sampleRate * 4);

(// record to buffer
{
	Line.kr(0,0,4,doneAction:2);
	RecordBuf.ar(SoundIn.ar(0), ~record, 0.0);
	0.0;
}.play;
)


~record.plot;


// Granular
(
{
	TGrains.ar(2, Impulse.kr(1), b, 1, 0.0, 0.1, 0.0, 0.1);
}.play;
)





















