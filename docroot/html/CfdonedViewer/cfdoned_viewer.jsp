<%@page import="com.kisti.osp.util.OSPVisualizerUtil"%>
<%@page import="com.kisti.osp.util.OSPVisualizerConfig"%>
<%@page import="com.kisti.osp.constants.OSPRepositoryTypes"%>
<%@page import="com.liferay.portal.kernel.util.GetterUtil"%>
<%@page import="com.liferay.portal.util.PortalUtil"%>
<%@page import="com.liferay.portal.kernel.portlet.LiferayWindowState"%>
<%@page import="javax.portlet.PortletPreferences"%>
<%@include file="../init.jsp"%>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/main.css">
<portlet:resourceURL var="serveResourceURL"></portlet:resourceURL>
<%
OSPVisualizerConfig visualizerConfig = OSPVisualizerUtil.getVisualizerConfig(renderRequest, portletDisplay, user);
%>

<div class="container-fluid osp-visualizer">
	<div class="row-fluid osp-frame cfdoneD">
		<iframe 
				class="col-sm-12 osp-iframe-canvas"  
				style="<%=visualizerConfig.getDisplayStyle()%> border:0;padding:0;" 
				id="<portlet:namespace/>canvas" 
				src="<%=request.getContextPath()%>/html/CfdonedViewer/inner-viewer.jsp">
		</iframe>
	</div>
</div>

<script>
/***********************************************************************
 * Global variables and initialization section
 ***********************************************************************/
 var <portlet:namespace/>canvas = document.getElementById('<portlet:namespace/>canvas');

 var <portlet:namespace/>config = {
			namespace: '<portlet:namespace/>',
			displayCanvas: <portlet:namespace/>canvas,
			portletId: '<%=portletDisplay.getId()%>',
			connector: '<%=visualizerConfig.connector%>',
			menuOptions: JSON.parse('<%=visualizerConfig.menuOptions%>'), 
			resourceURL: '<%=serveResourceURL%>',
			eventHandlers: {
					'OSP_LOAD_DATA': <portlet:namespace/>loadDataEventHandler,
					'OSP_RESPONSE_DATA':<portlet:namespace/>responseDataEventHandler,
					'OSP_INITIALIZE': <portlet:namespace/>initializeEventHandler
			},
			loadCanvas: <portlet:namespace/>loadCfdOned,
			procFuncs:{
				readServerFile: function( jsonData ){
					console.log('Custom function for readServerFile....');
				}
			}
};
 
 var <portlet:namespace/>visualizer;
 $('#<portlet:namespace/>canvas').load( function(){
	<portlet:namespace/>visualizer = OSP.Visualizer(<portlet:namespace/>config);
	<portlet:namespace/>processInitAction( JSON.parse( '<%=visualizerConfig.initData%>' ) );
 });

/***********************************************************************
 * Canvas functions
 ***********************************************************************/
function <portlet:namespace/>loadCfdOned( jsonData, changeAlert ){
	switch( jsonData.type_ ){
	case OSP.Enumeration.PathType.FILE:
		<portlet:namespace/>visualizer.readServerFile();
		break;
	case OSP.Enumeration.PathType.FOLDER:
	case OSP.Enumeration.PathType.EXT:
	    <portlet:namespace/>visualizer.readFirstServerFile();
		break;
	case OSP.Enumeration.PathType.CONTENT:
	case OSP.Enumeration.PathType.FILE_CONTENT:
		<portlet:namespace/>setTitle( OSP.Util.mergePath( jsonData.parent_, jsonData.name_ ) );
		<portlet:namespace/>visualizer.callIframeFunc( 'loadOneD', null, jsonData.content_, '', '' );
		break;
	case OSP.Enumeration.PathType.URL:
		<portlet:namespace/>visualizer.showAlert( 'Un-supported yet: '+jsonData.type_);
		break;
	default:
		<portlet:namespace/>visualizer.showAlert( 'Un-expected Path type: '+ jsonData.type_);
	}
}

function <portlet:namespace/>setTitle( title ){
	var titleSplit = title.split(".job/");
	if(titleSplit.length > 1 ) {
		var title = "./" + titleSplit[1];
		title = title.replace("//","/");
	}
	<portlet:namespace/>visualizer.callIframeFunc('setTitle', null, title);

//	$('#<portlet:namespace/>title').html( '<h4 style="margin:0;">'+title+'</h4>' );
};

function <portlet:namespace/>processInitAction( jsonInitData ){
	if( jsonInitData && !jsonInitData.repositoryType_ ){
		// Do nothing if repository is not specified.
		// This means processInitAction will be performed OSP_SHAKEHAND event handler.
		return;  
	}
	
	if( !jsonInitData.user_ ){	
		jsonInitData.user_ = '<%=user.getScreenName()%>';
		jsonInitData.dataType_ = {
				name: 'any',
				version:'0.0.0'
		};
		jsonInitData.type_ = OSP.Enumeration.PathType.FOLDER;
		jsonInitData.parent_ = '';
		jsonInitData.name_ = '';
	}
	
	<portlet:namespace/>visualizer.processInitAction( jsonInitData, false );
}

/***********************************************************************
 * Window Event binding functions 
 ***********************************************************************/
function <portlet:namespace/>openLocalFile() {
	<portlet:namespace/>visualizer.openLocalFile();
};

function <portlet:namespace/>openServerFile() {
	<portlet:namespace/>visualizer.openServerFile();
};

function <portlet:namespace/>downloadCurrentFile() {
	<portlet:namespace/>visualizer.downloadCurrentFile();
};



/***********************************************************************
 * Handling OSP Events and event handlers
 ***********************************************************************/
function <portlet:namespace/>loadDataEventHandler( data, params ){
	console.log('[<portlet:namespace/>loadDataEventHandler] ', data );
	
	<portlet:namespace/>visualizer.loadCanvas( data, false );
}

function <portlet:namespace/>responseDataEventHandler( data, params ){
	console.log('[<portlet:namespace/>responseDataEventHandler]', data, params);
	
	switch( params.procFunc ){
		
	case 'readServerFile':
		<portlet:namespace/>visualizer.runProcFuncs( 'readServerFile', data );
		break;
	}
}

function <portlet:namespace/>initializeEventHandler( data, params ){
	console.log('[<portlet:namespace/>initializeEventHandler] ', Liferay.PortletDisplay );
	
	<portlet:namespace/>visualizer.callIframeFunc('cleanCanvas', null );
	<portlet:namespace/>visualizer.processInitAction( null, false );
}
</script>
