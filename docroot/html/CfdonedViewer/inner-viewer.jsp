<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">

  <link rel="stylesheet" type="text/css" href="/content/css/bulma/bulma.min.css"/>
  <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/cfdoned/bulma-tooltip.min.css"/>
  <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/cfdoned/all.css"/>
  <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/cfdoned/wb.css"/>
    <style>
    body{
      margin :0;
    }
    .dropdown-menu {
      min-width: 6rem;
    }
  </style>
  <title>2D CFD POST</title>
</head>
<body>
<div class="wb-appFrame">
  <div class="wb-appFrame-header">
    <nav class="level">
      <div class="level-left">
        <p class="level-item" id="title">CFD oneD Viewer</p>
      </div>
      <div class="level-left">
        <div class="level-item">
          <p class="control">
            <div class="select">
              <select id="contourSelectX">
              </select>
            </div>
          </p>
        </div>
        <div class="level-item">
          <p class="control">
            <div class="select">
              <select id="contourSelectY">
              </select>
            </div>
          </p>
        </div>
        <div class="level-item">
          <div class="dropdown is-right">
            <div class="dropdown-trigger">
              <button class="button dropdown-trigger" aria-haspopup="true" aria-controls="dropdown-menu">
                <span class="icon">
                  <i class="fas fa-bars"></i>
                </span>
              </button>
              <div class="dropdown-menu" id="dropdown-menu" role="menu">
                <div class="dropdown-content">
                  <div class="dropdown-item" id="">
                    <p><strong>Oepn</strong></p>
                  </div>
                  <a class="dropdown-item" id="localLoadButton">
                    <span>Local File</span>
                  </a>
                  <a class="dropdown-item" id="serverLoadButton">
                    <span>Server File</span>
                  </a>
                  <hr class="dropdown-divider">
                  <a class="dropdown-item" id='downloadButton'>
                    <span>Download</span>
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </nav>
  </div>
  <div class='wb-appFrame-ViewerColumn' id='plotDiv'>
  </div>
</div>

