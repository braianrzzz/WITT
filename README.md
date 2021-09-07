# WITT
We're In This Together - Enhancement Live Project

Repository containing code and data for an interactive audio-visual performance called "We're in this together" 
by Samuele Buonassisi, Manuel Iglesias and Braian Ruiz.

The project consists in the projection of visuals on a white screen on which cubic props are attached. 
Props are made of paper and are arranged in the shape of an arch on the screen. The screen and props are mounted
on a structure made of PVC pipes. The projection is accompanied by three original music pieces composed by the 
three authors. Just in front of the screen, on the ground, some DMX lights were positioned too. The performance is
interactive, meaning that the user can control some instruments and visuals during the projection. It is
possible thanks to a Kinect v1 and a Kinect v2 that were placed in the control area, behind the projector, and track
body of the user.

The performance, audio and visuals, is divided into three parts: Childhood, Adventure and Universo. 

The music is played through SuperCollider, a software to code live audio. It is divided into two parts: the background 
music, which is played through each of the parts from start to end, and live interactive instruments that are added during the performance. 
They are mixed together and sent to the audio interface, and then to the speakers.
The background music and live instruments are different for each part. In SuperCollider some instruments were created:
a theremin synth, a pad synth, a pulse synth, a synth that played the background music and a synth that played voices 
samples. 

A GUI was implemented to control all the synths mentioned, in particular: a play button for each of them,
a slider for the volume of each of them, a slider for the panning of the voices samples, a slider for a LPF applied on
the background music. SuperCollider also comunicated with the Kinect v1: through a software called Synapse, it
sent OSC messages to SuperCollider about the position of some body parts. For the project, the position of the right
hand was tracked, as well as head hits (forward, right and left) and left hand hits (forward and left). With the hits, 
the user can choose which instrument to control, the mapping is as follows:

Head Forward hit ---> Select the Pad<br>
Head Right hit ---> Select the Theremin<br>
Head Left hit ---> Select the Low Pass Filter<br>
Left Hand Forward hit ---> Select the Sample Pan<br>
Left Hand Forward hit ---> Deselect all<br>

When the user has selected the instruments, the right hand is used to control the parameters of that instrument. The
mapping is as follows:

Theremin ---> right hand X axis position: amplitude<br>
              right hand Y axis position: frequency<br>
Pad ---> right hand X axis position: amplitude<br>
         right hand Y axis position: frequency<br>
LPF ---> right hand X axis position: cut-off frequency<br>
Pan ---> right hand X axis position: position on stereo field ranging from 1 (Right channel) to -1 (Left channel)<br>

Madmapper and Processing were used for the visuals and lights. Visuals can be divided into two parts: a background
video and some interactive effects/images that are displayed during the performance. Madmapper contained
the background video and was also used to control the live effects/visuals displayed on the screen. Processing was used
to draw the silhouette of the user and send it to Madmapper. Processing receives OSC messages from the Kinect v2 in order to 
create the silhouette. In Madmapper the image received from Processing is used as another layer that can be added to the 
visuals. At the end Madmapper sends the video signal to the projector.

In Madmapper, on top of the layer containing the background video, some other layers of images are used and displayed during 
the performance. A MIDI controller was implemented to control some parameters of these layers. When pressing a button
or knob, a certain parameter (such as the opacity or position of a layer) is changed.

The lights are mapped into MIDI controls in Madmapper, with the use of the Art-Net protocol.
