var ready = function(){
	 // Create out canvas for drawing on
	 svg = d3.select('#content-holder')
	 	.append("svg")
	 	.attr("class", "canvas")
	 	.attr("id", "ourCanvas");

	 var clearSVG = function()
	 	$('#ourCanvas').clear();

	 var drawHighLevel = function(svg){
	 	clearSVG();

	 }
}
console.log(this);
$( document ).ready(ready.bind(this));