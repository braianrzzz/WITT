//Inititate communication with Synapse.
(
~synapse = NetAddr.new("127.0.0.1", 12346);
)

//Definition of a violin/pad-kind synth.
(
SynthDef(\violin,{
	|midinote = 60, amp = 1|
	var sig = VarSaw.ar(midinote.midicps, width: LFNoise2.kr(1).range(0.4,0.8)*SinOsc.kr(4, Rand(0.0,1.0)).range(0.7,0.8))*0.25;
	sig = FreeVerb.ar(sig, mix: 1, room: 1);
	sig = sig * amp * 0.3;
	Out.ar(0,sig!2);
}).add;
)

//Definition of a theremin-kind synth.
(
SynthDef(\theremin, {
	|out=0, amp=1, freq=660, cutoff=600|
	var snd;
	freq = Lag.kr(freq,0.00001);
	snd = LFSaw.ar([freq+(freq*SinOsc.ar(7,0,0.01)),freq+0.01+(freq*SinOsc.ar(7.234,0,0.01))]);
	snd = RLPF.ar(snd, freq+cutoff, 2);
	snd = FreeVerb.ar(snd, mix: 0.8, room: 0.2, damp: 1, mul: 1.0, add: 0.0);
	OffsetOut.ar(out, snd*amp*0.2);
}).add;
)

//Definition of a pulse-kind synth.
(
SynthDef(\pulse, {
	arg amp, ampHz, fund = 40, maxPartial = 4, width = 0.5;
	var amp1, amp2, freq1, freq2, sig1, sig2;

	freq1 = LFNoise0.kr(4).exprange(fund,maxPartial * fund).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund,maxPartial * fund).round(fund);

	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq2 = freq2 * LFPulse.kr(6, add:1);

	amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz, 0.5, 0.12) * 0.75;

	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);

	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);

	Out.ar(0, sig1 * amp);
	Out.ar(1, sig2 * amp);
}).add;
)

//Adding the folder containing the songs to be played.
(
~songs = Array.new;
~folder = PathName.new("C:/Users/TOWEL/Desktop/HW 3/Songs For EQ");
(
~folder.entries.do({
	arg path;
	~songs = ~songs.add(Buffer.read(s, path.fullPath));
});
)
)

//Definition of a Synth to read samples from a folder and apply pan.
(
SynthDef.new(\voices, { |pos, voicesvol|
	var out;
	out = Buffer.read(s,Platform.resourceDir +/+ "sounds/Child_voices.wav");
	Out.ar(0, Pan2.ar(PlayBuf.ar(1,out),pos)*voicesvol);
}).add;
)

//Definition of a GUI
//In which the user can control the different sounds previously created (play/stop), their volume, the pan, and the frequency of the low pass filter.
(
w = Window.new("Control Window", Rect(200,200,600,400)).front;

//Theremin control.
~playtheremin = Button.new(w,Rect(10,10,80,30)).states_([["Play Theremin"],["Stop Theremin"]]);
~playtheremin.action = {if(~playtheremin.value == 1,{~sound = Synth(\theremin)},{~sound.free})};
~gaintheremin = Slider.new(w,Rect(35,50,30,100));
~gaintheremin.action = {~sound.set("amp", ~gaintheremin.value)};

//Pad control.
~playpad = Button.new(w,Rect(100,10,80,30)).states_([["Play Pad"],["Stop Pad"]]);
~playpad.action = {if(~playpad.value == 1,{~sound = Synth(\violin)},{~sound.free})};
~gainpad = Slider.new(w,Rect(125,50,30,100));
~gainpad.action = {~sound.set("amp", ~gainpad.value)};

//Pulse synth control.
~playpulse = Button.new(w,Rect(190,10,80,30)).states_([["Play Pulse"],["Stop Pulse"]]);
~playpulse.action = {if(~playpulse.value == 1,{~sound = Synth(\pulse)},{~sound.free})};
~gainpulse = Slider.new(w,Rect(215,50,30,100));
~gainpulse.action = {~sound.set("amp", ~gainpulse.value)};

//Play/stop songs control.
~playsong1 = Button.new(w,Rect(280,10,80,30)).states_([["Play song1"],["Stop song1"]]);
~playsong1.action = {if(~playsong1.value == 1,{~song1 = Synth(\songEQ, [\freq, \db, \t_trig])},{~song1.free})};
~pausesong1 = Button.new(w,Rect(370,10,80,30)).states_([["Pause song1"],["Resume song1"]]);
~pausesong1.action = {if(~playsong1.value == 1,{~song1.set(\t_trig, 1)},{~song1.run})};
~gainsong1 = Slider.new(w,Rect(305,50,30,100));
~gainsong1.action = {~song1.set("amp", ~gainsong1.value)};

//Voices samples control.
~playvoices = Button.new(w,Rect(460,10,80,30)).states_([["Play voices"],["Stop voices"]]);
~playvoices.action = {if(~playvoices.value == 1,{~voices = Synth("voices")},{~voices.free})};
~gainvoices = Slider.new(w,Rect(485,50,30,100));
~gainvoices.action = {~voices.set("voicesvol", ~gainvoices.value)};
~panvoices = Slider.new(w,Rect(400,180,160,30));
~panvoices.action = {~voices.set("pos", ~panvoices.value.linlin(0,1,-1,1))};

//Frequency of low pass filter control.
~cutoff = Slider.new(w,Rect(10,180,160,30));
~cutoff.action = {~song1.set("cutoff", ~cutoff.value*20000)};
)

