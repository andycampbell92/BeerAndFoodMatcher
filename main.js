var ready = function(){
	var api = new BeerAndFoodAPI();
	 // Create out canvas for drawing on
	 this.svg = d3.select('#content-holder')
	 	.append("svg")
	 	.attr("class", "canvas")
	 	.attr("id", "ourCanvas");

	 var clearSVG = function(){
	 	$('#ourCanvas').empty();
	 }

	 var drawHighLevel = function(svg){
	 	var drawColumn = function(svg, data){
	 		var superNodes = [];
	 		var canvasWidth = $('#ourCanvas').width();
	 		var rectDims = {width:250, height:20};
	 		var margin = 30;
	 		data.forEach(function(node){
	 			if(node.superNode === true){
	 				var newNode = svg.append("g")
	 						.attr("transform", "translate(" + (canvasWidth/2 - rectDims.width/2) + "," + (rectDims.height*(superNodes.length+1)) + ")");

                    newNode.append("rect")
                    	   .attr("width", rectDims.width)
                           .attr("height", rectDims.height)
                           .attr("class", "centre-column");

                    newNode.append("text")
                    		.text(function(d){return node.name})
                    		.attr("class", "centre-column");

                    superNodes.push(newNode);
	 			};
	 		})
	 	}
	 	clearSVG();
	 	api.getHighLevelData().then(function(data){drawColumn(this.svg, data)});
	 }
	 drawHighLevel();
}
$( document ).ready(ready.bind(this));