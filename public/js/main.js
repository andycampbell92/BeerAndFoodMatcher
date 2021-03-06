var ready = function(){
	var api = new BeerAndFoodAPI();
	 // Create out canvas for drawing on
	 this.svg = d3.select('#content-holder')
	 	.append("svg")
	 	.attr("class", "canvas")
	 	.attr("id", "ourCanvas");

	 var resetDrawing = function(){
	 	$('#ourCanvas').empty();
	 	window.drawnData = null;
	 }

	 var drawHighLevel = function(svg){
	 	var drawColumn = function(svg, data){
	 		var superNodes = {};
	 		var canvasWidth = $('#ourCanvas').width();
	 		var rectDims = {width:250, height:20};
	 		var margin = 30;
	 		data.forEach(function(node){
 				superNodes[node._id] = {data:node};
 				var newNode = svg.append("g")
 						.attr("transform", "translate(" + (canvasWidth/2 - rectDims.width/2) + "," + (rectDims.height*(Object.keys(superNodes).length+1)) + ")");

                newNode.append("rect")
                	   .attr("width", rectDims.width)
                       .attr("height", rectDims.height)
                       .attr("class", "centre-column");

                newNode.append("text")
                		.text(function(d){return node.name})
                		.attr("class", "centre-column")
                		.attr("transform", "translate(15,15)");

                superNodes[node._id].element = newNode;
	 		});
	 		return superNodes
	 	}
	 	var drawEdgeNodes = function(svg, data, columnData){
	 		var i =22;
	 		var jumped = false;
	 		var x = 500;
	 		data.forEach(function(superNode){
	 			superNode.links.forEach(function(edgeNode){
	 				columnData[edgeNode._id] = {data:edgeNode};
	 				i++;
	 				if(i>44 && jumped==false){
	 					jumped=true;
	 					i+=22;
	 					x+=100;
	 				}

	 				var newNode = svg.append("g")
	 					.attr("transform", "translate(400,200)")
	 					.attr("transform", "translate("+ (Math.cos(2*Math.PI/data.length*i)*300+x) +", " + (Math.sin(2*Math.PI/data.length*i)*900 +600) + ")");
				        //.attr("transform", function(d) {
            			//	console.log(d);
            			//	return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")";
        				//});
	 				newNode.append("circle")
	 					.attr("r", 5)
	 					.attr("class", "edge-node");

	 				newNode.append("text")
	 					.text(function(d){return edgeNode.name})
	 					.attr("class", "edge-node");
	 				columnData[edgeNode._id].element = newNode;
	 			});
	 		});
	 		return columnData;
	 	};
	 	resetDrawing();
	 	api.getHighLevelData().then(function(data){
	 		var columnData = drawColumn(this.svg, data);
	 		console.log(columnData);
	 		window.drawnData = drawEdgeNodes(this.svg, data, columnData);
	 	});
	 }
	 drawHighLevel();
}
$( document ).ready(ready.bind(this));