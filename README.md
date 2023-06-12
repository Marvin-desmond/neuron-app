### Hi there! :wave:
***
### Neuron[^1]
> Introducing Neuron, a cross-compatible Flutter application that handles preprocessing, inference and postprocessing pipelines for both TensorFlow and PyTorch in a single codebase, by use of Methodchannel communication protocol to handle compute tasks on the Java native codebase.

:pushpin: _It was built as the basis for the idea of a cross-compatible Flutter plugin for both TensorFlow and PyTorch and now it becomes the very foundation by which the plugin will be developed_

[^1]: [Neuron app (and plugin) explained](https://neurify.vercel.app/labs/spark_neuron)

The app, in its home widget, has <span style="color: orange;">model cards</span> for tasks such as classification :dog: :cat:, detection :blue_car:, segmentation :ocean:, and more to come.

<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/1-intro.png?raw=true" width="300">\
\
For the model playground, the default image rendered is attributed to @hardmaru's tweet :point_down:

_"So cool to meet up with AK and the Gradio gang in Shibuya. Got myself some nice_ :hugs: _[huggingface](https://twitter.com/huggingface) swag"_ ~ [@hardmaru](https://twitter.com/hardmaru/status/1661233207344496640)
\
<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/3-classification-no-preds.png?raw=true" width="40%">
\
__:rocket: Classification in action__
> ... the TensorFlow screenshots first then followed by PyTorch, note the model selected in the dropdown widget

<div style="display: flex; justify-content: space-around; margin:20px 0;">
<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/4-classification-tf-image-model.png?raw=true" width="40%">
<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/5-classification-tf-preds.png?raw=true" width="40%">
</div>

<div style="display: flex; justify-content: space-around; margin:20px 0;">
<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/6-classification-pt-image-model.png?raw=true" width="40%">
<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/7-classification-pt-preds.png?raw=true" width="40%">
</div>

__:rocket: Detection in action__


<div style="display: flex; justify-content: space-around; margin:20px 0;">
<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/8-detection-tf-image-model.png?raw=true" width="40%">
<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/9-detection-tf-preds.png?raw=true" width="40%">
</div>

<div style="display: flex; justify-content: space-around; margin:20px 0;">
<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/10-detection-pt-image-model.png?raw=true" width="40%">
<img src="https://github.com/Marvin-desmond/neuron-models-tests/blob/main/spark-neuron/11-detection-pt-preds.png?raw=true" width="40%">
</div>

The whole reason why I am making this <span style="color: orange">app</span> and everything built after it, including the <span style="color: orange">plugin</span>, <span style="color: orange">open-source</span> is for the <span style="color: orange">amazing community</span> out there to improve it to its <span style="color: orange">best version</span> there is.\
\
To contribute to the application in terms of <span style="color: orange">code convention</span>, <span style="color: orange">error handling</span>, <span style="color: orange">UI improvements</span>, <span style="color: orange">optimization</span> in terms of <span style="color: orange">flutter isolates</span>, and <span style="color: orange">code shrinking</span> and <span style="color: orange">treeshaking</span>, among other features\
- clone the repo
- run 
```
flutter pub get
```
on the root folder of the app
- open an emulator, or connect a physical device
- cd to the android folder from the root
- run 
```
./gradlew installDebug
```  
to download the native Java third-party libraries


> I welcome all Flutter, Java, and especially Kotlin developers to help rebuild the Java codebase in Kotlin. The reason I did so in Java was 'cause the official mobile blog and demo for the frameworks was done in Java.