//Kinect configuration.
(
var code = 0, head_hit = 0;//Initial variables for changing between instruments and functions.
k = 0;
l = 340; //initial setup for lower frequency bound
h = 530; //initial setup for higher frequency bound

//Tracking of right and left hands, for more info review website: https://synapsekinect.tumblr.com/post/6307752257/maxmspjitter
~trackHands = Task.new({
	{
		~synapse.sendMsg("/lefthand_trackjointpos", 3);
		~synapse.sendMsg("/righthand_trackjointpos", 3);
		//Value 1 = Joint position relative to the torso
		//Value 2 = World mode
		//Value 3 = Pixels on Screen (X values from left to right 0 to 640, Y value from top to bottom 0 to 480, Z stays the same as world mode)
		2.wait;
	}.loop;
}).play;

//OSC definition for receiving the messages from the tracking of the right hand position.
OSCdef.new(\trackRHpos,
	{ |msg|
		var handPos, y,y_, midi, freq, amp, cutoff, pan;
		handPos = msg[1..];
		y = msg[2]; //'y' variable
		y_ = msg[1];// 'x' variable

		//Controlling theremin's variables.
		if(code == 0 && head_hit == 1,
			{
				midi = y.linexp(0,480,82,65);
				amp = y_.linlin(100,500,0,0.2);
				freq = midi.midicps;
				~sound.set(\freq, freq);
				~sound.set(\amp, amp);
			}
		);

		//Controllin pad's variable.
		if(code == 1 && head_hit == 1,
			{
				midi = y.linexp(0,480,80,62);
				amp = y_.linlin(100,500,0,0.5);
				[y,midi].postln;
				~sound.set(\midinote, midi);
				~sound.set(\amp, amp);
			}
		);

		//Controlling the frequency of the low pass filter.
		if(code == 2 && head_hit == 1,
			{
				cutoff = y_.linexp(320,640,80,20000);
				~song1.set(\cutoff, cutoff);
			}
		);

		//Controlling the pan of the voices samples.
		if(code == 4 && head_hit == 1,
			{
				pan = y_.linlin(10,630,-1,1);
				[y_,pan].postln;
				~voices.set(\pos, pan);
			}
		);

	},
	'/righthand_pos_screen',nil,12345
);

//OSC definition for receiving the messages of left hand hits.
OSCdef.new(
	\trackLHhit,
	{
		arg msg;

		//Hit forward with the left hand. (Acticate voices samples
		//and pan.
		if(
			msg[1] == \forward,
			{
				~sound.free;
				code = 4;
				head_hit = 1;
			}
		);

		//Hit left with the left hand to stop the sound.
		if(
			msg[1] == \left,
			{
				~sound.free;
				head_hit = 0;
			}
		);
	},
	'/lefthand',
	nil,
	12345
);


//OSC defintion for receiving the messages of the head hits. And set variables for use the different sounds defined previously (pad, theremin...).
OSCdef.new(
	\trackHEADhit,
	{
		arg msg;

		//Hit forward with the head. (PAD)
		if(msg[1] == \forward,
			{
				~sound.free;
				~sound = Synth.new(\violin);
				code = 1;
				head_hit = 1;
			}
		);

		//Hit right with the head. (theremin)
		if(msg[1] == \right,
			{
				~sound.free;
				~sound = Synth.new(\theremin);
				code = 0;
				head_hit = 1;
			}
		);

		//Hit left with the head. (LPF)
		if(msg[1] == \left,
			{
				~sound.free;
				code = 2;
				head_hit = 1;
			}
		);
	},
	'/head',nil,12345
);
)