<!-- OnedPlotly libs -->
<script src="<%=request.getContextPath()%>/js/plotly/plotly-basic-1.43.2.min.js"></script>
<script>




	var namespace;
	var currentData;
	var currentTitle;
	var currentSubtitle;
	
	/***********************************************************************
	 * Golbal functions
	 ***********************************************************************/
	function setNamespace( ns ){
		namespace = ns;
	}
	
	function cleanCanvas(){
//		$('#plotDiv').empty();
    document.getElementById("plotDiv").innerHTML = "";
		currentData = undefined;
		currentTitle = '';
		currentSubtitle = '';
	}

  var d3 = Plotly.d3;
  var gd;
  var oned;
  var layout;
  var traces;

  class CFDData {
    constructor(rawData) {
      this.readCFDData(rawData)
    }
    readCFDData(rawData) {
      const datas = rawData.trim().split(/[\s,="']+/);
      let colum_val =[];
      let zone = {};
      let r = 0;
      let plotType = '2D';

      if (!datas[0].toLowerCase().match(/^variables/)) {
        // Not plot3D type
        return -1;    
      } else { // plot3D type
        for(let i = 0; i < datas.length; i++) {
          if (datas[i].toLowerCase().match(/^variables/)) {
            let j = 0;
            while(!datas[i+1].toLowerCase().match(/^zone/)){
              i = i + 1;
              //console.log(datas[i])
              let replaced = datas[i].replace(/\W*/g,'').toLowerCase();
              //console.log(replaced)
              if ( replaced ) {
                colum_val[j++] = replaced;
              }
            }
          } else if (datas[i].toLowerCase().match('zone')){
            i=i+1;
            let i_flag = false, j_flag = false;
    
            //console.log(datas[i]);
            while ( datas[i].replace(/\W+/g,'').match(/^[a-zA-Z]/) ) {
              let key = datas[i].replace(/\W+/g,'').toLowerCase();
              let value = "";
              while ( ! value ) {
                value = datas[++i].replace(/\W+/g,'').toLowerCase();
              }
              if( key.match(/[i]/)){
                zone[key] = parseInt(value);
                i_flag = true;
              } else if( key.match(/[j]/)){
                zone[key] = parseInt(value);
                j_flag = true;
    
              } else if ( key.match(/[tf]/)) {
                zone[key] = value;
              }
              i++;
            }
            i--;
    
            plotType = '2D';
            for (let p = 0; p < colum_val.length; p++) {
              this[colum_val[p]] = new Array();
            }

          } else {     //read data
            if (plotType == '2D'){
              for (let p = 0; p < colum_val.length; p++) {
                this[colum_val[p]][r] = parseFloat(datas[i++]);
              }
              i--;  r++;
            } else {
              return -1;
            }
          }
        }

        this.zone = zone;
        this.varlist = colum_val;
        this.plotType = plotType;
    
        const absMaxX = Math.max.apply(null, this[colum_val[0]].map(Math.abs));
        const absMaxY = Math.max.apply(null, this[colum_val[1]].map(Math.abs));
        this.maxSize = Math.max(absMaxX, absMaxY);
      }
    }
  } //end class


function createSelectOptionX(varlist){
  var options = varlist;

  for (const i in options) {
    const x = options[i];
    if(i == 0)
      var option = "<option value='" + x + "' selected>" + x + "</option>"
    else
      var option = "<option value='" + x + "'>" + x + "</option>"
    document.getElementById('contourSelectX').innerHTML += option;
  }
}
function createSelectOptionY(varlist){
  var options = varlist;

  for (const i in options) {
    const y = options[i];
    if(i == 1)
      var option = "<option value='" + y + "' selected>" + y + "</option>"
    else
      var option = "<option value='" + y + "'>" + y + "</option>"
    document.getElementById('contourSelectY').innerHTML += option;
  } 
}


d3.select('#contourSelectX').on('change', onchangeX);
function onchangeX(){
  var selectValue = d3.select('#contourSelectX').property('value');
  var data_update = traces[0];
  data_update.x =oned[selectValue];

  var layout_update = layout.layout;
  layout_update.xaxis.title = selectValue;
  Plotly.newPlot(gd, [data_update], layout_update, {showSendToCloud: true});
}

d3.select('#contourSelectY').on('change', onchangeY);
function onchangeY(){
  var selectValue = d3.select('#contourSelectY').property('value');
  var data_update = traces[0];
  data_update.y =oned[selectValue];

  var layout_update = layout.layout;
  layout_update.yaxis.title = selectValue;
  Plotly.newPlot(gd, [data_update], layout_update, {showSendToCloud: true});
}

let dropdown = document.querySelector('.dropdown');
dropdown.addEventListener('click', function(event) {
    event.stopPropagation();
    dropdown.classList.toggle('is-active');
});
document.addEventListener('click', function (event) {
  dropdown.classList.remove('is-active');
});


class PlotlyLayout {
  constructor(oned) {
    this.createOnedPlotlyData(oned);
  }
  createOnedPlotlyData(oned){
    this.layout = {
      width : window.innerWidth,
      height : window.innerHeight - 50,
      margin : {t:30, r:10 },
      xaxis : {
//          exponentformat : "e",
        mirror : true,
        linewidth : 1,
        zeroline : false
      },
      yaxis : {
//          exponentformat : "e",
        mirror : true,
        linewidth : 1,
        zeroline : false
      },
      showlegend : false
    }
    this.layout.xaxis.title = oned.varlist[0];
    this.layout.yaxis.title = oned.varlist[1];
  }
}

function loadOneD(data){
  document.getElementById("plotDiv").innerHTML = "";
  var gd3 = d3.select('#plotDiv');
  oned = new CFDData(data);
  console.log(oned);

  traces = [{
    x: oned[oned.varlist[0]],
    y: oned[oned.varlist[1]],
    type: 'scatter'
  }];
  document.getElementById('contourSelectX').innerHTML = '';
  document.getElementById('contourSelectY').innerHTML = '';

  createSelectOptionX(oned.varlist);
  createSelectOptionY(oned.varlist);

  layout = new PlotlyLayout(oned);
  //var plotly = { data : traces, layout : layout.layout };

  //console.log(plotly);

  gd = gd3.node();
  //plotly.divClass = gd;

  Plotly.newPlot(gd, traces, layout.layout, {showSendToCloud: true});
}

function setTitle(title){
  d3.select("#title").text(title);
};

window.onresize = function() {
  var gd3 = d3.select('#plotDiv');
  var h = window.innerHeight - 50;
  var w = window.innerWidth;

  gd = gd3.node();

  var update = {
    width: w,
    height: h
  };

  Plotly.relayout(gd, update);
};

d3.select("#localLoadButton").on("click", function() {
  var function_name = namespace + 'openLocalFile';
  parent[function_name](  );
});
d3.select("#serverLoadButton").on("click", function() {
  var function_name = namespace + 'openServerFile';
  parent[function_name](  );
});

d3.select("#downloadButton").on("click", function() {
  var function_name = namespace + 'downloadCurrentFile';
  parent[function_name]();
});



</script>

</body>
</html>
