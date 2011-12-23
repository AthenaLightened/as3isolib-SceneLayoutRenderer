<h1>SceneLayoutRenderer</h1>

<h3>Constrains</h3>
<ul>
  <ol>no overlap</ol>
  <ol>no z-value</ol>
  <ol>for performance consideration, the dependency will not be re-built when redepth one element.It will cause few issues.</ol>
</ul>

<h3>Example</h3>
// enable the scene layout renderer
isoScene.layoutRenderer = new SceneLayoutRenderer();

// iso object is an object need to be re-depthed.
SceneLayoutRenderer(isoScene.layoutRenderer).redepth(isoObject);